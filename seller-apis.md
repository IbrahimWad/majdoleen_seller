# Seller APIs

## API Endpoints

### 1. User Authentication
- **POST /api/auth/login**  
  - **Request Body:**  
    ```json  
    {  
      "email": "string",  
      "password": "string"  
    }  
    ```  
  - **Response:**  
    - **200 OK**:  
      ```json  
      {  
        "token": "string",  
        "user": {  
          "id": "string",  
          "name": "string"  
        }  
      }  
      ```  

### 2. Fetch Products
- **GET /api/products**  
  - **Response:**  
    - **200 OK**:  
      ```json  
      [  
        {  
          "id": "string",  
          "name": "string",  
          "price": "number"  
        }  
      ]  
      ```  

### 3. Create Order
- **POST /api/orders**  
  - **Request Body:**  
    ```json  
    {  
      "productId": "string",  
      "quantity": "number"  
    }  
    ```  
  - **Response:**  
    - **201 Created**:  
      ```json  
      {  
        "orderId": "string"  
      }  
      ```  

### 4. Fetch User Orders
- **GET /api/orders**  
  - **Response:**  
    - **200 OK**:  
      ```json  
      [  
        {  
          "orderId": "string",  
          "status": "string"  
        }  
      ]  
      ```  

## Implementation Notes
- Ensure that all endpoints are secured and validate user input.
- Use appropriate error handling for API responses.
- Implement loading states in the UI for better user experience.

## Design Considerations
- Follow Material Design guidelines for UI components.
- Ensure responsiveness across different screen sizes.