# Instabug Backend Challenge (Chat System API)

## Introduction
This project is a chat system built as part of the Instabug Backend Challenge. The system allows creating new applications, each identified by a unique token, and supports multiple chats and messages within each application. The API is built using Ruby on Rails, with MySQL as the main datastore, ElasticSearch for message searching, Redis for handling race conditions, and Sidekiq for background job processing.

## Table of Contents
- [How to Run](#how-to-run)
- [API Documentation](#api-documentation)
- [Technologies](#technologies)
- [Solution Explained](#solution-explained)
## How to Run

1. **Clone the Repository**:
    ```sh
    git clone https://github.com/zeyadahmed10/chat-system-api.git
    cd chat-system-api
    ```

2. **Ensure Docker Daemon is Running**:
    - Make sure Docker is installed and running on your device. You can check if Docker is running by executing:
    ```sh
    docker --version
    ```

3. **Run Docker Compose**:
    - Start the application using Docker Compose:
    ```sh
    docker-compose up -d
    ```

4. **Access the Application**:
   `NOTE: Wait for full boot up before accessing the application`
    - The application will be running on port 3001. You can access it via `http://localhost:3001`.

6. **Stopping the Application**:
    - To stop the application, run:
    ```sh
    docker-compose down
    ```

## API Documentation

### Endpoints
For detailed documentation and (request, response) examples please check [Chat-system-api Documentation](test)
- **Applications**:
    - **Create Application**: `POST /api/v1/applications`
    - **Update Application**: `PUT /api/v1/applications/:application_token`
    - **Get Application**: `GET /api/v1/applications/:application_token`
    - **Get Applications**: `GET /api/v1/applications/`

- **Chats**:
    - **Create Chat**: `POST /api/v1/applications/:application_token/chats`
    - **Get Chats**: `GET /api/v1/applications/:application_token/chats`
    - **Get Chat**: `GET /api/v1/applications/:application_token/chats/:chat_number`

- **Messages**:
    - **Create Message**: `POST /api/v1/applications/:application_token/chats/:chat_number/messages`
    - **Get Messages**: `GET /api/v1/applications/:application_token/chats/:chat_number/messages`
    - **Get Message**: `GET /api/v1/applications/:application_token/chats/:chat_number/messages/:message_number`
    - **Get Message**: `PUT /api/v1/applications/:application_token/chats/:chat_number/messages/:message_number`
    - **Search Messages**: `GET /api/v1/applications/:application_token/chats/:chat_number/messages/search?query=search_term`

---

## Technologies
- **Ruby**: 3.3.4
- **Ruby on Rails**: 7.1.4
- **MySQL**: 5.7
- **ElasticSearch**: 7.10.1
- **Redis**: 7.2
- **Sidekiq**: 7.0
- **Docker & Docker Compose**: Containerization.

## Solution Explained

1. **N+1 Problem And Slow Queries**:
    - **Challenge**: Retrieving messages by first getting the application, then its chats, and finally the messages can cause an N+1 query problem, leading to performance issues.
    - **Solution**: To avoid this, we added foreign keys in the tables and create indexes:
        - `NOTE: As foreign keys doesn't directly solve the N+1 but when will be utilized later for indexing to help.`
        - **Chats Table**: Added `application_token` as a foreign key.
        - **Messages Table**: Added `application_token` and `chat_number` as foreign keys.
    - **Indexes**: Introduced unique composite indexes:
        - **Chats Table**: Composite index on `[application_token, chat_number]` to ensure uniqueness.
        - **Messages Table**: Composite index on `[application_token, chat_number, message_number]` to ensure uniqueness.
    - **Denormalization**: While this approach introduces a bit of denormalization, it effectively solves the N+1 issue by allowing fast retrieval with custom query and minimizing queries. This approach is more efficient than relying solely on the ORM.
    - **Eager Loading**: Although eager loading were considered, they did not solve the N+1 problem effectively with large dataset, Instead custom query to utilize the indexes potential.
    - **Indexing Strategies**:
      - **Index on `application_token` (applications table)**:
        - Ensures that queries retrieving a specific application by token (e.g., `GET /applications/[application_token]`) are efficient and avoid full table scans.
      - **Index on `application_token` (chats table)**:
        - Since each chat belongs to an application, indexing `application_token` in the chats table allows efficient querying of all chats under a specific application (e.g., `GET /applications/[application_token]/chats`).
    - **Composite Index on `application_token` and `chat_number` (chats table)**:
        - Creating a composite index with a unique constraint on `application_token` and `chat_number` ensures that chat numbers are unique within the scope of the application, avoiding potential data integrity issues. This also optimizes retrieval of a specific chat by its number.
    - **Messages Optimization**:
        - Similar to chats, a composite index on `application_token`, `chat_number`, and `message_number` for the messages table ensures that querying messages for a specific chat is efficient and avoids N+1 problems.

2. **Race Condition While Creating Resources**:
    - **Challenge**: Handling race conditions when creating chats and messages to ensure data integrity, especially when the system is running on multiple servers and processing concurrent requests.
    - **Solution**: Use Redis for atomic operations to ensure the uniqueness of chat numbers within an application and message numbers within a chat.
        - **Atomic Operations with Redis**: Utilize Redis' `INCR` command to atomically increment counters for chat and message numbers.
        - **Chat Creation**:
            - Use a Redis key for each application's chat counter (e.g., `chat_counter:application_token`).
            - When creating a new chat, increment the counter using `INCR` and use the returned value as the chat number.
        - **Message Creation**:
            - Use a Redis key for each chat's message counter (e.g., `message_counter:application_token:chat_number`).
            - When creating a new message, increment the counter using `INCR` and use the returned value as the message number.
        - **Benefits of Using `INCR`**:
            - **Atomicity**: `INCR` operations in Redis are atomic, ensuring that each increment is unique and preventing race conditions without the need for complex locking mechanisms.
            - **Performance**: Redis operates in-memory, making `INCR` operations extremely fast compared to querying the database for the maximum chat or message number.
            - **Scalability**: Using Redis reduces the load on the database, allowing the system to handle a higher number of concurrent requests efficiently.
            - **Simplicity**: Implementing atomic counters in Redis simplifies the code and reduces the potential for bugs related to concurrency.
3. **Maintaining Integrity of `application_token`**:
    - **Challenge**: Ensuring that each `application_token` is unique and not updated once created.
    - **Solution**: Generate a unique token using a combination of a random hexadecimal string and the current timestamp, and ensure its uniqueness by checking against the database.
4. **Asynchronous Creation of Chats and Messages, and Updating Counts**:
    - **Challenge**: Efficiently creating chats and messages while updating `chats_count` and `messages_count` without blocking the main application flow.
    - **Solution**: Use Sidekiq for creating asynchronous workers, with the help of Redis, and schedule workers to update counts.
        - **Asynchronous Workers**:
            - **Chat and Message Creation**: Use Sidekiq workers to handle the creation of chats and messages asynchronously.
            - **Updating Counts**: Schedule Sidekiq workers to update `chats_count` and `messages_count` periodically.
        - **Retries with Exponential Backoff**: Set up retries with exponential backoff to handle failed attempts and ensure data integrity.
        - **Benefits**:
            - **Fast Response**: Returns a fast response to the user by offloading the creation and updating tasks to background workers.
            - **Reduced Load**: Offloads the heavy lifting of writing to the database to background workers, reducing the load on the main application.
            - **Data Integrity**: Ensures data integrity by retrying failed operations with exponential backoff, minimizing the risk of data inconsistencies.
5. **ElasticSearch Partial Match**:
    - **Challenge**: Implementing partial match search for message bodies.
    - **Solution**: Use n-grams filter in ElasticSearch to handle partial matches.
        - **N-grams Filter**: Utilize n-grams filter to break down text into smaller chunks, improving search accuracy for partial matches.
        - **Index Creation**: Create an index in ElasticSearch using `application_token` and `chat_number` for sub-document retrieval.
        - **Query Execution**: Perform queries on the index for fast response times.
        - **Benefits**:
            - **Improved Search Accuracy**: N-grams filter enhances the ability to match partial text, making searches more effective.
            - **Fast Retrieval**: Indexing with `application_token` and `chat_number` ensures quick sub-document retrieval.
            - **Advantages Over Wildcard Matching and Prefix Matching**:
                - **Performance**: N-grams are more efficient than wildcard matching with regex, which can be computationally expensive and slow, especially for large datasets.
                - **Accuracy**: N-grams provide better accuracy for partial matches compared to prefix matching, which only matches the beginning of words.
                - **Indexed Text**: N-grams indexing allows for faster searches as the text is already indexed, unlike wildcard searches that require a full scan specially in the  beginning of the search term (e.g., *term) of the text.
                - **Scalability**: N-grams scale better with large datasets, providing consistent performance and accuracy.
