// tests/unit/bookmarkController.test.js - FIXED
// Clear module cache
delete require.cache[require.resolve('../../config/database')];
delete require.cache[require.resolve('../../controllers/bookmarkController')];

// Mock the database
jest.mock('../../config/database', () => ({
  dbPromise: {
    query: jest.fn(),
  },
}));

const { dbPromise } = require('../../config/database');
const bookmarkController = require('../../controllers/bookmarkController');

describe('Bookmark Controller - Correct Test', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getBookmark Function', () => {
    test('should return bookmarks for authenticated user', async () => {
      const mockReq = {
        user: { idPengguna: 1 },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      const mockBookmarks = [
        {
          idBookmark: 1,
          idVideo: 10,
          title: 'Video 1',
          sentDate: '2024-01-15',
          videoPath: '/videos/video1.mp4',
          thumbnailPath: '/thumbnails/thumb1.jpg',
          durationSec: 120,
          uploaderName: 'User One',
        },
      ];

      dbPromise.query.mockResolvedValueOnce([mockBookmarks]);

      await bookmarkController.getBookmark(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        count: 1,
        bookmarks: mockBookmarks,
      });
    });

    test('should return 401 when user is not authenticated', async () => {
      const mockReq = {
        user: null,
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      await bookmarkController.getBookmark(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Unauthorized',
      });
    });

    test('should return empty array when no bookmarks', async () => {
      const mockReq = {
        user: { idPengguna: 1 },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.query.mockResolvedValueOnce([[]]); // Empty result

      await bookmarkController.getBookmark(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        count: 0,
        bookmarks: [],
      });
    });
  });

  describe('addBookmark Function', () => {
    test('should add bookmark successfully', async () => {
      const mockReq = {
        params: { id: '10' },
        user: { idPengguna: 1 },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      // Mock: video exists, not bookmarked, insert successful
      dbPromise.query
        .mockResolvedValueOnce([[{ idVideo: 10 }]]) // Video exists
        .mockResolvedValueOnce([[]]) // Not bookmarked
        .mockResolvedValueOnce([{ insertId: 5 }]); // Insert successful

      await bookmarkController.addBookmark(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Bookmark added',
        bookmarkId: 5,
      });
    });

    test('should return 200 when already bookmarked', async () => {
      const mockReq = {
        params: { id: '10' },
        user: { idPengguna: 1 },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.query
        .mockResolvedValueOnce([[{ idVideo: 10 }]]) // Video exists
        .mockResolvedValueOnce([[{ idBookmark: 5 }]]); // Already bookmarked

      await bookmarkController.addBookmark(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Already bookmarked',
      });
    });

    test('should return 404 when video not found', async () => {
      const mockReq = {
        params: { id: '999' },
        user: { idPengguna: 1 },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.query.mockResolvedValueOnce([[]]); // Video not found

      await bookmarkController.addBookmark(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Video not found',
      });
    });
  });

  describe('deleteBookmark Function', () => {
    test('should delete bookmark successfully', async () => {
      const mockReq = {
        params: { id: '10' },
        user: { idPengguna: 1 },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.query.mockResolvedValueOnce([{ affectedRows: 1 }]);

      await bookmarkController.deleteBookmark(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Bookmark removed',
      });
    });

    test('should return 404 when bookmark not found', async () => {
      const mockReq = {
        params: { id: '999' },
        user: { idPengguna: 1 },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.query.mockResolvedValueOnce([{ affectedRows: 0 }]);

      await bookmarkController.deleteBookmark(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Bookmark not found',
      });
    });
  });
});