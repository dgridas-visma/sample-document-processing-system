# Next Steps

## Issues resolved
- Transformed DocumentProcessor.Web.csproj to net8.0

## Summary

The solution has no build errors following the transformation. All projects compiled successfully, which indicates the migration to cross-platform .NET has completed without introducing any compilation-level issues.

## Validation Steps

### 1. Review Target Framework

Open `src/DocumentProcessor.Web/DocumentProcessor.Web.csproj` and confirm the `<TargetFramework>` element is set to the intended .NET version (e.g., `net8.0`). Ensure no legacy `<TargetFrameworkVersion>` elements remain.

### 2. Restore and Build Locally

Run the following commands from the solution root to confirm a clean restore and build on your local machine:

```bash
dotnet restore
dotnet build --configuration Release
```

Verify that no warnings are promoted to errors and that all project references resolve correctly.

### 3. Run the Test Suite

If the solution contains test projects, execute them to confirm runtime behavior is consistent with the original application:

```bash
dotnet test --configuration Release --logger "console;verbosity=detailed"
```

Review any failing tests carefully, as they may indicate behavioral differences introduced by the framework change rather than test-specific issues.

### 4. Check Runtime Dependencies

- Confirm that any NuGet packages that were previously targeting `.NET Framework` have compatible `.NET` or `.NET Standard` versions in the migrated project files.
- Run `dotnet list package --outdated` to identify packages that may have newer, more compatible versions available.
- Check for any packages marked as deprecated or with known compatibility issues on the [NuGet compatibility matrix](https://learn.microsoft.com/en-us/dotnet/standard/net-standard).

### 5. Verify Configuration Files

- Ensure `Web.config` transformations have been replaced with `appsettings.json` and environment-specific variants (`appsettings.Development.json`, `appsettings.Production.json`).
- Confirm that connection strings, application settings, and any custom configuration sections have been correctly migrated to the new configuration system.

### 6. Test Application Startup

Run the web application locally and confirm it starts without errors:

```bash
dotnet run --project src/DocumentProcessor.Web/DocumentProcessor.Web.csproj --configuration Release
```

Check the console output for any startup exceptions, middleware configuration errors, or missing service registrations.

### 7. Validate HTTP Endpoints

Using a tool such as a browser, `curl`, or a REST client, exercise the primary routes and endpoints of the application to confirm responses are correct and no runtime exceptions occur.

### 8. Review Removed Windows-Specific APIs

Search the codebase for any usage of APIs that are Windows-specific and may not throw at compile time but will fail at runtime on non-Windows platforms:

```bash
grep -rn "Registry\|WindowsIdentity\|System.Drawing\|System.Web" src/
```

Address any findings by replacing them with cross-platform equivalents.

### 9. Deployment

Once local validation is complete, publish the application using:

```bash
dotnet publish src/DocumentProcessor.Web/DocumentProcessor.Web.csproj \
  --configuration Release \
  --output ./publish
```

Verify the contents of the `./publish` directory and deploy it to your target environment according to your existing hosting setup (IIS, self-hosted, Linux service, etc.).

For IIS hosting, ensure the **ASP.NET Core Hosting Bundle** is installed on the target server and that the application pool is configured to use **No Managed Code**.