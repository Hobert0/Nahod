﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Cms.Models
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    
    public partial class Entities : DbContext
    {
        public Entities()
            : base("name=Entities")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public virtual DbSet<deliver_city> deliver_city { get; set; }
        public virtual DbSet<e_settings> e_settings { get; set; }
        public virtual DbSet<newsletter> newsletter { get; set; }
        public virtual DbSet<pages> pages { get; set; }
        public virtual DbSet<settings> settings { get; set; }
        public virtual DbSet<wishlist> wishlist { get; set; }
        public virtual DbSet<attributes> attributes { get; set; }
        public virtual DbSet<users> users { get; set; }
        public virtual DbSet<types> types { get; set; }
        public virtual DbSet<slideshow> slideshow { get; set; }
        public virtual DbSet<variants> variants { get; set; }
        public virtual DbSet<ordermeta> ordermeta { get; set; }
        public virtual DbSet<orders> orders { get; set; }
        public virtual DbSet<products> products { get; set; }
        public virtual DbSet<coupons> coupons { get; set; }
        public virtual DbSet<categories> categories { get; set; }
        public virtual DbSet<brands> brands { get; set; }
        public virtual DbSet<blog> blog { get; set; }
        public virtual DbSet<usersmeta> usersmeta { get; set; }
    }
}
