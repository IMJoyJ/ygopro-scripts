--覇王の逆鱗
-- 效果：
-- ①：自己场上有「霸王龙 扎克」存在的场合才能发动。「霸王龙 扎克」以外的自己场上的怪兽全部破坏，从自己的手卡·卡组·额外卡组·墓地把最多4只卡名不同的「霸王眷龙」怪兽无视召唤条件特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只「霸王眷龙」超量怪兽为对象才能发动。从自己的额外卡组（表侧）·墓地选2只「霸王眷龙」怪兽作为成为对象的怪兽的超量素材。
function c84869738.initial_effect(c)
	-- 注册卡片脚本中提及了「霸王龙 扎克」的卡名
	aux.AddCodeList(c,13331639)
	-- ①：自己场上有「霸王龙 扎克」存在的场合才能发动。「霸王龙 扎克」以外的自己场上的怪兽全部破坏，从自己的手卡·卡组·额外卡组·墓地把最多4只卡名不同的「霸王眷龙」怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c84869738.condition)
	e1:SetTarget(c84869738.target)
	e1:SetOperation(c84869738.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「霸王眷龙」超量怪兽为对象才能发动。从自己的额外卡组（表侧）·墓地选2只「霸王眷龙」怪兽作为成为对象的怪兽的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置效果②的发动动作为：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c84869738.mattg)
	e2:SetOperation(c84869738.matop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「霸王龙 扎克」
function c84869738.cfilter(c)
	return c:IsFaceup() and c:IsCode(13331639)
end
-- 效果①的发动条件：自己场上有「霸王龙 扎克」存在
function c84869738.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「霸王龙 扎克」
	return Duel.IsExistingMatchingCard(c84869738.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：非「霸王龙 扎克」的怪兽
function c84869738.desfilter(c)
	return not c84869738.cfilter(c)
end
-- 过滤条件：可以无视召唤条件特殊召唤的「霸王眷龙」怪兽，并根据其所在位置判断是否有可用的怪兽区域
function c84869738.spfilter(c,e,tp,g)
	if not (c:IsSetCard(0x20f8) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 检查在假设破坏了怪兽组后，额外卡组的怪兽是否有可用的额外怪兽区域进行特殊召唤
		return Duel.GetLocationCountFromEx(tp,tp,g,c)>0
	else
		-- 检查在假设破坏了怪兽组后，是否有可用的主要怪兽区域进行特殊召唤
		return Duel.GetMZoneCount(tp,g)>0
	end
end
-- 效果①的发动准备：检查场上是否有可破坏的怪兽，以及各区域是否有可特殊召唤的「霸王眷龙」怪兽
function c84869738.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上除「霸王龙 扎克」以外的所有怪兽
	local g=Duel.GetMatchingGroup(c84869738.desfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return g:GetCount()>0
		-- 检查手卡、卡组、墓地、额外卡组是否存在至少1只在破坏发生后能特殊召唤的「霸王眷龙」怪兽
		and Duel.IsExistingMatchingCard(c84869738.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp,g) end
	-- 设置操作信息：破坏自己场上除「霸王龙 扎克」以外的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：从手卡、卡组、墓地、额外卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 过滤条件：额外卡组里里侧表示的融合、同调、超量怪兽
function c84869738.exfilter2(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 过滤条件：额外卡组里的连接怪兽，或表侧表示的灵摆怪兽
function c84869738.exfilter3(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
-- 检查选择的怪兽组是否满足：卡名各不相同、数量不超过可用怪兽区域总数，且各来源区域的怪兽数量不超过该区域对应的可用格子限制
function c84869738.gcheck(g,ft1,ft2,ft3,ect,ft)
	-- 检查怪兽组内卡名是否互不相同，且总数量不超过可用的怪兽区域总数
	return aux.dncheck(g) and #g<=ft
		and g:FilterCount(Card.IsLocation,nil,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)<=ft1
		and g:FilterCount(c84869738.exfilter2,nil)<=ft2
		and g:FilterCount(c84869738.exfilter3,nil)<=ft3
		and g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect
end
-- 效果①的实际处理：破坏符合条件的怪兽，并根据场上格子情况，从手卡、卡组、额外卡组、墓地选择最多4只卡名不同的「霸王眷龙」怪兽无视召唤条件特殊召唤
function c84869738.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上除「霸王龙 扎克」以外的所有怪兽
	local dg=Duel.GetMatchingGroup(c84869738.desfilter,tp,LOCATION_MZONE,0,nil)
	-- 破坏这些怪兽，若没有怪兽被破坏，则不处理后续特殊召唤效果
	if Duel.Destroy(dg,REASON_EFFECT)==0 then return end
	-- 获取当前可用的主要怪兽区域数量
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取额外卡组里侧表示的融合、同调、超量怪兽可用的额外怪兽区域数量
	local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	-- 获取额外卡组表侧表示的灵摆怪兽或连接怪兽可用的额外怪兽区域数量
	local ft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
	-- 获取玩家当前可用的怪兽区域总数
	local ft=Duel.GetUsableMZoneCount(tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		if ft3>0 then ft3=1 end
		ft=1
	end
	-- 计算受其他卡片效果影响后的额外卡组特召可用格子上限
	local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
	local loc=0
	if ft1>0 then loc=loc+LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE end
	if ect>0 and (ft2>0 or ft3>0) then loc=loc+LOCATION_EXTRA end
	if loc==0 then return end
	-- 获取所有符合特殊召唤条件且不受「王家长眠之谷」影响的「霸王眷龙」怪兽
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c84869738.spfilter),tp,loc,0,nil,e,tp)
	if sg:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local rg=sg:SelectSubGroup(tp,c84869738.gcheck,false,1,4,ft1,ft2,ft3,ect,ft)
	-- 将选择的怪兽无视召唤条件以表侧表示特殊召唤
	Duel.SpecialSummon(rg,0,tp,tp,true,false,POS_FACEUP)
end
-- 过滤条件：自己场上表侧表示的「霸王眷龙」超量怪兽
function c84869738.xyzfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x20f8) and c:IsType(TYPE_XYZ)
end
-- 过滤条件：墓地或额外卡组表侧表示的、可以作为超量素材的「霸王眷龙」怪兽
function c84869738.matfilter(c)
	return c:IsSetCard(0x20f8) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA)) and c:IsCanOverlay()
end
-- 效果②的发动准备：选择自己场上1只「霸王眷龙」超量怪兽作为对象，并确认墓地或额外卡组有至少2只可作为素材的怪兽
function c84869738.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c84869738.xyzfilter(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的「霸王眷龙」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c84869738.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己的墓地或额外卡组是否存在至少2只可作为超量素材的「霸王眷龙」怪兽
		and Duel.IsExistingMatchingCard(c84869738.matfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,2,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「霸王眷龙」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c84869738.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的实际处理：从额外卡组（表侧）或墓地选择2只「霸王眷龙」怪兽，重叠在作为对象的超量怪兽下面作为超量素材
function c84869738.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从墓地或额外卡组选择2只「霸王眷龙」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c84869738.matfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,2,2,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽重叠在目标超量怪兽下方作为超量素材
			Duel.Overlay(tc,g)
		end
	end
end
