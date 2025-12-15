// tests/debug-mock.test.js
jest.mock('../config/database', () => ({
  dbPromise: {
    query: jest.fn()
  }
}));

const { dbPromise } = require('../config/database');

describe('Debug Mock Test', () => {
  test('Check if database mocking works', () => {
    console.log('dbPromise:', dbPromise);
    console.log('dbPromise.query type:', typeof dbPromise.query);
    console.log('Is mock function?', jest.isMockFunction(dbPromise.query));
    
    // Verify it's a mock
    expect(jest.isMockFunction(dbPromise.query)).toBe(true);
    
    // Test that we can mock a response
    dbPromise.query.mockResolvedValue([['test data']]);
    
    // Verify the mock was set
    expect(dbPromise.query).toHaveBeenCalledTimes(0); // Not called yet
  });
});