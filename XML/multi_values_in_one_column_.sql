ALTER FUNCTION [dbo].[multi_values]
(@col varchar(10), @sep varchar(10), @recid varchar(255), @xmlrecord XML)
RETURNS @table table ([VALUES] varchar(4000))
WITH SCHEMABINDING
BEGIN
declare @multi_value Varchar(1000)

insert into @table
select 
isnull([1],'')+
isnull(@sep+[2],'') + isnull(@sep+[3],'') + isnull(@sep+[4],'') + isnull(@sep+[5],'') + isnull(@sep+[6],'') + isnull(@sep+[7],'') + isnull(@sep+[8],'') + isnull(@sep+[9],'')+
isnull(@sep+[10],'')+ isnull(@sep+[11],'')+ isnull(@sep+[12],'')+ isnull(@sep+[13],'')+ isnull(@sep+[14],'')+ isnull(@sep+[15],'')+ isnull(@sep+[16],'')+ isnull(@sep+[17],'')+ isnull(@sep+[18],'')+ isnull(@sep+[19],'')+
isnull(@sep+[20],'')+ isnull(@sep+[21],'')+ isnull(@sep+[22],'')+ isnull(@sep+[23],'')+ isnull(@sep+[24],'')+ isnull(@sep+[25],'')+ isnull(@sep+[26],'')+ isnull(@sep+[27],'')+ isnull(@sep+[28],'')+ isnull(@sep+[29],'')+
isnull(@sep+[30],'')+ isnull(@sep+[31],'')+ isnull(@sep+[32],'')+ isnull(@sep+[33],'')+ isnull(@sep+[34],'')+ isnull(@sep+[35],'')+ isnull(@sep+[36],'')+ isnull(@sep+[37],'')+ isnull(@sep+[38],'')+ isnull(@sep+[39],'')+
isnull(@sep+[40],'')+ isnull(@sep+[41],'')+ isnull(@sep+[42],'')+ isnull(@sep+[43],'')+ isnull(@sep+[44],'')+ isnull(@sep+[45],'')+ isnull(@sep+[46],'')+ isnull(@sep+[47],'')+ isnull(@sep+[48],'')+ isnull(@sep+[49],'')+
isnull(@sep+[50],'')+ isnull(@sep+[51],'')+ isnull(@sep+[52],'')+ isnull(@sep+[53],'')+ isnull(@sep+[54],'')+ isnull(@sep+[55],'')+ isnull(@sep+[56],'')+ isnull(@sep+[57],'')+ isnull(@sep+[58],'')+ isnull(@sep+[59],'')+
isnull(@sep+[60],'')+ isnull(@sep+[61],'')+ isnull(@sep+[62],'')+ isnull(@sep+[63],'')+ isnull(@sep+[64],'')+ isnull(@sep+[65],'')+ isnull(@sep+[66],'')+ isnull(@sep+[67],'')+ isnull(@sep+[68],'')+ isnull(@sep+[69],'')+
isnull(@sep+[70],'')+ isnull(@sep+[71],'')+ isnull(@sep+[72],'')+ isnull(@sep+[73],'')+ isnull(@sep+[74],'')+ isnull(@sep+[75],'')+ isnull(@sep+[76],'')+ isnull(@sep+[77],'')+ isnull(@sep+[78],'')+ isnull(@sep+[79],'')+
isnull(@sep+[80],'')+ isnull(@sep+[81],'')+ isnull(@sep+[82],'')+ isnull(@sep+[83],'')+ isnull(@sep+[84],'')+ isnull(@sep+[85],'')+ isnull(@sep+[86],'')+ isnull(@sep+[87],'')+ isnull(@sep+[88],'')+ isnull(@sep+[89],'')+
isnull(@sep+[90],'')+ isnull(@sep+[91],'')+ isnull(@sep+[92],'')+ isnull(@sep+[93],'')+ isnull(@sep+[94],'')+ isnull(@sep+[95],'')+ isnull(@sep+[96],'')+ isnull(@sep+[97],'')+ isnull(@sep+[98],'')+ isnull(@sep+[99],'')+
isnull(@sep+[100],'')+isnull(@sep+[101],'')+isnull(@sep+[102],'')+isnull(@sep+[103],'')+isnull(@sep+[104],'')+isnull(@sep+[105],'')+isnull(@sep+[106],'')+isnull(@sep+[107],'')+isnull(@sep+[108],'')+isnull(@sep+[109],'')+
isnull(@sep+[110],'')+isnull(@sep+[111],'')+isnull(@sep+[112],'')+isnull(@sep+[113],'')+isnull(@sep+[114],'')+isnull(@sep+[115],'')+isnull(@sep+[116],'')+isnull(@sep+[117],'')+isnull(@sep+[118],'')+isnull(@sep+[119],'')+
isnull(@sep+[120],'')+isnull(@sep+[121],'')+isnull(@sep+[122],'')+isnull(@sep+[123],'')+isnull(@sep+[124],'')+isnull(@sep+[125],'')+isnull(@sep+[126],'')+isnull(@sep+[127],'')+isnull(@sep+[128],'')+isnull(@sep+[129],'')+
isnull(@sep+[130],'')+isnull(@sep+[131],'')+isnull(@sep+[132],'')+isnull(@sep+[133],'')+isnull(@sep+[134],'')+isnull(@sep+[135],'')+isnull(@sep+[136],'')+isnull(@sep+[137],'')+isnull(@sep+[138],'')+isnull(@sep+[139],'')+
isnull(@sep+[140],'')+isnull(@sep+[141],'')+isnull(@sep+[142],'')+isnull(@sep+[143],'')+isnull(@sep+[144],'')+isnull(@sep+[145],'')+isnull(@sep+[146],'')+isnull(@sep+[147],'')+isnull(@sep+[148],'')+isnull(@sep+[149],'')+
isnull(@sep+[150],'')+isnull(@sep+[151],'')+isnull(@sep+[152],'')+isnull(@sep+[153],'')+isnull(@sep+[154],'')+isnull(@sep+[155],'')+isnull(@sep+[156],'')+isnull(@sep+[157],'')+isnull(@sep+[158],'')+isnull(@sep+[159],'')+
isnull(@sep+[160],'')+isnull(@sep+[161],'')+isnull(@sep+[162],'')+isnull(@sep+[163],'')+isnull(@sep+[164],'')+isnull(@sep+[165],'')+isnull(@sep+[166],'')+isnull(@sep+[167],'')+isnull(@sep+[168],'')+isnull(@sep+[169],'')+
isnull(@sep+[170],'')+isnull(@sep+[171],'')+isnull(@sep+[172],'')+isnull(@sep+[173],'')+isnull(@sep+[174],'')+isnull(@sep+[175],'')+isnull(@sep+[176],'')+isnull(@sep+[177],'')+isnull(@sep+[178],'')+isnull(@sep+[179],'')+
isnull(@sep+[180],'')+isnull(@sep+[181],'')+isnull(@sep+[182],'')+isnull(@sep+[183],'')+isnull(@sep+[184],'')+isnull(@sep+[185],'')+isnull(@sep+[186],'')+isnull(@sep+[187],'')+isnull(@sep+[188],'')+isnull(@sep+[189],'')+
isnull(@sep+[190],'')+isnull(@sep+[191],'')+isnull(@sep+[192],'')+isnull(@sep+[193],'')+isnull(@sep+[194],'')+isnull(@sep+[195],'')+isnull(@sep+[196],'')+isnull(@sep+[197],'')+isnull(@sep+[198],'')+isnull(@sep+[199],'')+
isnull(@sep+[200],'')+isnull(@sep+[201],'')+isnull(@sep+[202],'')+isnull(@sep+[203],'')+isnull(@sep+[204],'')+isnull(@sep+[205],'')+isnull(@sep+[206],'')+isnull(@sep+[207],'')+isnull(@sep+[208],'')+isnull(@sep+[209],'')+
isnull(@sep+[210],'')+isnull(@sep+[211],'')+isnull(@sep+[212],'')+isnull(@sep+[213],'')+isnull(@sep+[214],'')+isnull(@sep+[215],'')+isnull(@sep+[216],'')+isnull(@sep+[217],'')+isnull(@sep+[218],'')+isnull(@sep+[219],'')+
isnull(@sep+[220],'')+isnull(@sep+[221],'')+isnull(@sep+[222],'')+isnull(@sep+[223],'')+isnull(@sep+[224],'')+isnull(@sep+[225],'')+isnull(@sep+[226],'')+isnull(@sep+[227],'')+isnull(@sep+[228],'')+isnull(@sep+[229],'')+
isnull(@sep+[230],'')+isnull(@sep+[231],'')+isnull(@sep+[232],'')+isnull(@sep+[233],'')+isnull(@sep+[234],'')+isnull(@sep+[235],'')+isnull(@sep+[236],'')+isnull(@sep+[237],'')+isnull(@sep+[238],'')+isnull(@sep+[239],'')+
isnull(@sep+[240],'')+isnull(@sep+[241],'')+isnull(@sep+[242],'')+isnull(@sep+[243],'')+isnull(@sep+[244],'')+isnull(@sep+[245],'')+isnull(@sep+[246],'')+isnull(@sep+[247],'')+isnull(@sep+[248],'')+isnull(@sep+[249],'')+
isnull(@sep+[250],'')+isnull(@sep+[251],'')+isnull(@sep+[252],'')+isnull(@sep+[253],'')+isnull(@sep+[254],'')+isnull(@sep+[255],'')+isnull(@sep+[256],'')+isnull(@sep+[257],'')+isnull(@sep+[258],'')+isnull(@sep+[259],'')+
isnull(@sep+[260],'')+isnull(@sep+[261],'')+isnull(@sep+[262],'')+isnull(@sep+[263],'')+isnull(@sep+[264],'')+isnull(@sep+[265],'')+isnull(@sep+[266],'')+isnull(@sep+[267],'')+isnull(@sep+[268],'')+isnull(@sep+[269],'')+
isnull(@sep+[270],'')+isnull(@sep+[271],'')+isnull(@sep+[272],'')+isnull(@sep+[273],'')+isnull(@sep+[274],'')+isnull(@sep+[275],'')+isnull(@sep+[276],'')+isnull(@sep+[277],'')+isnull(@sep+[278],'')+isnull(@sep+[279],'')+
isnull(@sep+[280],'')+isnull(@sep+[281],'')+isnull(@sep+[282],'')+isnull(@sep+[283],'')+isnull(@sep+[284],'')+isnull(@sep+[285],'')+isnull(@sep+[286],'')+isnull(@sep+[287],'')+isnull(@sep+[288],'')+isnull(@sep+[289],'')+
isnull(@sep+[290],'')+isnull(@sep+[291],'')+isnull(@sep+[292],'')+isnull(@sep+[293],'')+isnull(@sep+[294],'')+isnull(@sep+[295],'')+isnull(@sep+[296],'')+isnull(@sep+[297],'')+isnull(@sep+[298],'')+isnull(@sep+[299],'')+
isnull(@sep+[300],'')
from (
select row_number() over(order by tag_no) tag_no, col
from (
select 
row_number() over(order by @recid) tag_no,  
T.C.value('.', 'varchar(34)') col
FROM @XMLRECORD.nodes('(/row/*[local-name(.)=sql:variable("@col")])') as T(C))a
)b
pivot (
max(col) for tag_no in (
[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],
[30],[31],[32],[33],[34],[35],[36],[37],[38],[39],[40],[41],[42],[43],[44],[45],[46],[47],[48],[49],[50],[51],[52],[53],[54],[55],[56],[57],[58],[59],
[60],[61],[62],[63],[64],[65],[66],[67],[68],[69],[70],[71],[72],[73],[74],[75],[76],[77],[78],[79],[80],[81],[82],[83],[84],[85],[86],[87],[88],[89],
[90],[91],[92],[93],[94],[95],[96],[97],[98],[99],[100],[101],[102],[103],[104],[105],[106],[107],[108],[109],[110],[111],[112],[113],[114],[115],[116],
[117],[118],[119],[120],[121],[122],[123],[124],[125],[126],[127],[128],[129],[130],[131],[132],[133],[134],[135],[136],[137],[138],[139],[140],[141],
[142],[143],[144],[145],[146],[147],[148],[149],[150],[151],[152],[153],[154],[155],[156],[157],[158],[159],[160],[161],[162],[163],[164],[165],[166],
[167],[168],[169],[170],[171],[172],[173],[174],[175],[176],[177],[178],[179],[180],[181],[182],[183],[184],[185],[186],[187],[188],[189],[190],[191],
[192],[193],[194],[195],[196],[197],[198],[199],[200],[201],[202],[203],[204],[205],[206],[207],[208],[209],[210],[211],[212],[213],[214],[215],[216],
[217],[218],[219],[220],[221],[222],[223],[224],[225],[226],[227],[228],[229],[230],[231],[232],[233],[234],[235],[236],[237],[238],[239],[240],[241],
[242],[243],[244],[245],[246],[247],[248],[249],[250],[251],[252],[253],[254],[255],[256],[257],[258],[259],[260],[261],[262],[263],[264],[265],[266],
[267],[268],[269],[270],[271],[272],[273],[274],[275],[276],[277],[278],[279],[280],[281],[282],[283],[284],[285],[286],[287],[288],[289],[290],[291],
[292],[293],[294],[295],[296],[297],[298],[299],[300]))p

return
end
