using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Cms.Models
{
    public class ImportModel
    {
        public HttpPostedFileBase File { get; set; }
        public bool Presta { get; set; }
    }
}