--自律行動ユニット
-- 效果：
-- ①：支付1500基本分，以对方墓地1只怪兽为对象才能把这张卡发动。那只怪兽在自己场上攻击表示特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
function c71453557.initial_effect(c)
	-- ①：支付1500基本分，以对方墓地1只怪兽为对象才能把这张卡发动。那只怪兽在自己场上攻击表示特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c71453557.cost)
	e1:SetTarget(c71453557.target)
	e1:SetOperation(c71453557.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c71453557.desop)
	c:RegisterEffect(e2)
end
-- 发动代价（Cost）处理：检查并支付1500基本分
function c71453557.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能够支付1500基本分
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	-- 支付1500基本分
	Duel.PayLPCost(tp,1500)
end
-- 效果发动时的目标选择与合法性检查：如果是作为已选择的对象，检查该卡是否仍在对方墓地且能以表侧攻击表示特殊召唤
function c71453557.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:GetControler()==1-tp
		and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查对方墓地是否存在可以表侧攻击表示特殊召唤的怪兽
		and Duel.IsExistingTarget(Card.IsCanBeSpecialSummoned,tp,0,LOCATION_GRAVE,1,nil,e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置提示信息为：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只可以表侧攻击表示特殊召唤的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsCanBeSpecialSummoned,tp,0,LOCATION_GRAVE,1,1,nil,e,0,tp,false,false,POS_FACEUP_ATTACK)
	-- 设置连锁信息：包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置连锁信息：包含将这张卡装备的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 定义装备限制：该装备卡只能装备给此效果特殊召唤的怪兽
function c71453557.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理：将对象怪兽特殊召唤并装备这张卡，同时设置装备限制
function c71453557.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将对象怪兽在自己场上表侧攻击表示特殊召唤，若特殊召唤失败则处理终止
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)==0 then return end
		-- 将这张卡装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c71453557.eqlimit)
		c:RegisterEffect(e1)
	end
end
-- 离场时效果处理：获取这张卡装备的怪兽，若其仍在怪兽区，则将其破坏
function c71453557.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
