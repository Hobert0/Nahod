using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Cms.Models
{
    public class EmailSendModel
    {
        public string Name { get; set; }
        public string Email { get; set; }
        public string Subject { get; set; }
        [AllowHtml]
        public string Message { get; set; }
    }
}