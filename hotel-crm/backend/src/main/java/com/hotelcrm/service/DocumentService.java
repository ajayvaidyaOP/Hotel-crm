package com.hotelcrm.service;

import com.hotelcrm.domain.entity.Invoice;
import com.hotelcrm.domain.entity.InvoiceLine;
import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.time.format.DateTimeFormatter;
import java.util.List;

/** Server side document rendering: PDF invoices / reports and Excel exports. */
@Service
public class DocumentService {

    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd MMM yyyy");
    private static final Color NAVY = new Color(15, 32, 62);
    private static final Color LIGHT = new Color(238, 242, 249);

    public byte[] invoicePdf(Invoice invoice) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4, 42, 42, 42, 42);
        try {
            PdfWriter.getInstance(document, out);
            document.open();

            Font titleFont = new Font(Font.HELVETICA, 18, Font.BOLD, NAVY);
            Font subFont = new Font(Font.HELVETICA, 9, Font.NORMAL, Color.DARK_GRAY);
            Font bold = new Font(Font.HELVETICA, 9, Font.BOLD, Color.BLACK);
            Font normal = new Font(Font.HELVETICA, 9, Font.NORMAL, Color.BLACK);

            Paragraph hotel = new Paragraph(invoice.getHotel().getName(), titleFont);
            hotel.setAlignment(Element.ALIGN_LEFT);
            document.add(hotel);

            StringBuilder address = new StringBuilder();
            if (invoice.getHotel().getAddress() != null) {
                address.append(invoice.getHotel().getAddress());
            }
            if (invoice.getHotel().getCity() != null) {
                address.append(", ").append(invoice.getHotel().getCity());
            }
            if (invoice.getHotel().getState() != null) {
                address.append(", ").append(invoice.getHotel().getState());
            }
            if (address.length() > 0) {
                document.add(new Paragraph(address.toString(), subFont));
            }
            if (invoice.getHotel().getContactNumber() != null) {
                document.add(new Paragraph("Phone: " + invoice.getHotel().getContactNumber()
                        + (invoice.getHotel().getEmail() == null ? "" : "  |  " + invoice.getHotel().getEmail()), subFont));
            }
            if (invoice.getGstin() != null) {
                document.add(new Paragraph("GSTIN: " + invoice.getGstin(), subFont));
            }

            Paragraph spacer = new Paragraph(" ");
            document.add(spacer);

            PdfPTable header = new PdfPTable(new float[]{1.6f, 1f});
            header.setWidthPercentage(100);
            header.addCell(labelCell("TAX INVOICE", new Font(Font.HELVETICA, 13, Font.BOLD, NAVY), false));
            header.addCell(labelCell("Invoice No: " + invoice.getInvoiceNumber(), bold, true));
            header.addCell(labelCell("", normal, false));
            header.addCell(labelCell("Date: " + invoice.getIssueDate().format(DATE), normal, true));
            document.add(header);

            document.add(new Paragraph(" "));
            PdfPTable parties = new PdfPTable(new float[]{1f, 1f});
            parties.setWidthPercentage(100);
            parties.addCell(cell("Billed to", bold));
            parties.addCell(cell("Stay details", bold));
            parties.addCell(cell(buildText(invoice.getBillToName(),
                    invoice.getBillToAddress(),
                    invoice.getGuest() == null ? null : invoice.getGuest().getMobile(),
                    invoice.getGuest() == null ? null : invoice.getGuest().getEmail()), normal));
            String stay = invoice.getBooking() == null ? "-"
                    : "Booking " + invoice.getBooking().getBookingCode() + "\n"
                    + "Check-in: " + invoice.getBooking().getCheckInDate().format(DATE) + "\n"
                    + "Check-out: " + invoice.getBooking().getCheckOutDate().format(DATE);
            parties.addCell(cell(stay, normal));
            document.add(parties);

            document.add(new Paragraph(" "));
            PdfPTable table = new PdfPTable(new float[]{0.6f, 3.4f, 0.8f, 1.1f, 1.2f});
            table.setWidthPercentage(100);
            addTableHeader(table, bold, "S.No", "Description", "Qty", "Rate", "Amount");
            int index = 1;
            for (InvoiceLine line : invoice.getLines()) {
                addTableRow(table, normal, false, String.valueOf(index++), line.getDescription(),
                        trim(line.getQuantity()), trim(line.getUnitPrice()), trim(line.getAmount()));
            }
            if (invoice.getDiscount().compareTo(BigDecimal.ZERO) > 0) {
                addTableRow(table, normal, false, "", "Discount applied", "", "", "-" + trim(invoice.getDiscount()));
            }
            document.add(table);

            document.add(new Paragraph(" "));
            PdfPTable totals = new PdfPTable(new float[]{3.4f, 1.2f});
            totals.setWidthPercentage(45);
            totals.setHorizontalAlignment(Element.ALIGN_RIGHT);
            addTotalRow(totals, normal, "Subtotal", trim(invoice.getSubtotal()));
            addTotalRow(totals, normal, "Discount", "-" + trim(invoice.getDiscount()));
            addTotalRow(totals, normal, "GST @ " + trim(invoice.getTaxRate()) + "%", trim(invoice.getTaxAmount()));
            addTotalRow(totals, bold, "Total payable", "INR " + trim(invoice.getTotal()));
            addTotalRow(totals, normal, "Amount paid", trim(invoice.getAmountPaid()));
            addTotalRow(totals, bold, "Balance due", "INR " + trim(invoice.getBalance()));
            document.add(totals);

            document.add(new Paragraph(" "));
            document.add(new Paragraph("This is a computer generated invoice. "
                    + "Thank you for choosing " + invoice.getHotel().getName() + ".", subFont));
            if (invoice.getNotes() != null && !invoice.getNotes().isBlank()) {
                document.add(new Paragraph("Notes: " + invoice.getNotes(), subFont));
            }
            document.close();
            return out.toByteArray();
        } catch (Exception ex) {
            throw new IllegalStateException("Unable to render invoice PDF", ex);
        }
    }

    public byte[] reportPdf(String title, String subtitle, List<String> headers, List<List<String>> rows) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4.rotate(), 32, 32, 32, 32);
        try {
            PdfWriter.getInstance(document, out);
            document.open();
            document.add(new Paragraph(title, new Font(Font.HELVETICA, 16, Font.BOLD, NAVY)));
            document.add(new Paragraph(subtitle, new Font(Font.HELVETICA, 9, Font.NORMAL, Color.DARK_GRAY)));
            document.add(new Paragraph(" "));
            PdfPTable table = new PdfPTable(headers.size());
            table.setWidthPercentage(100);
            Font bold = new Font(Font.HELVETICA, 8, Font.BOLD, Color.WHITE);
            Font normal = new Font(Font.HELVETICA, 8, Font.NORMAL, Color.BLACK);
            for (String header : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(header, bold));
                cell.setBackgroundColor(NAVY);
                cell.setPadding(5);
                table.addCell(cell);
            }
            for (List<String> row : rows) {
                for (String value : row) {
                    PdfPCell cell = new PdfPCell(new Phrase(value == null ? "" : value, normal));
                    cell.setPadding(4);
                    table.addCell(cell);
                }
            }
            document.add(table);
            document.close();
            return out.toByteArray();
        } catch (Exception ex) {
            throw new IllegalStateException("Unable to render report PDF", ex);
        }
    }

    public byte[] excel(String sheetName, List<String> headers, List<List<String>> rows) {
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet(sheetName.length() > 30 ? sheetName.substring(0, 30) : sheetName);
            CellStyle headerStyle = workbook.createCellStyle();
            org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < headers.size(); i++) {
                org.apache.poi.ss.usermodel.Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers.get(i));
                cell.setCellStyle(headerStyle);
            }
            int rowIndex = 1;
            for (List<String> row : rows) {
                Row dataRow = sheet.createRow(rowIndex++);
                for (int i = 0; i < row.size(); i++) {
                    dataRow.createCell(i).setCellValue(row.get(i) == null ? "" : row.get(i));
                }
            }
            for (int i = 0; i < headers.size(); i++) {
                sheet.autoSizeColumn(i);
            }
            workbook.write(out);
            return out.toByteArray();
        } catch (Exception ex) {
            throw new IllegalStateException("Unable to render Excel export", ex);
        }
    }

    public byte[] csv(List<String> headers, List<List<String>> rows) {
        StringBuilder sb = new StringBuilder();
        sb.append('\uFEFF');
        sb.append(String.join(",", headers.stream().map(this::escape).toList())).append("\r\n");
        for (List<String> row : rows) {
            sb.append(String.join(",", row.stream().map(this::escape).toList())).append("\r\n");
        }
        return sb.toString().getBytes(StandardCharsets.UTF_8);
    }

    private String escape(String value) {
        String safe = value == null ? "" : value;
        if (safe.contains(",") || safe.contains("\"") || safe.contains("\n")) {
            return '"' + safe.replace("\"", "\"\"") + '"';
        }
        return safe;
    }

    private void addTableHeader(PdfPTable table, Font font, String... labels) {
        for (String label : labels) {
            PdfPCell cell = new PdfPCell(new Phrase(label, new Font(Font.HELVETICA, 9, Font.BOLD, Color.WHITE)));
            cell.setBackgroundColor(NAVY);
            cell.setPadding(6);
            table.addCell(cell);
        }
    }

    private void addTableRow(PdfPTable table, Font font, boolean shaded, String... values) {
        for (String value : values) {
            PdfPCell cell = new PdfPCell(new Phrase(value == null ? "" : value, font));
            cell.setPadding(5);
            if (shaded) {
                cell.setBackgroundColor(LIGHT);
            }
            table.addCell(cell);
        }
    }

    private void addTotalRow(PdfPTable table, Font font, String label, String value) {
        PdfPCell left = new PdfPCell(new Phrase(label, font));
        left.setBorder(0);
        left.setPadding(4);
        PdfPCell right = new PdfPCell(new Phrase(value, font));
        right.setBorder(0);
        right.setPadding(4);
        right.setHorizontalAlignment(Element.ALIGN_RIGHT);
        table.addCell(left);
        table.addCell(right);
    }

    private PdfPCell cell(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text == null ? "" : text, font));
        cell.setPadding(6);
        cell.setBackgroundColor(LIGHT);
        cell.setBorder(0);
        return cell;
    }

    private PdfPCell labelCell(String text, Font font, boolean alignRight) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBorder(0);
        cell.setPadding(2);
        if (alignRight) {
            cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
        }
        return cell;
    }

    private String buildText(String... parts) {
        StringBuilder sb = new StringBuilder();
        for (String part : parts) {
            if (part != null && !part.isBlank()) {
                sb.append(sb.length() > 0 ? "\n" : "").append(part);
            }
        }
        return sb.toString();
    }

    private String trim(BigDecimal value) {
        return value == null ? "0.00" : value.setScale(2, java.math.RoundingMode.HALF_UP).toPlainString();
    }
}
