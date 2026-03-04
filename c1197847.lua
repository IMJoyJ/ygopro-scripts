--幻煌龍の螺旋波
-- 效果：
-- 通常怪兽才能装备。「幻煌龙的螺旋波」的②的效果1回合只能使用1次。
-- ①：装备怪兽1回合只有1次不会被战斗破坏。
-- ②：装备怪兽进行战斗的战斗阶段结束时才能发动。从自己的手卡·卡组·墓地选1只「幻煌龙 螺旋」特殊召唤，这张卡给那只怪兽装备。那之后，有对方手卡的场合，对方选1张手卡丢弃。
function c1197847.initial_effect(c)
	-- 通常怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1197847.target)
	e1:SetOperation(c1197847.operation)
	c:RegisterEffect(e1)
	-- 「幻煌龙的螺旋波」的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c1197847.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽1回合只有1次不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetCountLimit(1)
	e3:SetValue(c1197847.valcon)
	c:RegisterEffect(e3)
	-- 装备怪兽进行战斗的战斗阶段结束时才能发动。从自己的手卡·卡组·墓地选1只「幻煌龙 螺旋」特殊召唤，这张卡给那只怪兽装备。那之后，有对方手卡的场合，对方选1张手卡丢弃。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1197847,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,1197847)
	e4:SetCondition(c1197847.spcon)
	e4:SetTarget(c1197847.sptg)
	e4:SetOperation(c1197847.spop)
	c:RegisterEffect(e4)
end
-- 限制只能装备到通常怪兽上。
function c1197847.eqlimit(e,c)
	return c:IsType(TYPE_NORMAL)
end
-- 过滤出场上正面表示的通常怪兽。
function c1197847.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
-- 设置装备效果的处理目标。
function c1197847.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1197847.filter(chkc) end
	-- 检查场上是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c1197847.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择场上正面表示的通常怪兽作为装备对象。
	Duel.SelectTarget(tp,c1197847.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 设置装备效果的处理流程。
function c1197847.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- 设置装备怪兽不会被战斗破坏的条件。
function c1197847.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 设置②效果发动的条件。
function c1197847.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:GetBattledGroupCount()>0
end
-- 过滤出「幻煌龙 螺旋」怪兽。
function c1197847.spfilter(c,e,tp)
	return c:IsCode(56649609) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置②效果的处理目标。
function c1197847.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的特殊召唤位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地是否存在「幻煌龙 螺旋」。
		and Duel.IsExistingMatchingCard(c1197847.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	-- 设置装备的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 检查对方是否有手卡。
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
		-- 设置丢弃手卡的处理信息。
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	end
end
-- 设置②效果的处理流程。
function c1197847.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否有足够的特殊召唤位置。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的「幻煌龙 螺旋」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1197847.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 将选中的怪兽特殊召唤。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 将装备卡装备给特殊召唤的怪兽。
			Duel.Equip(tp,c,tc)
			-- 完成特殊召唤流程。
			Duel.SpecialSummonComplete()
			-- 检查对方是否有手卡。
			if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
				-- 中断当前效果处理。
				Duel.BreakEffect()
				-- 令对方丢弃一张手卡。
				Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
			end
		end
	end
end
