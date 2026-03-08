--継承の印
-- 效果：
-- 自己墓地有3张同名怪兽卡存在时发动。选择那些怪兽的其中1只在自己场上特殊召唤，并装备这张卡。这张卡破坏时，装备怪兽破坏。
function c45305419.initial_effect(c)
	-- 效果原文：自己墓地有3张同名怪兽卡存在时发动。选择那些怪兽的其中1只在自己场上特殊召唤，并装备这张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c45305419.target)
	e1:SetOperation(c45305419.operation)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡破坏时，装备怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c45305419.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查墓地中的怪兽是否可以特殊召唤且自己墓地存在两张同名怪兽卡
function c45305419.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己墓地是否存在两张同名怪兽卡
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,2,c,c:GetCode())
end
-- 效果处理：设置选择目标，检查是否满足特殊召唤条件
function c45305419.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45305419.filter(chkc,e,tp) end
	-- 检查自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c45305419.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c45305419.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息：装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备对象限制函数：只能装备给此卡
function c45305419.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理：将目标怪兽特殊召唤并装备此卡，设置装备限制
function c45305419.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 将此卡装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 设置装备对象限制效果，防止被其他卡装备
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c45305419.eqlimit)
		c:RegisterEffect(e1)
	end
end
-- 效果处理：当此卡被破坏时，破坏装备的怪兽
function c45305419.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if c:IsReason(REASON_DESTROY) and tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将装备的怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
