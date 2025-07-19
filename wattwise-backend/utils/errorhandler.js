// utils/errorHandler.js
export const errorHandler = (statusCode, message) => {
  const error = new Error(message);
  error.statusCode = statusCode;
  return error;
};

export const handleValidationError = (schema, data) => {
  const result = schema.safeParse(data);
  if (!result.success) {
    const message = result.error.errors
      .map((e) => `${e.path[0]}: ${e.message}`)
      .join(", ");
    throw errorHandler(400, message);
  }
  return result.data;
};
