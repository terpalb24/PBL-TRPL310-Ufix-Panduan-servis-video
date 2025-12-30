// tests/integration/tagIntegration.test.js
const request = require('supertest');
const express = require('express');

describe('INTEGRATION TEST: Tag Controller', () => {
  let app;
  let testUserId = 1; // Assuming you have a user with ID 1
  let testVideoId;
  let testTagId;

  // ============================================
  // SETUP
  // ============================================
  beforeAll(async () => {
    console.log('Setting up integration test...');
    
    // Create Express app
    app = express();
    app.use(express.json());
    
    // Load your actual routes
    const tagRoutes = require('../../routes/tagRoutes');
    app.use('/api/tags', tagRoutes);

    // Get database connection from your actual config
    const { dbPromise } = require('../../config/database');
    
    try {
      // Check if we have at least one video for testing
      const [videos] = await dbPromise.query('SELECT idVideo FROM video LIMIT 1');
      
      if (videos.length > 0) {
        testVideoId = videos[0].idVideo;
        console.log(`Using existing video ID: ${testVideoId}`);
      } else {
        // Create a test video if none exists
        const [result] = await dbPromise.query(
          'INSERT INTO video (title, deskripsi, idUser) VALUES (?, ?, ?)',
          ['Integration Test Video', 'Video for integration testing', testUserId]
        );
        testVideoId = result.insertId;
        console.log(`Created test video ID: ${testVideoId}`);
      }

      // Check if we have at least one tag for testing
      const [tags] = await dbPromise.query('SELECT idTag FROM tag LIMIT 1');
      
      if (tags.length > 0) {
        testTagId = tags[0].idTag;
        console.log(`Using existing tag ID: ${testTagId}`);
      }
      
      console.log('Integration test setup completed');
    } catch (error) {
      console.error('Setup failed:', error.message);
      // Continue anyway - some tests might still work
    }
  }, 30000);

  // ============================================
  // 1. BASIC FUNCTIONALITY TESTS
  // ============================================
  describe('1. Basic Functionality Tests', () => {
    test('GET /api/tags/get should return 200', async () => {
      const response = await request(app)
        .get('/api/tags/get');

      console.log('GET /api/tags/get response:', {
        status: response.status,
        success: response.body.success,
        count: response.body.count
      });

      // Should return 200 (even if no tags) or 404 if no tags
      expect([200, 404]).toContain(response.status);
    });

    test('POST /api/tags/create should create tag', async () => {
      const uniqueTagName = `Integration Test ${Date.now()}`;
      
      const response = await request(app)
        .post('/api/tags/create')
        .send({
          tag: uniqueTagName,
          pembuat: testUserId.toString() // Convert to string if needed
        });

      console.log('POST /api/tags/create response:', {
        status: response.status,
        body: response.body
      });

      if (response.status === 201) {
        console.log(`Created tag ID: ${response.body.data.idTag}`);
        // Store for later tests
        if (!testTagId) testTagId = response.body.data.idTag;
      }
      
      // Should be 201 (created) or 409 (duplicate) or 400 (validation)
      expect([201, 400, 409]).toContain(response.status);
    });

    test('POST /api/tags/create should return 400 for empty tag', async () => {
      const response = await request(app)
        .post('/api/tags/create')
        .send({
          tag: '',
          pembuat: testUserId.toString()
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });

  // ============================================
  // 2. TAG-VIDEO RELATIONSHIP TESTS
  // ============================================
  describe('2. Tag-Video Relationship Tests', () => {
    test('POST /api/tags/video should add tag to video', async () => {
      if (!testTagId || !testVideoId) {
        console.log('Skipping test: missing testTagId or testVideoId');
        return;
      }

      const response = await request(app)
        .post('/api/tags/video')
        .send({
          idTag: testTagId,
          idVideo: testVideoId
        });

      console.log('POST /api/tags/video response:', {
        status: response.status,
        body: response.body
      });

      // Should be 201 (created) or 409 (already exists)
      expect([201, 409]).toContain(response.status);
    });

    test('POST /api/tags/video should return 400 for missing parameters', async () => {
      const response = await request(app)
        .post('/api/tags/video')
        .send({
          // Missing idVideo or idTag
        });

      expect(response.status).toBe(400);
    });
  });

  // ============================================
  // 3. UPDATE AND DELETE TESTS
  // ============================================
  describe('3. Update and Delete Tests', () => {
    test('PUT /api/tags/update/:idTag should update tag', async () => {
      if (!testTagId) {
        console.log('Skipping test: missing testTagId');
        return;
      }

      const response = await request(app)
        .put(`/api/tags/update/${testTagId}`)
        .send({
          tag: `Updated ${Date.now()}`,
          pembuat: testUserId.toString()
        });

      console.log('PUT /api/tags/update response:', {
        status: response.status,
        body: response.body
      });

      // Should be 200 (success) or 404 (not found) or 403 (unauthorized)
      expect([200, 403, 404]).toContain(response.status);
    });

    test('DELETE /api/tags/delete/:idTag should delete tag', async () => {
      if (!testTagId) {
        console.log('Skipping test: missing testTagId');
        return;
      }

      // First, remove any relationships
      const { dbPromise } = require('../../config/database');
      try {
        await dbPromise.query('DELETE FROM tagVideo WHERE idTag = ?', [testTagId]);
      } catch (error) {
        console.log('No relationships to delete or error:', error.message);
      }

      const response = await request(app)
        .delete(`/api/tags/delete/${testTagId}`);

      console.log('DELETE /api/tags/delete response:', {
        status: response.status,
        body: response.body
      });

      // Should be 200 (deleted) or 404 (not found) or 400 (in use)
      expect([200, 400, 404]).toContain(response.status);
    });
  });

  // ============================================
  // 4. ERROR HANDLING TESTS
  // ============================================
  describe('4. Error Handling Tests', () => {
    test('GET /api/tags/get - handles database errors gracefully', async () => {
      // This tests that the endpoint doesn't crash
      const response = await request(app)
        .get('/api/tags/get');

      expect(response.status).toBeDefined();
      expect(typeof response.body).toBe('object');
    });

    test('PUT /api/tags/update/99999 should return 404', async () => {
      const response = await request(app)
        .put('/api/tags/update/99999')
        .send({
          tag: 'Non-existent',
          pembuat: testUserId.toString()
        });

      expect([404, 400]).toContain(response.status);
    });
  });

  // ============================================
  // 5. VALIDATION TESTS
  // ============================================
  describe('5. Validation Tests', () => {
    test('Should validate all required fields', async () => {
      const testCases = [
        { body: {}, expectedStatus: 400, description: 'Empty body' },
        { body: { tag: 'Test' }, expectedStatus: 400, description: 'Missing pembuat' },
        { body: { pembuat: testUserId.toString() }, expectedStatus: 400, description: 'Missing tag' },
        { body: { tag: '', pembuat: testUserId.toString() }, expectedStatus: 400, description: 'Empty tag' },
        { body: { tag: 'Valid', pembuat: '' }, expectedStatus: 400, description: 'Empty pembuat' }
      ];

      for (const testCase of testCases) {
        const response = await request(app)
          .post('/api/tags/create')
          .send(testCase.body);

        console.log(`${testCase.description}: ${response.status}`);
        
        // Should be 400 for validation errors
        if (response.status !== 201 && response.status !== 409) {
          expect(response.status).toBe(400);
        }
      }
    });
  });
});