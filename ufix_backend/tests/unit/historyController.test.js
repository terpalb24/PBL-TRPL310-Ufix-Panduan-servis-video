// tests/unit/historyController.test.js - FIXED
// Clear module cache
delete require.cache[require.resolve('../../config/database')];
delete require.cache[require.resolve('../../controllers/historyController')];

// Mock the database
jest.mock('../../config/database', () => ({
  dbPromise: {
    query: jest.fn(),
  },
}));

const { dbPromise } = require('../../config/database');
const historyController = require('../../controllers/historyController');

describe('History Controller - Correct Test', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getAllHistory Function', () => {
    test('should return all history for admin', async () => {
      const mockReq = {};
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      const mockHistory = [
        {
          idPengguna: 1,
          idVideo: 10,
          title: 'Video 1',
          watchedAt: '2024-01-15 10:30:00',
        },
      ];

      dbPromise.query.mockResolvedValueOnce([mockHistory]);

      await historyController.getAllHistory(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Videos Found!',
        videos: mockHistory,
      });
    });

    test('should return 404 when no history exists', async () => {
      const mockReq = {};
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.query.mockResolvedValueOnce([[]]); // Empty result

      await historyController.getAllHistory(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'No videos in the menonton table in the database',
      });
    });
  });

  describe('getHistorySingleUser Function', () => {
    test('should return history for authenticated user', async () => {
      const mockReq = {
        user: { idPengguna: 1 },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      const mockHistory = [
        {
          idVideo: 10,
          title: 'Video 1',
          watchedAt: '2024-01-15 10:30:00',
        },
      ];

      dbPromise.query.mockResolvedValueOnce([mockHistory]);

      await historyController.getHistorySingleUser(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Videos found for this user',
        videos: mockHistory,
      });
    });

    test('should return 401 when user not authenticated', async () => {
      const mockReq = {
        user: null,
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      await historyController.getHistorySingleUser(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Unauthorized',
      });
    });

    test('should return empty array when no history for user', async () => {
      const mockReq = {
        user: { idPengguna: 1 },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.query.mockResolvedValueOnce([[]]); // Empty result

      await historyController.getHistorySingleUser(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'No videos in history for this user',
        videos: [],
      });
    });
  });

  describe('deleteHistoryForSingleUser Function', () => {
    test('should delete history successfully', async () => {
      const mockReq = {
        user: { idPengguna: 1 },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.query.mockResolvedValueOnce(); // DELETE successful

      await historyController.deleteHistoryForSingleUser(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'History successfully deleted for this user',
      });
    });

    test('should return 401 when user not authenticated', async () => {
      const mockReq = {
        user: null,
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      await historyController.deleteHistoryForSingleUser(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Unauthorized',
      });
    });
  });
});