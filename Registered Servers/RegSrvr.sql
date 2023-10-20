declare @RegSrvr table (value varchar(max))
declare @ips table (ip_address varchar(100))
insert into @ips values 
('172.xx.xx.xx'),
('10.xx.xx.xx'),
('10.xx.xx.xx'),
('10.xx.xx.xx'),
('10.xx.xx.xx,17772'),
('10.xx.xx.xx,1432')

declare ip_cursor cursor fast_forward
for
select ip_address
from @ips

declare @xml_overall varchar(max), @ip varchar(100), @group_name varchar(100) = 'Failover Activity'

open ip_cursor
fetch next from ip_cursor into @ip
while @@FETCH_STATUS = 0
begin

--set @xml_group = '<document>
--                  <docinfo>
--                    <aliases>
--                      <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup</alias>
--                    </aliases>
--                    <sfc:version DomainVersion="1" />
--                  </docinfo>
--                  <data>
--                    <RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema">
--                      <RegisteredServers:ServerGroups>
--                        <sfc:Collection>
--                          <sfc:Reference sml:ref="true">
--                            <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/old T24</sml:Uri>
--                          </sfc:Reference>
--                        </sfc:Collection>
--                      </RegisteredServers:ServerGroups>
--                      <RegisteredServers:Parent>
--                        <sfc:Reference sml:ref="true">
--                          <sml:Uri>/RegisteredServersStore</sml:Uri>
--                        </sfc:Reference>
--                      </RegisteredServers:Parent>
--                      <RegisteredServers:Name type="string">DatabaseEngineServerGroup</RegisteredServers:Name>
--                      <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType>
--                    </RegisteredServers:ServerGroup>
--                  </data>
--                </document>'

set @xml_overall = '<document>
		<data>
		<RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema">
			<RegisteredServers:RegisteredServers>
				<sfc:Collection>
					<sfc:Reference sml:ref="true">
						<sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@group_name+'/RegisteredServer/'+replace(@ip,'.','_.')+'</sml:Uri>
					</sfc:Reference>
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
</document>
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

insert into @RegSrvr
select @xml_overall
fetch next from ip_cursor into @ip
end
close ip_cursor
deallocate ip_cursor

select *
from @RegSrvr

