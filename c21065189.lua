--ファイアウォール・X・ドラゴン
-- 效果：
-- 4星怪兽×2只以上
-- ①：超量召唤的这张卡的攻击力上升和这张卡成为连接状态的连接怪兽的连接标记数量×500。
-- ②：把这张卡2个超量素材取除，以自己墓地1只连接4电子界族连接怪兽为对象才能发动。那只怪兽在要和这张卡成为连接状态的自己场上特殊召唤。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤，不能直接攻击。
function c21065189.initial_effect(c)
	-- 为这张卡添加超量召唤手续：可用4星怪兽2只以上（最多99只）叠放超量召唤。
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
-- 攻击力上升效果的条件：判定这张卡是否为超量召唤成功（召唤方式为超量召唤）。
function c21065189.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤出场上表侧表示、是连接怪兽，并且与这张卡处于连接状态（这张卡在其连接区域内）的怪兽。
function c21065189.atkfilter(c,ec)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:GetLinkedGroup():IsContains(ec)
end
-- 计算攻击力上升数值：取场上所有与这张卡处于连接状态的连接怪兽的连接标记数量之和，乘以500。
function c21065189.atkval(e,c)
	-- 获取所有与这张卡处于连接状态的表侧连接怪兽（用于计算攻击力上升量）。
	local g=Duel.GetMatchingGroup(c21065189.atkfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler())
	return g:GetSum(Card.GetLink)*500
end
-- 发动代价：从这张卡上取除2个超量素材作为代价（先检查是否有2个素材，再实际取除）。
function c21065189.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 根据特殊召唤的怪兽的连接标记和这张卡所在位置，计算可供特殊召唤的场上区域（位掩码），使召唤出的怪兽能与这张卡形成连接状态。
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
-- 选择对象的过滤条件：自己墓地的连接4电子界族连接怪兽，且可特殊召唤到与这张卡成为连接状态的区域。
function c21065189.spfilter(c,e,tp,seq)
	if not (c:IsType(TYPE_LINK) and c:IsRace(RACE_CYBERSE) and c:IsLink(4)) then return false end
	local zone=c21065189.get_zone(c,seq)
	return zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 目标选择：从自己墓地选择1只满足条件的连接4电子界族连接怪兽作为对象，并确认有可用区域。
function c21065189.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local seq=e:GetHandler():GetSequence()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21065189.spfilter(chkc,e,tp,seq) end
	-- 判定自己场上是否有可用的怪兽区域（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在1只以上满足特殊召唤条件的对象。
		and Duel.IsExistingTarget(c21065189.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,seq) end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的怪兽作为效果对象，并设定为连锁对象。
	local g=Duel.SelectTarget(tp,c21065189.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,seq)
	-- 将本连锁的操作信息设置为“特殊召唤1只怪兽”，供后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若这张卡仍在场上且对象仍与该效果关联，则将对象特殊召唤到与这张卡连接状态的区域；然后给发动玩家附加直到回合结束“不能特殊召唤怪兽”和“不能直接攻击”的限制。
function c21065189.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽（墓地的那只连接怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsControler(tp) and tc:IsRelateToEffect(e) then
		local zone=c21065189.get_zone(tc,c:GetSequence())
		-- 将对象怪兽以表侧表示特殊召唤到之前计算好的、能与这张卡成为连接状态的区域。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
	-- 这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将“不能特殊召唤怪兽”的限制效果注册给玩家tp，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- 不能直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能直接攻击”的誓约效果注册给玩家tp，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
end
