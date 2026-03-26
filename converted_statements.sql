-- ============================================================================
-- Converted SQL Statements Catalog
-- Target: PostgreSQL (postgres database, dps_dbo schema)
-- Conversion Method: DMS_FAILURE_MANUAL_CONVERSION_WITH_LOWERCASE_SCHEMA
-- Note: All 8 statements were passed through DMS MCP tool first.
--       DMS returned converted_sql_count=0 for all statements with message:
--       "No converted SQL found in target metadata models"
--       Manual conversion applied with lowercase schema object names per TD rules.
-- ============================================================================

-- Statement 1: CREATE TABLE (Program.cs - Database.EnsureCreatedAsync)
-- Conversion: DMS_FAILURE_MANUAL_CONVERSION_WITH_LOWERCASE_SCHEMA
CREATE TABLE IF NOT EXISTS dps_dbo.documents (
    id UUID NOT NULL,
    filename TEXT NOT NULL,
    originalfilename TEXT NOT NULL,
    fileextension TEXT NOT NULL,
    filesize BIGINT NOT NULL,
    contenttype TEXT NOT NULL,
    storagepath TEXT NOT NULL,
    status INTEGER NOT NULL,
    summary TEXT NULL,
    uploadedby TEXT NOT NULL,
    isdeleted INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT pk_documents PRIMARY KEY (id)
);

-- Statement 2: SELECT with WHERE + LIMIT (Home.razor - LoadDocuments)
-- Conversion: DMS_FAILURE_MANUAL_CONVERSION_WITH_LOWERCASE_SCHEMA
-- Changed: TOP 50 -> LIMIT 50, schema dbo->dps_dbo, column/table names lowercase
SELECT d.id, d.filename, d.originalfilename, d.fileextension,
    d.filesize, d.contenttype, d.storagepath, d.status, d.summary,
    d.uploadedby, d.isdeleted
FROM dps_dbo.documents AS d
WHERE d.isdeleted = 0
LIMIT 50;

-- Statement 3: INSERT (Home.razor - UploadFiles)
-- Conversion: DMS_FAILURE_MANUAL_CONVERSION_WITH_LOWERCASE_SCHEMA
INSERT INTO dps_dbo.documents (id, filename, originalfilename, fileextension,
    filesize, contenttype, storagepath, status, summary, uploadedby, isdeleted)
VALUES (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10);

-- Statement 4: DELETE (Home.razor - DeleteDoc)
-- Conversion: DMS_FAILURE_MANUAL_CONVERSION_WITH_LOWERCASE_SCHEMA
DELETE FROM dps_dbo.documents WHERE id = @p0;

-- Statement 5: SELECT by Primary Key (DocumentProcessingService.cs - FindAsync)
-- Conversion: DMS_FAILURE_MANUAL_CONVERSION_WITH_LOWERCASE_SCHEMA
SELECT d.id, d.filename, d.originalfilename, d.fileextension,
    d.filesize, d.contenttype, d.storagepath, d.status, d.summary,
    d.uploadedby, d.isdeleted
FROM dps_dbo.documents AS d
WHERE d.id = @p0;

-- Statement 6: UPDATE Status to Processing (DocumentProcessingService.cs)
-- Conversion: DMS_FAILURE_MANUAL_CONVERSION_WITH_LOWERCASE_SCHEMA
UPDATE dps_dbo.documents SET status = @p0 WHERE id = @p1;

-- Statement 7: UPDATE Status + Summary (DocumentProcessingService.cs)
-- Conversion: DMS_FAILURE_MANUAL_CONVERSION_WITH_LOWERCASE_SCHEMA
UPDATE dps_dbo.documents SET status = @p0, summary = @p1 WHERE id = @p2;

-- Statement 8: UPDATE Status to Failed (DocumentProcessingService.cs)
-- Conversion: DMS_FAILURE_MANUAL_CONVERSION_WITH_LOWERCASE_SCHEMA
UPDATE dps_dbo.documents SET status = @p0 WHERE id = @p1;
