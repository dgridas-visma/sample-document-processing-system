# Migration Report: Microsoft SQL Server to PostgreSQL

## Document Processor Application

**Migration Date:** 2026-03-26  
**Source Database:** Microsoft SQL Server 2019 (DPS database, dbo schema)  
**Target Database:** Amazon Aurora PostgreSQL 13 (postgres database, dps_dbo schema)  
**Application Framework:** .NET 8.0, Entity Framework Core 8.0, Blazor Server  
**DMS Migration Project ARN:** arn:aws:dms:us-east-1:210357578870:migration-project:TFS4RBF33NHPHKKUSK3U3RBZKE

---

## Executive Summary

This report documents the migration of the DocumentProcessor web application from Microsoft SQL Server to PostgreSQL. The application uses Entity Framework Core exclusively for database operations (no raw/inline SQL), which means SQL statements are generated at runtime by the EF Core provider. All 8 identified SQL statement patterns were processed through the DMS MCP tool and validated through the SQL Equivalency MCP tool as required by the transformation definition.

---

## SQL Statement Processing Summary

| Metric | Count |
|--------|-------|
| **Total SQL statements processed** | 8 |
| **Statements successfully converted by DMS MCP tool** | 0 |
| **Statements requiring manual intervention after DMS tool** | 8 |
| **Statements validated as equivalent** | 0 |
| **Statements validated as non-equivalent** | 0 |
| **Statements with equivalency validation errors** | 8 |

---

## DMS Tool Conversion Details

All 8 SQL statements were passed through the DMS MCP tool (`dms-mcp___statement_conversion_tool`) with the following parameters:
- **Migration Project Identifier:** `arn:aws:dms:us-east-1:210357578870:migration-project:TFS4RBF33NHPHKKUSK3U3RBZKE`
- **Schema Name:** `dbo`
- **Database Name:** `DPS` (auto-resolved)
- **Region:** `us-east-1`

**Result:** All 8 statements completed the DMS workflow (create_metadata_model → convert_metadata_model → extract_converted_sql) but returned `converted_sql_count: 0` with message: "No converted SQL found in target metadata models".

**Manual Conversion Applied:** Since DMS failed to provide converted SQL, manual conversion was applied using `DMS_FAILURE_MANUAL_CONVERSION_WITH_LOWERCASE_SCHEMA` as specified in the transformation definition. The following schema mapping rules were applied:
- Schema: `[dbo]` → `dps_dbo`
- Table: `[Documents]` → `documents`
- All column names: PascalCase → lowercase (e.g., `[FileName]` → `filename`)
- `SELECT TOP N` → `LIMIT N`
- `UNIQUEIDENTIFIER` → `UUID`
- `NVARCHAR(MAX)` → `TEXT`
- `BIT` → `INTEGER`

---

## SQL Equivalency Validation Details

All 8 statement pairs were validated through the SQL Equivalency MCP tool (`sql-equivalency___validate_sql_equivalence`).

**Result:** All 8 validations returned `ERROR` with error message `'uniqueID'`. This appears to be a systemic issue with the equivalency tool rather than a problem with the converted statements. Per the transformation definition: "If sql-equivalency___validate_sql_equivalence returns an error, mark the equivalency status as ERROR."

---

## Detailed Statement Listing

### Statement 1: CREATE TABLE
- **Source:** Program.cs (Database.EnsureCreatedAsync)
- **Original (MS SQL):**
  ```sql
  CREATE TABLE [dbo].[Documents] ([Id] UNIQUEIDENTIFIER NOT NULL, [FileName] NVARCHAR(MAX) NOT NULL, ...)
  ```
- **Converted (PostgreSQL):**
  ```sql
  CREATE TABLE IF NOT EXISTS dps_dbo.documents (id UUID NOT NULL, filename TEXT NOT NULL, ...)
  ```
- **DMS Status:** Failed (converted_sql_count=0)
- **Equivalency Status:** ERROR ('uniqueID')

### Statement 2: SELECT with WHERE + TOP/LIMIT
- **Source:** Home.razor (LoadDocuments - `DB.Documents.Where(d => !d.IsDeleted).Take(50).ToListAsync()`)
- **Original (MS SQL):**
  ```sql
  SELECT TOP 50 [d].[Id], ... FROM [dbo].[Documents] AS [d] WHERE [d].[IsDeleted] = 0;
  ```
- **Converted (PostgreSQL):**
  ```sql
  SELECT d.id, ... FROM dps_dbo.documents AS d WHERE d.isdeleted = 0 LIMIT 50;
  ```
- **DMS Status:** Failed (converted_sql_count=0)
- **Equivalency Status:** ERROR ('uniqueID')

### Statement 3: INSERT
- **Source:** Home.razor (UploadFiles - `DB.Documents.AddAsync(doc)` + `DB.SaveChangesAsync()`)
- **Original (MS SQL):**
  ```sql
  INSERT INTO [dbo].[Documents] ([Id], [FileName], ...) VALUES (@p0, @p1, ...);
  ```
- **Converted (PostgreSQL):**
  ```sql
  INSERT INTO dps_dbo.documents (id, filename, ...) VALUES (@p0, @p1, ...);
  ```
- **DMS Status:** Failed (converted_sql_count=0)
- **Equivalency Status:** ERROR ('uniqueID')

### Statement 4: DELETE
- **Source:** Home.razor (DeleteDoc - `DB.Documents.Remove(_deleteDoc)` + `DB.SaveChangesAsync()`)
- **Original (MS SQL):**
  ```sql
  DELETE FROM [dbo].[Documents] WHERE [Id] = @p0;
  ```
- **Converted (PostgreSQL):**
  ```sql
  DELETE FROM dps_dbo.documents WHERE id = @p0;
  ```
- **DMS Status:** Failed (converted_sql_count=0)
- **Equivalency Status:** ERROR ('uniqueID')

### Statement 5: SELECT by Primary Key
- **Source:** DocumentProcessingService.cs (FindAsync - `db.Documents.FindAsync(documentId)`)
- **Original (MS SQL):**
  ```sql
  SELECT [d].[Id], ... FROM [dbo].[Documents] AS [d] WHERE [d].[Id] = @p0;
  ```
- **Converted (PostgreSQL):**
  ```sql
  SELECT d.id, ... FROM dps_dbo.documents AS d WHERE d.id = @p0;
  ```
- **DMS Status:** Failed (converted_sql_count=0)
- **Equivalency Status:** ERROR ('uniqueID')

### Statement 6: UPDATE Status (to Processing)
- **Source:** DocumentProcessingService.cs (`doc.Status = DocumentStatus.Processing; db.SaveChangesAsync()`)
- **Original (MS SQL):**
  ```sql
  UPDATE [dbo].[Documents] SET [Status] = @p0 WHERE [Id] = @p1;
  ```
- **Converted (PostgreSQL):**
  ```sql
  UPDATE dps_dbo.documents SET status = @p0 WHERE id = @p1;
  ```
- **DMS Status:** Failed (converted_sql_count=0)
- **Equivalency Status:** ERROR ('uniqueID')

### Statement 7: UPDATE Status + Summary (to Processed)
- **Source:** DocumentProcessingService.cs (`doc.Status = DocumentStatus.Processed; doc.Summary = summary; db.SaveChangesAsync()`)
- **Original (MS SQL):**
  ```sql
  UPDATE [dbo].[Documents] SET [Status] = @p0, [Summary] = @p1 WHERE [Id] = @p2;
  ```
- **Converted (PostgreSQL):**
  ```sql
  UPDATE dps_dbo.documents SET status = @p0, summary = @p1 WHERE id = @p2;
  ```
- **DMS Status:** Failed (converted_sql_count=0)
- **Equivalency Status:** ERROR ('uniqueID')

### Statement 8: UPDATE Status (to Failed)
- **Source:** DocumentProcessingService.cs (`doc.Status = DocumentStatus.Failed; db.SaveChangesAsync()`)
- **Original (MS SQL):**
  ```sql
  UPDATE [dbo].[Documents] SET [Status] = @p0 WHERE [Id] = @p1;
  ```
- **Converted (PostgreSQL):**
  ```sql
  UPDATE dps_dbo.documents SET status = @p0 WHERE id = @p1;
  ```
- **DMS Status:** Failed (converted_sql_count=0)
- **Equivalency Status:** ERROR ('uniqueID')

---

## Code Changes Summary

### 1. Connection String Updates (Program.cs)

| Path | Change | Status |
|------|--------|--------|
| Primary connection (Secrets Manager - target) | Already PostgreSQL format (`Host={host};Port={port};...`) | No change needed ✓ |
| Fallback connection (Secrets Manager - MSSQL) | Changed from `Server={host},{port};...` to `Host={host};Port={port};...` | Updated ✓ |
| Final fallback (local) | Changed from `Server=localhost;...` to `Host=localhost;Port=5432;...` | Updated ✓ |
| DatabaseType labels | Changed "SQL Server" → "PostgreSQL" and "SQL Server (Local)" → "PostgreSQL (Local)" | Updated ✓ |

### 2. Package Dependency Status

| Package | Status |
|---------|--------|
| `Npgsql.EntityFrameworkCore.PostgreSQL 8.0.0` | Already present ✓ |
| `Microsoft.Data.SqlClient` | Not present (not needed) ✓ |
| `Microsoft.EntityFrameworkCore.SqlServer` | Not present (not needed) ✓ |
| `System.Data.SqlClient` | Not present (not needed) ✓ |

### 3. ADO.NET Class Replacement Status

**Not applicable.** This application uses Entity Framework Core exclusively via `Microsoft.EntityFrameworkCore` and `Npgsql.EntityFrameworkCore.PostgreSQL`. There are no direct ADO.NET class usages (`SqlConnection`, `SqlCommand`, `SqlDataReader`, `SqlParameter`) in the codebase.

### 4. EF Core Model Configuration

| Component | Status |
|-----------|--------|
| AppDbContext.cs | Already configured for PostgreSQL with `dps_dbo` schema and lowercase column mappings ✓ |
| Document.cs (Model) | Already has `[Table("documents", Schema = "dps_dbo")]` and lowercase `[Column]` attributes ✓ |
| DbContext registration | Already uses `o.UseNpgsql(connectionString)` ✓ |

### 5. Configuration Files

| File | Status |
|------|--------|
| appsettings.json | Already uses PostgreSQL connection string format ✓ |
| appsettings.Development.json | Already uses PostgreSQL connection string format ✓ |

---

## Build Validation

**Final Build Status:** ✅ SUCCESS  
**Warnings:** 1 (pre-existing CS0414 - unused field `_isDragOver` in Home.razor, not migration-related)  
**Errors:** 0

---

## Transformation Artifacts

| Artifact | Location | Description |
|----------|----------|-------------|
| `extracted_statements.sql` | sourceCode/ | Complete catalog of all 8 original MS SQL Server statements |
| `converted_statements.sql` | sourceCode/ | Complete catalog of all 8 converted PostgreSQL statements |
| `sql_equivalency_validation_report.json` | sourceCode/ | Comprehensive JSON report with all statement details, DMS results, and equivalency validation results |
| `migration_report.md` | sourceCode/ | This comprehensive migration report |

---

## Notes and Recommendations

1. **EF Core Handles SQL Generation:** Since this application uses EF Core exclusively, the actual SQL statements are generated at runtime by the Npgsql EF Core provider. The SQL statements documented here represent the EF Core LINQ-to-SQL translations and were processed through the DMS and equivalency tools as required.

2. **Schema Mapping:** The DMS schema mapping confirmed that `dbo.Documents` (SQL Server) maps to `documents` (PostgreSQL) in the target. The AppDbContext.cs already configures this mapping to `dps_dbo.documents` with lowercase column names.

3. **DMS Tool Limitations:** The DMS tool completed all workflow steps successfully but returned no converted SQL output for any of the 8 statements. This may be because DMS is optimized for stored procedures, functions, and complex T-SQL rather than simple DML statements.

4. **Equivalency Tool Error:** The SQL Equivalency tool returned a consistent `'uniqueID'` error across all 8 statement pairs, including a test with completely unrelated tables. This appears to be a systemic tool issue. All statements are marked as ERROR as required by the transformation definition.

5. **All connection string paths now use PostgreSQL format**, ensuring consistent behavior regardless of which secret retrieval path is taken.
