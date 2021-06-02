using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Cms.Models
{
    public class EsettingsModel
    {
        public int Id { get; set; }
        public string Companyname { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string Ico { get; set; }
        public string Dic { get; set; }
        public string Icdph { get; set; }
        public string Accountnumber { get; set; }
        public string Transfer1 { get; set; }
        public string Transfer2 { get; set; }
        public string Transfer3 { get; set; }
        public string Transfer4 { get; set; }
        public string Transfer5 { get; set; }
        public string Pay1 { get; set; }
        public bool Pay1Enbl { get; set; }
        public string Pay2 { get; set; }
        public bool Pay2Enbl { get; set; }
        public string Pay3 { get; set; }
        public bool Pay3Enbl { get; set; }
        public string Pay4 { get; set; }
        public bool Pay4Enbl { get; set; }
        public bool Transfer1Enbl { get; set; }
        public bool Transfer2Enbl { get; set; }
        public bool Transfer3Enbl { get; set; }
        public bool Transfer4Enbl { get; set; }
        public string Custom { get; set; }
        public string DeliveryPrice1 { get; set; }
        public string DeliveryPrice2 { get; set; }
        public string DeliveryPrice3 { get; set; }
        public string VopPdf { get; set; }
        public string ReturnPdf { get; set; }
        public string CancelPdf { get; set; }
        public HttpPostedFileBase[] VopPdfImage { get; set; }
        public HttpPostedFileBase[] ReturnPdfImage { get; set; }
        public HttpPostedFileBase[] CancelPdfImage { get; set; }
    }
}