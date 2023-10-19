declare @RegSrvr table (x int, id int, value varchar(max))
declare @ips table (ip_address varchar(100))
insert into @ips values 
('10.0.10.29,17120'),
('10.0.10.34,17120'),
('10.0.15.66,17120'),
('10.0.6.134'),
('10.0.6.22,17120'),
('10.0.7.4,17120'),
('10.1.2.67'),
('10.1.2.68'),
('10.2.23.31,17120'),
('10.32.10.32,17120'),
('10.32.10.37,17120'),
('10.32.15.66,17120'),
('10.32.6.134'),
('10.32.6.40,17120'),
('10.32.7.4,17120'),
('10.33.2.67'),
('10.33.2.68'),
('10.34.23.31,17120'),
('10.36.0.100'),
('10.36.0.178'),
('10.36.0.179'),
('10.36.0.41'),
('10.36.0.56'),
('10.36.0.65'),
('10.36.1.106'),
('10.36.1.107'),
('10.36.1.136,17120'),
('10.36.1.138,17120'),
('10.36.1.15'),
('10.1.102.16'),
('10.1.102.17'),
('10.1.102.1'),
('10.1.102.2'),
('10.33.102.16'),
('10.33.102.17'),
('10.33.102.1'),
('10.33.102.2'),
('10.36.1.178,17120'),
('10.36.1.19'),
('10.36.1.198,17120'),
('10.36.1.212,17120'),
('10.36.1.213,17120'),
('10.36.1.6,17120'),
('10.36.1.62'),
('10.36.1.82'),
('10.36.1.86'),
('10.36.1.94'),
('10.36.100.17'),
('10.36.2.1'),
('10.36.2.10,17120'),
('10.36.2.102'),
('10.36.2.108,17120'),
('10.36.2.109,17120'),
('10.36.2.142,17120'),
('10.36.2.180,17120'),
('10.36.2.189,17120'),
('10.36.2.68,17120'),
('10.36.2.71,17120'),
('10.36.2.76,17120'),
('10.4.0.100'),
('10.4.0.178'),
('10.4.0.179'),
('10.4.0.41'),
('10.4.0.59'),
('10.4.0.65'),
('10.4.1.108'),
('10.4.1.109'),
('10.4.1.110'),
('10.4.1.15'),
('10.4.1.155,17120'),
('10.4.1.178,17120'),
('10.4.1.183,17120'),
('10.4.1.184,17120'),
('10.4.1.19'),
('10.4.1.203,17120'),
('10.4.1.212,17120'),
('10.4.1.213,17120'),
('10.4.1.63'),
('10.4.1.64'),
('10.4.1.82'),
('10.4.1.86'),
('10.4.1.88'),
('10.4.1.9,17120'),
('10.4.1.94'),
('10.4.100.17'),
('10.4.2.1'),
('10.4.2.10,17120'),
('10.4.2.102'),
('10.4.2.159,17120'),
('10.4.2.220,17120'),
('10.4.2.222,17120'),
('10.4.2.61,17120'),
('10.4.2.68,17120'),
('10.4.2.71,17120'),
('10.4.2.75,17120'),
('10.4.2.78,17120'),
('10.4.2.85,17120')
declare ip_cursor cursor fast_forward
for
select ip_address
from @ips

declare
@RegSrvr_part_1_no_change	varchar(max),
@RegSrvr_part_2_no_change	varchar(max),
@xml_reg_group				varchar(max),
@xml_reg_servers_header		varchar(max),
@xml_reg_servers_detail			varchar(max),
@xml_reg_servers_header_open	varchar(max),
@xml_reg_servers_header_close	varchar(max),
@ip								varchar(100), 
@group_name					varchar(100) = 'Network Failover Activity'


set @xml_reg_group = '				  
					  <document>
					  <docinfo>
						  <aliases>
							  <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup</alias>
						  </aliases>
						  <sfc:version DomainVersion="1" />
					  </docinfo>
					  <data>
						  <RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema">
							  <RegisteredServers:ServerGroups>
								  <sfc:Collection>
									  <sfc:Reference sml:ref="true">
										  <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@group_name+'</sml:Uri>
									  </sfc:Reference>
								  </sfc:Collection>
							  </RegisteredServers:ServerGroups>
							  <RegisteredServers:Parent>
								  <sfc:Reference sml:ref="true">
									  <sml:Uri>/RegisteredServersStore</sml:Uri>
								  </sfc:Reference>
							  </RegisteredServers:Parent>
							  <RegisteredServers:Name type="string">DatabaseEngineServerGroup</RegisteredServers:Name>
							  <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType>
						  </RegisteredServers:ServerGroup>
					  </data>
				  </document>'

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
                      <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@group_name+'</alias>
                    </aliases>
                    <sfc:version DomainVersion="1" />
                  </docinfo>
                    <data>
                    <RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema">
                      <RegisteredServers:RegisteredServers>
                        <sfc:Collection>'

set @xml_reg_servers_header_close = '                        
                        </sfc:Collection>
                      </RegisteredServers:RegisteredServers>
                      <RegisteredServers:Parent>
                        <sfc:Reference sml:ref="true">
                          <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup</sml:Uri>
                        </sfc:Reference>
                      </RegisteredServers:Parent>
                      <RegisteredServers:Name type="string">'+@group_name+'</RegisteredServers:Name>
                      <RegisteredServers:Description type="string" />
                      <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType>
                    </RegisteredServers:ServerGroup>
                  </data>
                </document>'

open ip_cursor
fetch next from ip_cursor into @ip
while @@FETCH_STATUS = 0
begin


set @xml_reg_servers_header =  ISNULL(@xml_reg_servers_header,'')+'
                          <sfc:Reference sml:ref="true">
                            <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@group_name+'/RegisteredServer/'+replace(@ip,'.','_.')+'</sml:Uri>
                          </sfc:Reference>'
				  
set @xml_reg_servers_detail = ISNULL(@xml_reg_servers_detail,'')+'                  
                  <document>
                  <docinfo>
                    <aliases>
                      <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@group_name+'/RegisteredServer/'+replace(@ip,'.','_.')+'</alias>
                    </aliases>
                    <sfc:version DomainVersion="1" />
                  </docinfo>
                  <data>
                    <RegisteredServers:RegisteredServer xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema">
                      <RegisteredServers:Parent>
                        <sfc:Reference sml:ref="true">
                          <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@group_name+'</sml:Uri>
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


--insert into @RegSrvr
--select 1 x, id, value from master.dbo.Separator(@xml_detailed_1,char(10))
--union
--select 2 x, id, value from master.dbo.Separator(@xml_overall,char(10))
--union
--select 3 x, id, value from master.dbo.Separator(@xml_detailed_1_1,char(10)) 
--union
--select 4 x, id, value from master.dbo.Separator(@xml_detailed_2,char(10))  order by x, id


fetch next from ip_cursor into @ip
end
close ip_cursor
deallocate ip_cursor

insert into @RegSrvr
select 0 x, id, value from master.dbo.Separator(@RegSrvr_part_1_no_change,char(10))
union
select 1 x, id, value from master.dbo.Separator(@xml_reg_group,char(10))
union
select 2 x, id, value from master.dbo.Separator(@xml_reg_servers_header_open,char(10))
union
select 3 x, id, value from master.dbo.Separator(@xml_reg_servers_header,char(10)) 
union
select 4 x, id, value from master.dbo.Separator(@xml_reg_servers_header_close,char(10))
union
select 5 x, id, value from master.dbo.Separator(@xml_reg_servers_detail,char(10))
union
select 6 x, id, value from master.dbo.Separator(@RegSrvr_part_2_no_change,char(10))  order by x, id

select * from @RegSrvr
order by x, id
