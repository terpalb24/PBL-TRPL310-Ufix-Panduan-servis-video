// tests/unit/bookmarkController.test.js
const bookmarkController = require('../../lib/controllers/bookmarkController');

describe('Bookmark Controller - Unit Tests', () => {
  let mockDbPromise;
  let mockReq;
  let mockRes;
  
  beforeEach(() => {
    // Reset all mocks
    jest.clearAllMocks();
    
    // Create mock database instance
    mockDbPromise = {
      query: jest.fn(),
    };
    
    // Mock the database module
    jest.mock('../../lib/config/database', () => ({
      dbPromise: mockDbPromise,
    }));
    
    // Reload the controller to use the mock
    jest.resetModules();
    bookmarkController = require('../../lib/controllers/bookmarkController');
    
    // Create fresh mock request/response for each test
    mockReq = {
      user: null,
      params: {},
    };
    
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
  });
  
  describe('getBookmark Function', () => {
    test('should return 401 when user is not authenticated', async () => {
      mockReq.user = null;
      
      await bookmarkController.getBookmark(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Unauthorized',
      });
    });
    
    test('should return 401 when userId is not found in user object', async () => {
      mockReq.user = { email: 'test@example.com' }; // Missing ID fields
      
      await bookmarkController.getBookmark(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Unauthorized',
      });
    });
    
    test('should return empty bookmarks when user has none', async () => {
      mockReq.user = { idPengguna: 123 };
      
      mockDbPromise.query.mockResolvedValueOnce([[]]); // Empty result
      
      await bookmarkController.getBookmark(mockReq, mockRes);
      
      expect(mockDbPromise.query).toHaveBeenCalledWith(expect.stringContaining('FROM bookmark'), [123]);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        count: 0,
        bookmarks: [],
      });
    });
    
    test('should return bookmarks when user has them', async () => {
      mockReq.user = { userId: 456 }; // Testing alternative field name
      
      const mockBookmarks = [
        {
          idBookmark: 1,
          idVideo: 10,
          title: 'Test Video 1',
          sentDate: '2024-01-15',
          videoPath: '/videos/test1.mp4',
          thumbnailPath: '/thumbnails/test1.jpg',
          durationSec: 120,
          uploaderName: 'User One',
        },
        {
          idBookmark: 2,
          idVideo: 11,
          title: 'Test Video 2',
          sentDate: '2024-01-16',
          videoPath: '/videos/test2.mp4',
          thumbnailPath: '/thumbnails/test2.jpg',
          durationSec: 180,
          uploaderName: 'User Two',
        },
      ];
      
      mockDbPromise.query.mockResolvedValueOnce([mockBookmarks]);
      
      await bookmarkController.getBookmark(mockReq, mockRes);
      
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        count: 2,
        bookmarks: mockBookmarks,
      });
    });
    
    test('should extract userId from idUser field', async () => {
      mockReq.user = { idUser: 789 };
      
      mockDbPromise.query.mockResolvedValueOnce([[]]);
      
      await bookmarkController.getBookmark(mockReq, mockRes);
      
      expect(mockDbPromise.query).toHaveBeenCalledWith(expect.any(String), [789]);
    });
    
    test('should handle database errors gracefully', async () => {
      mockReq.user = { idPengguna: 123 };
      
      mockDbPromise.query.mockRejectedValueOnce(new Error('Database connection failed'));
      
      await bookmarkController.getBookmark(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Server error',
      });
    });
  });
  
  describe('addBookmark Function', () => {
    test('should return 400 when videoId is missing', async () => {
      mockReq.params = {};
      mockReq.user = { idPengguna: 123 };
      
      await bookmarkController.addBookmark(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Invalid request',
      });
    });
    
    test('should return 400 when userId is missing', async () => {
      mockReq.params = { id: '10' };
      mockReq.user = null;
      
      await bookmarkController.addBookmark(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Invalid request',
      });
    });
    
    test('should return 400 when videoId is not a valid number', async () => {
      mockReq.params = { id: 'abc' }; // Will parse to NaN
      mockReq.user = { idPengguna: 123 };
      
      await bookmarkController.addBookmark(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Invalid request',
      });
    });
    
    test('should return 404 when video does not exist', async () => {
      mockReq.params = { id: '999' };
      mockReq.user = { idPengguna: 123 };
      
      mockDbPromise.query
        .mockResolvedValueOnce([[]]) // Video not found
        .mockResolvedValueOnce([[]]); // Not bookmarked (but won't reach this)
      
      await bookmarkController.addBookmark(mockReq, mockRes);
      
      expect(mockDbPromise.query).toHaveBeenCalledWith(
        'SELECT idVideo FROM video WHERE idVideo = ?',
        [999]
      );
      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Video not found',
      });
    });
    
    test('should return 200 when video is already bookmarked', async () => {
      mockReq.params = { id: '10' };
      mockReq.user = { idPengguna: 123 };
      
      mockDbPromise.query
        .mockResolvedValueOnce([[{ idVideo: 10 }]]) // Video exists
        .mockResolvedValueOnce([[{ idBookmark: 5 }]]); // Already bookmarked
      
      await bookmarkController.addBookmark(mockReq, mockRes);
      
      expect(mockDbPromise.query).toHaveBeenCalledWith(
        'SELECT idBookmark FROM bookmark WHERE idVideo = ? AND idPengguna = ?',
        [10, 123]
      );
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Already bookmarked',
      });
    });
    
    test('should create bookmark successfully when not already bookmarked', async () => {
      mockReq.params = { id: '10' };
      mockReq.user = { idPengguna: 123 };
      
      mockDbPromise.query
        .mockResolvedValueOnce([[{ idVideo: 10 }]]) // Video exists
        .mockResolvedValueOnce([[]]) // Not bookmarked
        .mockResolvedValueOnce([{ insertId: 25 }]); // Insert successful
      
      await bookmarkController.addBookmark(mockReq, mockRes);
      
      expect(mockDbPromise.query).toHaveBeenCalledWith(
        'INSERT INTO bookmark (idVideo, idPengguna) VALUES (?, ?)',
        [10, 123]
      );
      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Bookmark added',
        bookmarkId: 25,
      });
    });
    
    test('should handle database errors during video check', async () => {
      mockReq.params = { id: '10' };
      mockReq.user = { idPengguna: 123 };
      
      mockDbPromise.query.mockRejectedValueOnce(new Error('DB Error'));
      
      await bookmarkController.addBookmark(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Failed to add bookmark',
      });
    });
  });
  
  describe('deleteBookmark Function', () => {
    test('should return 400 when videoId or userId is missing', async () => {
      mockReq.params = {};
      mockReq.user = null;
      
      await bookmarkController.deleteBookmark(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Invalid request',
      });
    });
    
    test('should return 404 when bookmark does not exist', async () => {
      mockReq.params = { id: '10' };
      mockReq.user = { idPengguna: 123 };
      
      mockDbPromise.query.mockResolvedValueOnce([{ affectedRows: 0 }]);
      
      await bookmarkController.deleteBookmark(mockReq, mockRes);
      
      expect(mockDbPromise.query).toHaveBeenCalledWith(
        'DELETE FROM bookmark WHERE idVideo = ? AND idPengguna = ?',
        [10, 123]
      );
      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Bookmark not found',
      });
    });
    
    test('should successfully delete bookmark when it exists', async () => {
      mockReq.params = { id: '10' };
      mockReq.user = { idPengguna: 123 };
      
      mockDbPromise.query.mockResolvedValueOnce([{ affectedRows: 1 }]);
      
      await bookmarkController.deleteBookmark(mockReq, mockRes);
      
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Bookmark removed',
      });
    });
    
    test('should handle database errors during deletion', async () => {
      mockReq.params = { id: '10' };
      mockReq.user = { idPengguna: 123 };
      
      mockDbPromise.query.mockRejectedValueOnce(new Error('DB Error'));
      
      await bookmarkController.deleteBookmark(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Failed to remove bookmark',
      });
    });
    
    test('should handle alternative userId field names', async () => {
      // Test with userId field
      mockReq.params = { id: '10' };
      mockReq.user = { userId: 456 };
      
      mockDbPromise.query.mockResolvedValueOnce([{ affectedRows: 1 }]);
      
      await bookmarkController.deleteBookmark(mockReq, mockRes);
      
      expect(mockDbPromise.query).toHaveBeenCalledWith(
        'DELETE FROM bookmark WHERE idVideo = ? AND idPengguna = ?',
        [10, 456]
      );
    });
  });
  
  describe('Edge Cases and Additional Tests', () => {
    test('should handle floating point videoId', async () => {
      mockReq.params = { id: '10.5' };
      mockReq.user = { idPengguna: 123 };
      
      mockDbPromise.query
        .mockResolvedValueOnce([[{ idVideo: 10 }]]) // Note: parseInt('10.5') = 10
        .mockResolvedValueOnce([[]])
        .mockResolvedValueOnce([{ insertId: 30 }]);
      
      await bookmarkController.addBookmark(mockReq, mockRes);
      
      expect(mockDbPromise.query).toHaveBeenCalledWith(
        'INSERT INTO bookmark (idVideo, idPengguna) VALUES (?, ?)',
        [10, 123] // 10, not 10.5
      );
    });
    
    test('should handle very large videoId', async () => {
      mockReq.params = { id: '999999' };
      mockReq.user = { idPengguna: 123 };
      
      mockDbPromise.query.mockResolvedValueOnce([{ affectedRows: 1 }]);
      
      await bookmarkController.deleteBookmark(mockReq, mockRes);
      
      expect(mockDbPromise.query).toHaveBeenCalledWith(
        'DELETE FROM bookmark WHERE idVideo = ? AND idPengguna = ?',
        [999999, 123]
      );
    });
    
    test('should handle string userId in user object', async () => {
      // Note: The code expects numeric IDs but parseInt will handle string numbers
      mockReq.params = { id: '10' };
      mockReq.user = { idPengguna: '123' }; // String instead of number
      
      mockDbPromise.query.mockResolvedValueOnce([{ affectedRows: 1 }]);
      
      await bookmarkController.deleteBookmark(mockReq, mockRes);
      
      // The query will still work with string '123' in SQL
      expect(mockDbPromise.query).toHaveBeenCalledWith(
        'DELETE FROM bookmark WHERE idVideo = ? AND idPengguna = ?',
        [10, '123']
      );
    });
  });
});