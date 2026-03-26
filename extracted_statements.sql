-- ============================================================================
-- Extracted SQL Statements Catalog
-- Source: DocumentProcessor application (EF Core generated SQL equivalents)
-- Original Database: Microsoft SQL Server (DPS database, dbo schema)
-- ============================================================================

-- Statement 1: CREATE TABLE (Program.cs - Database.EnsureCreatedAsync)
-- Source: sourceCode/src/DocumentProcessor.Web/Program.cs line ~69
CREATE TABLE [dbo].[Documents] (
    [Id] UNIQUEIDENTIFIER NOT NULL,
    [FileName] NVARCHAR(MAX) NOT NULL,
    [OriginalFileName] NVARCHAR(MAX) NOT NULL,
    [FileExtension] NVARCHAR(MAX) NOT NULL,
    [FileSize] BIGINT NOT NULL,
    [ContentType] NVARCHAR(MAX) NOT NULL,
    [StoragePath] NVARCHAR(MAX) NOT NULL,
    [Status] INT NOT NULL,
    [Summary] NVARCHAR(MAX) NULL,
    [UploadedBy] NVARCHAR(MAX) NOT NULL,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    CONSTRAINT [PK_Documents] PRIMARY KEY ([Id])
);

-- Statement 2: SELECT with WHERE + TOP (Home.razor - LoadDocuments)
-- Source: sourceCode/src/DocumentProcessor.Web/Components/Pages/Home.razor line ~208
-- EF Core LINQ: DB.Documents.Where(d => !d.IsDeleted).Take(50).ToListAsync()
SELECT TOP 50 [d].[Id], [d].[FileName], [d].[OriginalFileName], [d].[FileExtension],
    [d].[FileSize], [d].[ContentType], [d].[StoragePath], [d].[Status], [d].[Summary],
    [d].[UploadedBy], [d].[IsDeleted]
FROM [dbo].[Documents] AS [d]
WHERE [d].[IsDeleted] = 0;

-- Statement 3: INSERT (Home.razor - UploadFiles)
-- Source: sourceCode/src/DocumentProcessor.Web/Components/Pages/Home.razor line ~244-246
-- EF Core LINQ: DB.Documents.AddAsync(doc) + DB.SaveChangesAsync()
INSERT INTO [dbo].[Documents] ([Id], [FileName], [OriginalFileName], [FileExtension],
    [FileSize], [ContentType], [StoragePath], [Status], [Summary], [UploadedBy], [IsDeleted])
VALUES (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10);

-- Statement 4: DELETE (Home.razor - DeleteDoc)
-- Source: sourceCode/src/DocumentProcessor.Web/Components/Pages/Home.razor line ~264-265
-- EF Core LINQ: DB.Documents.Remove(_deleteDoc) + DB.SaveChangesAsync()
DELETE FROM [dbo].[Documents] WHERE [Id] = @p0;

-- Statement 5: SELECT by Primary Key (DocumentProcessingService.cs - FindAsync)
-- Source: sourceCode/src/DocumentProcessor.Web/Services/DocumentProcessingService.cs line ~18
-- EF Core LINQ: db.Documents.FindAsync(documentId)
SELECT [d].[Id], [d].[FileName], [d].[OriginalFileName], [d].[FileExtension],
    [d].[FileSize], [d].[ContentType], [d].[StoragePath], [d].[Status], [d].[Summary],
    [d].[UploadedBy], [d].[IsDeleted]
FROM [dbo].[Documents] AS [d]
WHERE [d].[Id] = @p0;

-- Statement 6: UPDATE Status to Processing (DocumentProcessingService.cs)
-- Source: sourceCode/src/DocumentProcessor.Web/Services/DocumentProcessingService.cs line ~23-24
-- EF Core: doc.Status = DocumentStatus.Processing; db.SaveChangesAsync()
UPDATE [dbo].[Documents] SET [Status] = @p0 WHERE [Id] = @p1;

-- Statement 7: UPDATE Status + Summary (DocumentProcessingService.cs)
-- Source: sourceCode/src/DocumentProcessor.Web/Services/DocumentProcessingService.cs line ~30-32
-- EF Core: doc.Status = DocumentStatus.Processed; doc.Summary = summary; db.SaveChangesAsync()
UPDATE [dbo].[Documents] SET [Status] = @p0, [Summary] = @p1 WHERE [Id] = @p2;

-- Statement 8: UPDATE Status to Failed (DocumentProcessingService.cs)
-- Source: sourceCode/src/DocumentProcessor.Web/Services/DocumentProcessingService.cs line ~36-37
-- EF Core: doc.Status = DocumentStatus.Failed; db.SaveChangesAsync()
UPDATE [dbo].[Documents] SET [Status] = @p0 WHERE [Id] = @p1;
