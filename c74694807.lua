--再融合
-- 效果：
-- ①：支付800基本分，以自己墓地1只融合怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。这张卡破坏时那只怪兽除外。
function c74694807.initial_effect(c)
	-- ①：支付800基本分，以自己墓地1只融合怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c74694807.cost)
	e1:SetTarget(c74694807.target)
	e1:SetOperation(c74694807.operation)
	c:RegisterEffect(e1)
	-- 这张卡破坏时那只怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c74694807.rmop)
	c:RegisterEffect(e2)
end
-- 定义发动代价，检查并支付800基本分
function c74694807.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800)
	-- 在发动处理时，让玩家支付800基本分
	else Duel.PayLPCost(tp,800)	end
end
-- 过滤自己墓地可以特殊召唤的融合怪兽
function c74694807.filter(c,e,tp)
	return bit.band(c:GetType(),0x41)==0x41 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义发动效果的目标，选择自己墓地1只融合怪兽
function c74694807.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74694807.filter(chkc,e,tp) end
	-- 在发动检查时，确认自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动检查时，确认自己墓地是否存在符合条件的融合怪兽
		and Duel.IsExistingTarget(c74694807.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只符合条件的融合怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c74694807.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，用于连锁处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置装备卡的操作信息，用于连锁处理
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 定义装备限制，使这张卡只能装备给该效果特殊召唤的怪兽
function c74694807.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 定义效果处理，特殊召唤目标怪兽并装备这张卡
function c74694807.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤，若特殊召唤失败则不进行后续处理
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 将这张卡装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c74694807.eqlimit)
		c:RegisterEffect(e1)
	end
end
-- 定义这张卡离场时的效果处理，若被破坏则将装备的怪兽除外
function c74694807.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if c:IsReason(REASON_DESTROY) and tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将装备的怪兽表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
