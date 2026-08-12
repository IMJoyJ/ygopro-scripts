--蛇神の勅命
-- 效果：
-- 把手卡1张名字带有「蛇毒」的怪兽卡给对方观看发动。对方的魔法卡的发动和效果无效，并把那个破坏。
function c80678380.initial_effect(c)
	-- 把手卡1张名字带有「蛇毒」的怪兽卡给对方观看发动。对方的魔法卡的发动和效果无效，并把那个破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c80678380.condition)
	e1:SetCost(c80678380.cost)
	e1:SetTarget(c80678380.target)
	e1:SetOperation(c80678380.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：对方发动魔法卡时
function c80678380.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的魔法卡的发动，且该连锁的发动可以被无效
	return ep~=tp and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 过滤条件：手卡中未公开的「蛇毒」怪兽
function c80678380.cfilter(c)
	return c:IsSetCard(0x50) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 发动代价：展示手卡中1张「蛇毒」怪兽
function c80678380.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手卡中是否存在可展示的「蛇毒」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c80678380.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手卡中1张「蛇毒」怪兽
	local g=Duel.SelectMatchingCard(tp,c80678380.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡给对方确认
	Duel.ConfirmCards(1-tp,g)
	-- 洗切手卡
	Duel.ShuffleHand(tp)
end
-- 靶向/操作信息设置：确认无效与破坏的对象
function c80678380.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效该卡的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该卡可被破坏且仍关联，设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使发动无效并破坏
function c80678380.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功无效该卡的发动，且该卡仍与效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
