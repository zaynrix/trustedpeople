import 'dart:convert';
import 'dart:html' as html;

class ExportUtils {
  // Export data to CSV file
  static void downloadCsv(String csvContent, String fileName) {
    // Create a Blob with the CSV content
    final blob = html.Blob([csvContent], 'text/csv;charset=utf-8');

    // Create a download URL for the Blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create a link element
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '$fileName.csv')
      ..style.display = 'none';

    // Add to document body
    html.document.body?.children.add(anchor);

    // Trigger the download
    anchor.click();

    // Clean up
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  // Export data to Excel file
  // In a real app, you would use a package like excel to create an Excel file
  static void downloadExcel(String content, String fileName) {
    // Create a Blob with the Excel content (similar to CSV for demo purposes)
    final blob = html.Blob([content], 'application/vnd.ms-excel');

    // Create a download URL for the Blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create a link element
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '$fileName.xlsx')
      ..style.display = 'none';

    // Add to document body
    html.document.body?.children.add(anchor);

    // Trigger the download
    anchor.click();

    // Clean up
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}