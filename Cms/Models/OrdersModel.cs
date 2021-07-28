using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Cms.Models
{
    public class OrdersModel
    {
        public int Id { get; set; }
        public string Ordernumber { get; set; }
        public string Name { get; set; }
        public string Surname { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public string Zip { get; set; }
        public string Country { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string Companyname { get; set; }
        public string Ico { get; set; }
        public string Dic { get; set; }
        public string Icdph { get; set; }
        public string Date { get; set; }
        public string Payment { get; set; }
        public string Shipping { get; set; }
        public int Status { get; set; }
        public string Finalprice { get; set; }
        public string Baseprice { get; set; }
        public string Billnumber { get; set; }
        public string NameShipp { get; set; }
        public string SurnameShipp { get; set; }
        public string AddressShipp { get; set; }
        public string CompanynameShipp { get; set; }
        public string CityShipp { get; set; }
        public string ZipShipp { get; set; }
        public string CountryShipp { get; set; }
        public string PhoneShipp { get; set; }
        public string Comment { get; set; }
        public string Note { get; set; }
        public string UsedCoupon { get; set; }
        public int UserRating { get; set; }
    }
}