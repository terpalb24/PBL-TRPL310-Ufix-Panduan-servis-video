// tests/unit/searchController.test.js - FIXED
// Clear module cache
delete require.cache[require.resolve('../../config/database')];
delete require.cache[require.resolve('../../controllers/searchController')];

// Mock the database
jest.mock('../../config/database', () => ({
  dbPromise: {
    execute: jest.fn(),
  },
}));

const { dbPromise } = require('../../config/database');
const searchController = require('../../controllers/searchController');

describe('Search Controller - Correct Test', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('searchVideo Function', () => {
    test('should search videos by single tag', async () => {
      const mockReq = {
        query: { tag: 'nature' },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      const mockVideos = [
        {
          idVideo: 1,
          title: 'Beautiful Nature',
          videoPath: '/videos/nature1.mp4',
          durationSec: 120,
        },
      ];

      dbPromise.execute.mockResolvedValueOnce([mockVideos]);

      await searchController.searchVideo(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        count: 1,
        videos: mockVideos,
      });
    });

    test('should search videos by multiple tags', async () => {
      const mockReq = {
        query: { tag: 'nature landscape' },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      const mockVideos = [
        {
          idVideo: 1,
          title: 'Nature Documentary',
          videoPath: '/videos/doc1.mp4',
          durationSec: 300,
        },
      ];

      dbPromise.execute.mockResolvedValueOnce([mockVideos]);

      await searchController.searchVideo(mockReq, mockRes);

      expect(dbPromise.execute).toHaveBeenCalledWith(
        expect.stringContaining('IN (?, ?)'),
        ['nature', 'landscape']
      );
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        count: 1,
        videos: mockVideos,
      });
    });

    test('should return 400 when tag is missing', async () => {
      const mockReq = {
        query: {},
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      await searchController.searchVideo(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Masukan Tag video',
      });
    });

    test('should return empty array when no videos found', async () => {
      const mockReq = {
        query: { tag: 'nonexistent' },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.execute.mockResolvedValueOnce([[]]); // Empty result

      await searchController.searchVideo(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        count: 0,
        videos: [],
      });
    });

    test('should handle tags with extra spaces', async () => {
      const mockReq = {
        query: { tag: '  nature   landscape  ' },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.execute.mockResolvedValueOnce([[]]);

      await searchController.searchVideo(mockReq, mockRes);

      expect(dbPromise.execute).toHaveBeenCalledWith(
        expect.stringContaining('IN (?, ?)'),
        ['nature', 'landscape']
      );
    });
  });
});