declare @RegSrvr table (x int, id int, value varchar(max)) 
declare @ips table (groups varchar(1000), ip_address varchar(1000)) 
insert into @ips values  
('Prod','10.0.0.1,1433'),
('Prod','10.0.0.2,1433'),
('Prod','10.0.0.3,1433'),
('Prod','10.0.0.4,1433'),
('DR','172.0.0.1,1433'),
('DR','172.0.0.2,1433'),
('DR','172.0.0.3,1433'),
('DR','172.0.0.4,1433')



--insert into @ips --values  
--select --top 50 
--replace(replace(replace(replace(replace(replace(replace(APPNameChild,',',''),'-',''),'/',''),'+',''),'-',''),'&',''),'–',''),FULLSQLNAME,
--'('+''''+replace(replace(replace(replace(replace(APPNameChild,',',''),'-',''),'/',''),'+',''),'-','')+''''+','+''''+FULLSQLNAME+''''+'),'
--from ServerInfoDetails
--where len(APPNameChild) > 1
--and FULLSQLNAME is not null
--and APPNameChild != 'D2PBIDBSQRWV4'
--order by APPNameChild, FULLSQLNAME

declare @groups varchar(1000) 
declare group_cursor cursor fast_forward 
for 
select distinct groups 
from @ips 
 
declare @ip_cursor cursor  
 
declare ip_cursor cursor fast_forward 
for 
select groups, ip_address 
from @ips 
order by groups, ip_address 
 
declare 
@RegSrvr_part_1_no_change  varchar(max), 
@RegSrvr_part_2_no_change  varchar(max), 
@xml_reg_group     varchar(max), 
@xml_reg_servers_header   varchar(max), 
@xml_reg_servers_detail   varchar(max), 
@xml_reg_servers_header_open varchar(max), 
@xml_reg_servers_header_close varchar(max), 
@ip        varchar(0100), 
@group_scope     int, 
@x        int 
 
set @group_scope = 1 
set @RegSrvr_part_1_no_change = '<?xml version="1.0"?> 
<model xmlns="http://schemas.serviceml.org/smlif/2007/02"> 
  <identity> 
    <name>urn:uuid:96fe1236-abf6-4a57-b54d-e9baab394fd1</name> 
    <baseURI>http://documentcollection/</baseURI> 
  </identity> 
  <xs:bufferSchema xmlns:xs="http://www.w3.org/2001/XMLSchema"> 
    <definitions xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08"> 
      <document> 
        <docinfo> 
          <aliases> 
            <alias>/system/schema/RegisteredServers</alias> 
          </aliases> 
          <sfc:version DomainVersion="1" /> 
        </docinfo> 
        <data> 
          <xs:schema targetNamespace="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified"> 
            <xs:element name="RegisteredServersStore"> 
              <xs:complexType> 
                <xs:sequence> 
                  <xs:any namespace="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" processContents="skip" minOccurs="0" maxOccurs="unbounded" /> 
                </xs:sequence> 
              </xs:complexType> 
            </xs:element> 
            <xs:element name="ServerGroup"> 
              <xs:complexType> 
                <xs:sequence> 
                  <xs:any namespace="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" processContents="skip" minOccurs="0" maxOccurs="unbounded" /> 
                </xs:sequence> 
              </xs:complexType> 
            </xs:element> 
            <xs:element name="RegisteredServer"> 
              <xs:complexType> 
                <xs:sequence> 
                  <xs:any namespace="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" processContents="skip" minOccurs="0" maxOccurs="unbounded" /> 
                </xs:sequence> 
              </xs:complexType> 
            </xs:element> 
            <RegisteredServers:bufferData xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08"> 
              <instances xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08"> 
                <document> 
                  <docinfo> 
                    <aliases> 
                      <alias>/RegisteredServersStore</alias> 
                    </aliases> 
                    <sfc:version DomainVersion="1" /> 
                  </docinfo> 
                  <data> 
                    <RegisteredServers:RegisteredServersStore xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema"> 
                      <RegisteredServers:ServerGroups> 
                        <sfc:Collection> 
                          <sfc:Reference sml:ref="true"> 
                            <sml:Uri>/RegisteredServersStore/ServerGroup/AnalysisServicesServerGroup</sml:Uri> 
                          </sfc:Reference> 
                          <sfc:Reference sml:ref="true"> 
                            <sml:Uri>/RegisteredServersStore/ServerGroup/CentralManagementServerGroup</sml:Uri> 
                          </sfc:Reference> 
                          <sfc:Reference sml:ref="true"> 
                            <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup</sml:Uri> 
                          </sfc:Reference> 
                          <sfc:Reference sml:ref="true"> 
                            <sml:Uri>/RegisteredServersStore/ServerGroup/IntegrationServicesServerGroup</sml:Uri> 
                          </sfc:Reference> 
                          <sfc:Reference sml:ref="true"> 
                            <sml:Uri>/RegisteredServersStore/ServerGroup/ReportingServicesServerGroup</sml:Uri> 
                          </sfc:Reference> 
                          <sfc:Reference sml:ref="true"> 
                            <sml:Uri>/RegisteredServersStore/ServerGroup/SqlServerCompactEditionServerGroup</sml:Uri> 
                          </sfc:Reference> 
                        </sfc:Collection> 
                      </RegisteredServers:ServerGroups> 
                    </RegisteredServers:RegisteredServersStore> 
                  </data> 
                </document> 
                <document> 
                  <docinfo> 
                    <aliases> 
                      <alias>/RegisteredServersStore/ServerGroup/AnalysisServicesServerGroup</alias> 
                    </aliases> 
                    <sfc:version DomainVersion="1" /> 
                  </docinfo> 
                  <data> 
                    <RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema"> 
                      <RegisteredServers:Parent> 
                        <sfc:Reference sml:ref="true"> 
                          <sml:Uri>/RegisteredServersStore</sml:Uri> 
                        </sfc:Reference> 
                      </RegisteredServers:Parent> 
                      <RegisteredServers:Name type="string">AnalysisServicesServerGroup</RegisteredServers:Name> 
                      <RegisteredServers:ServerType type="ServerType">AnalysisServices</RegisteredServers:ServerType> 
                    </RegisteredServers:ServerGroup> 
                  </data> 
                </document> 
                <document> 
                  <docinfo> 
                    <aliases> 
                      <alias>/RegisteredServersStore/ServerGroup/CentralManagementServerGroup</alias> 
                    </aliases> 
                    <sfc:version DomainVersion="1" /> 
                  </docinfo> 
                  <data> 
                    <RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema"> 
                      <RegisteredServers:Parent> 
                        <sfc:Reference sml:ref="true"> 
                          <sml:Uri>/RegisteredServersStore</sml:Uri> 
                        </sfc:Reference> 
                      </RegisteredServers:Parent> 
                      <RegisteredServers:Name type="string">CentralManagementServerGroup</RegisteredServers:Name> 
                      <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType> 
                    </RegisteredServers:ServerGroup> 
                  </data> 
                </document>' 
 
set @RegSrvr_part_2_no_change = '                   
                  <document> 
                  <docinfo> 
                    <aliases> 
                      <alias>/RegisteredServersStore/ServerGroup/IntegrationServicesServerGroup</alias> 
                    </aliases> 
                    <sfc:version DomainVersion="1" /> 
                  </docinfo> 
                  <data> 
                    <RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema"> 
                      <RegisteredServers:Parent> 
                        <sfc:Reference sml:ref="true"> 
                          <sml:Uri>/RegisteredServersStore</sml:Uri> 
                        </sfc:Reference> 
                      </RegisteredServers:Parent> 
                      <RegisteredServers:Name type="string">IntegrationServicesServerGroup</RegisteredServers:Name> 
                      <RegisteredServers:ServerType type="ServerType">IntegrationServices</RegisteredServers:ServerType> 
                    </RegisteredServers:ServerGroup> 
                  </data> 
                </document> 
                <document> 
                  <docinfo> 
                    <aliases> 
                      <alias>/RegisteredServersStore/ServerGroup/ReportingServicesServerGroup</alias> 
                    </aliases> 
                    <sfc:version DomainVersion="1" /> 
                  </docinfo> 
                  <data> 
                    <RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema"> 
                      <RegisteredServers:Parent> 
                        <sfc:Reference sml:ref="true"> 
                          <sml:Uri>/RegisteredServersStore</sml:Uri> 
                        </sfc:Reference> 
                      </RegisteredServers:Parent> 
                      <RegisteredServers:Name type="string">ReportingServicesServerGroup</RegisteredServers:Name> 
                      <RegisteredServers:ServerType type="ServerType">ReportingServices</RegisteredServers:ServerType> 
                    </RegisteredServers:ServerGroup> 
                  </data> 
                </document> 
                <document> 
                  <docinfo> 
                    <aliases> 
                      <alias>/RegisteredServersStore/ServerGroup/SqlServerCompactEditionServerGroup</alias> 
                    </aliases> 
                    <sfc:version DomainVersion="1" /> 
                  </docinfo> 
                  <data> 
                    <RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema"> 
                      <RegisteredServers:Parent> 
                        <sfc:Reference sml:ref="true"> 
                          <sml:Uri>/RegisteredServersStore</sml:Uri> 
                        </sfc:Reference> 
                      </RegisteredServers:Parent> 
                      <RegisteredServers:Name type="string">SqlServerCompactEditionServerGroup</RegisteredServers:Name> 
                      <RegisteredServers:ServerType type="ServerType">SqlServerCompactEdition</RegisteredServers:ServerType> 
                    </RegisteredServers:ServerGroup> 
                  </data> 
                </document> 
              </instances> 
            </RegisteredServers:bufferData> 
          </xs:schema> 
        </data> 
      </document> 
    </definitions> 
  </xs:bufferSchema> 
</model>' 
 
set @xml_reg_servers_header_open = '                   
                  <document> 
                  <docinfo> 
                    <aliases> 
                      <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup'+case when @group_scope = 1 then '' else '/ServerGroup/'+@groups end +'</alias> 
                    </aliases> 
                    <sfc:version DomainVersion="1" /> 
                  </docinfo> 
                    <data> 
                    <RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema"> 
                      <RegisteredServers:'+case when @group_scope = 1 then 'ServerGroups' else 'RegisteredServers' end +'> 
                        <sfc:Collection>' 
 
set @xml_reg_servers_header_close = '                         
                        </sfc:Collection> 
                      </RegisteredServers:'+case when @group_scope = 1 then 'ServerGroups' else 'RegisteredServers' end +'> 
                      <RegisteredServers:Parent> 
                        <sfc:Reference sml:ref="true"> 
                          <sml:Uri>'+case when @group_scope = 1 then 'RegisteredServersStore' else '/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup' end +'</sml:Uri> 
                        </sfc:Reference> 
                      </RegisteredServers:Parent> 
                      <RegisteredServers:Name type="string">'+case when @group_scope = 1 then 'DatabaseEngineServerGroup' else @groups end +'</RegisteredServers:Name> 
       '+case when @group_scope = 1 then '' else '<RegisteredServers:Description type="string" />' end+' 
                      <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType> 
                    </RegisteredServers:ServerGroup> 
                  </data> 
                </document>' 
 
open group_cursor 
fetch next from group_cursor into @groups 
while @@FETCH_STATUS = 0 
begin 
 
set @xml_reg_servers_header =  ISNULL(@xml_reg_servers_header,'')+' 
                          <sfc:Reference sml:ref="true"> 
                            <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+case when @group_scope = 1 then @groups else @groups+'/RegisteredServer/'+replace(@ip,'.','_.') end+'</sml:Uri> 
                          </sfc:Reference>' 
 
 
fetch next from group_cursor into @groups 
end  
close group_cursor 
--deallocate group_cursor 
 
insert into @RegSrvr 
SELECT 1 x, [id], [value] from master.dbo.Separator(@RegSrvr_part_1_no_change, char(10)) 
UNION 
SELECT 2 x, [id], [value] from master.dbo.Separator(@xml_reg_servers_header_open, char(10)) 
UNION 
SELECT 3 x, [id], [value] from master.dbo.Separator(@xml_reg_servers_header, char(10))  
UNION 
SELECT 4 x, [id], [value] from master.dbo.Separator(@xml_reg_servers_header_close, char(10)) 
ORDER BY x, [id] 
 
set @x = 4 
set @xml_reg_servers_header   = null 
set @xml_reg_servers_header_open = null 
set @xml_reg_servers_header_close = null 
set @xml_reg_servers_detail   = null 
 
set @group_scope = 0 
 
open group_cursor 
fetch next from group_cursor into @groups 
while @@FETCH_STATUS = 0 
begin 
 
set @xml_reg_servers_header_open = '                   
                  <document> 
                  <docinfo> 
                    <aliases> 
                      <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup'+case when @group_scope = 1 then '' else '/'+@groups end +'</alias> 
                    </aliases> 
                    <sfc:version DomainVersion="1" /> 
                  </docinfo> 
                    <data> 
                    <RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema"> 
                      <RegisteredServers:'+case when @group_scope = 1 then 'ServerGroups' else 'RegisteredServers' end +'> 
                        <sfc:Collection>' 
 
set @xml_reg_servers_header_close = '                         
                        </sfc:Collection> 
                      </RegisteredServers:'+case when @group_scope = 1 then 'ServerGroups' else 'RegisteredServers' end +'> 
                      <RegisteredServers:Parent> 
                        <sfc:Reference sml:ref="true"> 
                          <sml:Uri>'+case when @group_scope = 1 then 'RegisteredServers' else '/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup' end +'</sml:Uri> 
                        </sfc:Reference> 
                      </RegisteredServers:Parent> 
                      <RegisteredServers:Name type="string">'+case when @group_scope = 1 then 'DatabaseEngineServerGroup' else @groups end +'</RegisteredServers:Name> 
       '+case when @group_scope = 1 then '' else '<RegisteredServers:Description type="string" />' end+' 
                      <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType> 
                    </RegisteredServers:ServerGroup> 
                  </data> 
                </document>' 
 
 
 
declare ip_cursor2 cursor fast_forward 
for 
select ip_address 
from @ips 
where groups = @groups 
 
set @xml_reg_servers_header   = null 
set @xml_reg_servers_detail   = null 
 
open ip_cursor2  
fetch next from ip_cursor2 into @ip 
while @@FETCH_STATUS = 0 
begin 
 
 
 
set @xml_reg_servers_header =  ISNULL(@xml_reg_servers_header,'')+' 
                          <sfc:Reference sml:ref="true"> 
                            <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@groups+'/RegisteredServer/'+replace(@ip,'.','_.')+'</sml:Uri> 
                          </sfc:Reference>' 
 
 
set @xml_reg_servers_detail = ISNULL(@xml_reg_servers_detail,'')+'                   
                  <document> 
                  <docinfo> 
                    <aliases> 
                      <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@groups+'/RegisteredServer/'+replace(@ip,'.','_.')+'</alias> 
                    </aliases> 
                    <sfc:version DomainVersion="1" /> 
                  </docinfo> 
                  <data> 
                    <RegisteredServers:RegisteredServer xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema"> 
                      <RegisteredServers:Parent> 
                        <sfc:Reference sml:ref="true"> 
                          <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@groups+'</sml:Uri> 
                        </sfc:Reference> 
                      </RegisteredServers:Parent> 
                      <RegisteredServers:Name type="string">'+@ip+'</RegisteredServers:Name> 
                      <RegisteredServers:Description type="string" /> 
                      <RegisteredServers:ServerName type="string">'+@ip+'</RegisteredServers:ServerName> 
                      <RegisteredServers:UseCustomConnectionColor type="boolean">false</RegisteredServers:UseCustomConnectionColor> 
                      <RegisteredServers:CustomConnectionColorArgb type="int">-986896</RegisteredServers:CustomConnectionColorArgb> 
                      <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType> 
                      <RegisteredServers:ConnectionStringWithEncryptedPassword type="string">data source='+@ip+';integrated security=True;pooling=False;multipleactiveresultsets=False;packet size=4096</RegisteredServers:ConnectionStringWithEncryptedPassword> 
                      <RegisteredServers:CredentialPersistenceType type="CredentialPersistenceType">PersistLoginName</RegisteredServers:CredentialPersistenceType> 
                    </RegisteredServers:RegisteredServer> 
                  </data> 
                </document>' 
 
fetch next from ip_cursor2 into @ip 
end 
close ip_cursor2 
deallocate ip_cursor2 
 
 
 
set @x += 1  
insert into @RegSrvr 
SELECT @x x, [id], [value] from master.dbo.Separator(@xml_reg_servers_header_open, char(10)) 
ORDER BY x, [id] 
set @x += 1  
insert into @RegSrvr 
SELECT @x x, [id], [value] from master.dbo.Separator(@xml_reg_servers_header, char(10)) 
ORDER BY x, [id] 
set @x += 1  
insert into @RegSrvr 
SELECT @x x, [id], [value] from master.dbo.Separator(@xml_reg_servers_header_close, char(10)) 
ORDER BY x, [id] 
set @x += 1  
insert into @RegSrvr 
SELECT @x x, [id], [value] from master.dbo.Separator(@xml_reg_servers_detail, char(10)) 
ORDER BY x, [id] 
 
fetch next from group_cursor into @groups 
end 
close group_cursor  
deallocate group_cursor  
 
set @x += 1  
insert into @RegSrvr 
SELECT @x x, [id], [value] from master.dbo.Separator(@RegSrvr_part_2_no_change, char(10)) 
ORDER BY x, [id] 
 
select *  
from @RegSrvr 
ORDER BY x, [id] 
 
declare @xml nvarchar(max) 
select @xml = isnull(@xml,'')+value  
from @RegSrvr 
ORDER BY x, [id] 
 
--select cast(@xml as xml) 
 
 
 
