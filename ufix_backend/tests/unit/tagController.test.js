// tests/correct-tag-controller.test.js
// Clear module cache
delete require.cache[require.resolve('../../config/database')];
delete require.cache[require.resolve('../../controllers/tagController')];

// Mock the database
jest.mock('../../config/database', () => ({
  dbPromise: {
    query: jest.fn()
  }
}));

const { dbPromise } = require('../../config/database');
const tagController = require('../../controllers/tagController');

describe('Tag Controller - Correct Test', () => {
  // Test 1: Direct function test (no Express)
  describe('Direct Function Tests', () => {
    beforeEach(() => {
      jest.clearAllMocks();
    });

    test('getAllTags should return tags', async () => {
      const mockTags = [
        { idTag: 1, tag: 'Test1', pembuat: 'user1' },
        { idTag: 2, tag: 'Test2', pembuat: 'user2' }
      ];

      dbPromise.query.mockResolvedValue([mockTags]);

      const mockReq = {};
      const mockRes = {
        json: jest.fn(),
        status: jest.fn().mockReturnThis()
      };

      await tagController.getAllTags(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        count: 2,
        tags: mockTags
      });
    });

    test('getAllTags should return 404 when no tags', async () => {
      dbPromise.query.mockResolvedValue([[]]);

      const mockReq = {};
      const mockRes = {
        json: jest.fn(),
        status: jest.fn().mockReturnThis()
      };

      await tagController.getAllTags(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Belum ada Tag untuk ditampilkan'
      });
    });

    test('newTag should create tag', async () => {
      // NOTE: This test assumes you've FIXED the controller to get pembuat from body
      // If not, it will fail
      
      const mockReq = {
        body: {
          tag: 'New Tag',
          pembuat: 'testuser'
        }
      };

      const mockRes = {
        json: jest.fn(),
        status: jest.fn().mockReturnThis()
      };

      // Mock: tag doesn't exist
      dbPromise.query.mockResolvedValueOnce([[]]);
      // Mock: insert succeeds
      dbPromise.query.mockResolvedValueOnce([{ insertId: 5 }]);

      await tagController.newTag(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Tag Berhasil Dibuat',
        data: {
          idTag: 5,
          tag: 'New Tag',
          pembuat: 'testuser'
        }
      });
    });

    test('updateTag should update when authorized', async () => {
      const mockReq = {
        params: { idTag: '1' },
        body: {
          tag: 'Updated Tag',
          pembuat: 'creator'
        }
      };

      const mockRes = {
        json: jest.fn(),
        status: jest.fn().mockReturnThis()
      };

      const mockExistingTag = [{
        idTag: 1,
        tag: 'Old Tag',
        pembuat: 'creator' // Same as request
      }];

      // Mock: tag exists
      dbPromise.query.mockResolvedValueOnce([mockExistingTag]);
      // Mock: no duplicate tag name
      dbPromise.query.mockResolvedValueOnce([[]]);
      // Mock: update succeeds
      dbPromise.query.mockResolvedValueOnce([{ affectedRows: 1 }]);

      await tagController.updateTag(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Tag Berhasil Diupdate',
        data: {
          idTag: '1',
          tag: 'Updated Tag',
          pembuat: 'creator'
        }
      });
    });

    test('updateTag should return 404 when tag not found', async () => {
      const mockReq = {
        params: { idTag: '999' },
        body: {
          tag: 'Updated Tag',
          pembuat: 'user'
        }
      };

      const mockRes = {
        json: jest.fn(),
        status: jest.fn().mockReturnThis()
      };

      // Mock: tag doesn't exist
      dbPromise.query.mockResolvedValueOnce([[]]);

      await tagController.updateTag(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Tag tidak ditemukan'
      });
    });
  });

  // Test 2: Express integration test
  describe('Express Integration Tests', () => {
    let app;
    let request;

    beforeAll(() => {
      const express = require('express');
      request = require('supertest');
      app = express();
      app.use(express.json());

      // Define routes
      app.get('/api/tags/get', tagController.getAllTags);
      app.post('/api/tags/create', tagController.newTag);
      app.post('/api/tags/video', tagController.addTagToVideo);
      app.put('/api/tags/update/:idTag', tagController.updateTag);
      app.delete('/api/tags/delete/:idTag', tagController.deleteTag);
    });

    beforeEach(() => {
      jest.clearAllMocks();
    });

    test('GET /api/tags/get - integration', async () => {
      const mockTags = [
        { idTag: 1, tag: 'Integration Test', pembuat: 'testuser' }
      ];

      dbPromise.query.mockResolvedValue([mockTags]);

      const response = await request(app)
        .get('/api/tags/get')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.tags).toEqual(mockTags);
    });

    test('DELETE /api/tags/delete/:idTag - integration', async () => {
      const mockExistingTag = [{
        idTag: 1,
        tag: 'To Delete',
        pembuat: 'user1'
      }];

      const mockTagUsage = [];

      // Mock: tag exists
      dbPromise.query.mockResolvedValueOnce([mockExistingTag]);
      // Mock: tag not used in videos
      dbPromise.query.mockResolvedValueOnce([mockTagUsage]);
      // Mock: delete succeeds
      dbPromise.query.mockResolvedValueOnce([{ affectedRows: 1 }]);

      const response = await request(app)
        .delete('/api/tags/delete/1')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('Tag Berhasil Dihapus');
    });
  });
});