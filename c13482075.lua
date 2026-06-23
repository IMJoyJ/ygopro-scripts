--ヴェンデット・キマイラ
-- 效果：
-- 「复仇死者」仪式魔法卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：要让场上的卡破坏的魔法·陷阱·怪兽的效果发动时，从自己墓地把1只不死族怪兽除外才能发动。那个发动无效并破坏。
-- ②：这张卡为仪式召唤而被解放或者除外的场合发动。对方场上的全部怪兽的攻击力·守备力下降500。
function c13482075.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：要让场上的卡破坏的魔法·陷阱·怪兽的效果发动时，从自己墓地把1只不死族怪兽除外才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13482075,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,13482075)
	e1:SetCondition(c13482075.condition)
	e1:SetCost(c13482075.cost)
	e1:SetTarget(c13482075.target)
	e1:SetOperation(c13482075.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡为仪式召唤而被解放或者除外的场合发动。对方场上的全部怪兽的攻击力·守备力下降500。
	local e2=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13482075,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,13482076)
	e2:SetCondition(c13482075.atkcon)
	e2:SetOperation(c13482075.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- 判断连锁是否可以被无效
function c13482075.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若此卡已在战斗破坏状态或连锁不能被无效则效果不发动
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 若连锁效果为无效效果且其发动为永续魔法则不发动
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取连锁的破坏效果信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- 过滤器函数：检查墓地是否有不死族怪兽
function c13482075.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
-- 支付效果代价：从墓地除外1只不死族怪兽
function c13482075.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足支付代价条件
	if chk==0 then return Duel.IsExistingMatchingCard(c13482075.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择1只不死族怪兽
	local g=Duel.SelectMatchingCard(tp,c13482075.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的不死族怪兽除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果处理目标
function c13482075.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数
function c13482075.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效并判断是否可以破坏对象
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏连锁对象
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 判断此卡是否因仪式召唤而被解放或除外
function c13482075.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RITUAL)
end
-- 效果处理函数：使对方场上所有表侧表示怪兽攻击力守备力下降500
function c13482075.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 遍历所有表侧表示怪兽
	for tc in aux.Next(g) do
		-- 给目标怪兽攻击力下降500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetValue(-500)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
