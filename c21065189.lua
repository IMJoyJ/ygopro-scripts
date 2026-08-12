--ファイアウォール・X・ドラゴン
-- 效果：
-- 4星怪兽×2只以上
-- ①：超量召唤的这张卡的攻击力上升和这张卡成为连接状态的连接怪兽的连接标记数量×500。
-- ②：把这张卡2个超量素材取除，以自己墓地1只连接4电子界族连接怪兽为对象才能发动。那只怪兽在要和这张卡成为连接状态的自己场上特殊召唤。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤，不能直接攻击。
function c21065189.initial_effect(c)
	-- 添加超量召唤手续，要求满足条件的4星怪兽至少2只以上
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：超量召唤的这张卡的攻击力上升和这张卡成为连接状态的连接怪兽的连接标记数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c21065189.atkcon)
	e1:SetValue(c21065189.atkval)
	c:RegisterEffect(e1)
	-- ②：把这张卡2个超量素材取除，以自己墓地1只连接4电子界族连接怪兽为对象才能发动。那只怪兽在要和这张卡成为连接状态的自己场上特殊召唤。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤，不能直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21065189,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c21065189.cost)
	e2:SetTarget(c21065189.target)
	e2:SetOperation(c21065189.operation)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为超量召唤
function c21065189.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 筛选场上正面表示的连接怪兽，且包含此卡的连接组
function c21065189.atkfilter(c,ec)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:GetLinkedGroup():IsContains(ec)
end
-- 计算满足条件的连接怪兽数量并乘以500作为攻击力加成
function c21065189.atkval(e,c)
	-- 获取满足条件的连接怪兽组
	local g=Duel.GetMatchingGroup(c21065189.atkfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler())
	return g:GetSum(Card.GetLink)*500
end
-- 支付2个超量素材作为代价
function c21065189.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 根据连接怪兽的连接标记计算可召唤区域
function c21065189.get_zone(c,seq)
	local zone=0
	if seq<4 and c:IsLinkMarker(LINK_MARKER_LEFT) then zone=bit.replace(zone,0x1,seq+1) end
	if seq>0 and seq<5 and c:IsLinkMarker(LINK_MARKER_RIGHT) then zone=bit.replace(zone,0x1,seq-1) end
	if seq==5 and c:IsLinkMarker(LINK_MARKER_TOP_LEFT) then zone=bit.replace(zone,0x1,2) end
	if seq==5 and c:IsLinkMarker(LINK_MARKER_TOP) then zone=bit.replace(zone,0x1,1) end
	if seq==5 and c:IsLinkMarker(LINK_MARKER_TOP_RIGHT) then zone=bit.replace(zone,0x1,0) end
	if seq==6 and c:IsLinkMarker(LINK_MARKER_TOP_LEFT) then zone=bit.replace(zone,0x1,4) end
	if seq==6 and c:IsLinkMarker(LINK_MARKER_TOP) then zone=bit.replace(zone,0x1,3) end
	if seq==6 and c:IsLinkMarker(LINK_MARKER_TOP_RIGHT) then zone=bit.replace(zone,0x1,2) end
	return zone
end
-- 筛选墓地中的连接4电子界族连接怪兽，且满足召唤区域条件
function c21065189.spfilter(c,e,tp,seq)
	if not (c:IsType(TYPE_LINK) and c:IsRace(RACE_CYBERSE) and c:IsLink(4)) then return false end
	local zone=c21065189.get_zone(c,seq)
	return zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 设置效果目标为墓地中的连接4电子界族连接怪兽
function c21065189.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local seq=e:GetHandler():GetSequence()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21065189.spfilter(chkc,e,tp,seq) end
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c21065189.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,seq) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c21065189.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,seq)
	-- 设置效果操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果操作，将目标怪兽特殊召唤到场上，并设置不能特殊召唤和不能直接攻击的效果
function c21065189.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsControler(tp) and tc:IsRelateToEffect(e) then
		local zone=c21065189.get_zone(tc,c:GetSequence())
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
	-- 设置不能特殊召唤的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 注册不能特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
	-- 设置不能直接攻击的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能直接攻击的效果
	Duel.RegisterEffect(e2,tp)
end
