Steps to use:
1. Install the ReportGenerator Package
2. Place the GenerateCoverageReports.ps1 file in your solution folder.
3. Open PowerShell and run this command:
   Make sure to change the ReportGeneratorPath value to wherever your ReportGenerator.dll file is located. The path may vary depending on your machine.

    powershell -ExecutionPolicy Bypass -File GenerateCoverageReports.ps1 -ReportGeneratorPath "[C:\Path\To\ReportGenerator.dll]"
4. After the script finishes running, it will automatically open the coverage report in your browser.
