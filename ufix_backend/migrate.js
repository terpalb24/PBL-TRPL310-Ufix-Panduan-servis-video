const { dbPromise } = require('./config/database');

async function tableEngine(schema, table) {
  const [rows] = await dbPromise.execute(
    `SELECT ENGINE FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?`,
    [table]
  );
  return rows.length ? rows[0].ENGINE : null;
}

async function columnInfo(table, column) {
  const [rows] = await dbPromise.execute(
    `SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?`,
    [table, column]
  );
  return rows.length ? rows[0] : null;
}

async function run() {
  try {
    console.log('Running DB migration to create `reply` table with proper foreign keys...');

    // check prerequisite tables
    const [usersExists] = await dbPromise.execute(
      `SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME IN ('users','komentar')`
    );
    const existing = usersExists.map(r => r.TABLE_NAME);
    if (!existing.includes('users') || !existing.includes('komentar')) {
      console.error('Required tables not found. Ensure both `users` and `komentar` exist in this database. Found:', existing);
      process.exit(1);
    }

    // ensure engines are InnoDB
    const usersEngine = await tableEngine(null, 'users');
    const komentarEngine = await tableEngine(null, 'komentar');

    console.log('users engine:', usersEngine, 'komentar engine:', komentarEngine);

    if (usersEngine && usersEngine.toUpperCase() !== 'INNODB') {
      console.log('Altering `users` engine to InnoDB...');
      await dbPromise.execute('ALTER TABLE users ENGINE = InnoDB');
    }
    if (komentarEngine && komentarEngine.toUpperCase() !== 'INNODB') {
      console.log('Altering `komentar` engine to InnoDB...');
      await dbPromise.execute('ALTER TABLE komentar ENGINE = InnoDB');
    }

    // detect primary key column and type for users table
    const [usersCols] = await dbPromise.execute(
      `SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?`,
      ['users']
    );
    const usersPk = usersCols.find(c => c.COLUMN_KEY === 'PRI');
    if (!usersPk) {
      console.error('users table has no primary key column. Cannot create foreign key reference.');
      process.exit(1);
    }

    // detect primary key column and type for komentar table
    const [komentarCols] = await dbPromise.execute(
      `SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?`,
      ['komentar']
    );
    const komentarPk = komentarCols.find(c => c.COLUMN_KEY === 'PRI');
    if (!komentarPk) {
      console.error('komentar table has no primary key column. Cannot create foreign key reference.');
      process.exit(1);
    }

    const usersPkName = usersPk.COLUMN_NAME;
    const komentarPkName = komentarPk.COLUMN_NAME;
    console.log('Detected users PK:', usersPkName, usersPk.COLUMN_TYPE, 'komentar PK:', komentarPkName, komentarPk.COLUMN_TYPE);

    // Determine unsigned/signed for FK columns to match referenced columns
    const usersUnsigned = /unsigned/i.test(usersPk.COLUMN_TYPE);
    const komentarUnsigned = /unsigned/i.test(komentarPk.COLUMN_TYPE);

    const idPengirimType = usersUnsigned ? 'INT UNSIGNED' : 'INT';
    const idKomentarType = komentarUnsigned ? 'INT UNSIGNED' : 'INT';

    // create reply table with indexes then foreign keys
    const createSql = `
      CREATE TABLE IF NOT EXISTS reply (
        idReply INT AUTO_INCREMENT PRIMARY KEY,
        sentDate DATETIME NOT NULL,
        isi TEXT NOT NULL,
        idPengirim ${idPengirimType} NULL,
        idKomentar ${idKomentarType} NOT NULL,
        INDEX idx_reply_idPengirim (idPengirim),
        INDEX idx_reply_idKomentar (idKomentar),
        CONSTRAINT fk_reply_pengirim FOREIGN KEY (idPengirim) REFERENCES users(${usersPkName}) ON DELETE SET NULL ON UPDATE CASCADE,
        CONSTRAINT fk_reply_komentar FOREIGN KEY (idKomentar) REFERENCES komentar(${komentarPkName}) ON DELETE CASCADE ON UPDATE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `;

    console.log('Creating table `reply` (if not exists)...');
    await dbPromise.execute(createSql);

    // Ensure parentReplyId exists and has FK to reply(idReply)
    try {
      const [cols] = await dbPromise.execute(
        `SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'reply' AND COLUMN_NAME = 'parentReplyId'`
      );
      if (!cols.length) {
        console.log('Altering `reply` table to add `parentReplyId` column...');
        await dbPromise.execute('ALTER TABLE reply ADD COLUMN parentReplyId INT NULL AFTER idKomentar');
      }
      // try to add FK if not present
      const [fks] = await dbPromise.execute(
        `SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'reply' AND COLUMN_NAME = 'parentReplyId' AND REFERENCED_TABLE_NAME = 'reply'`
      );
      if (!fks.length) {
        try {
          await dbPromise.execute('ALTER TABLE reply ADD CONSTRAINT fk_reply_parent FOREIGN KEY (parentReplyId) REFERENCES reply(idReply) ON DELETE SET NULL ON UPDATE CASCADE');
        } catch (e) {
          console.log('Could not add FK fk_reply_parent (maybe already exists or permissions):', e.message || e);
        }
      }
    } catch (e) {
      console.warn('Failed ensuring parentReplyId column/fk:', e.message || e);
    }

    console.log('Migration completed successfully. `reply` table exists with foreign keys.');
    process.exit(0);
  } catch (err) {
    console.error('Migration failed:', err);
    process.exit(2);
  }
}

run();
