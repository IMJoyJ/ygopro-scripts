--デストラクション・ジャマー
-- 效果：
-- 丢弃1张手卡。持有（把场上的怪兽破坏的效果）的卡的发动无效并破坏。
function c98956134.initial_effect(c)
	-- 丢弃1张手卡。持有（把场上的怪兽破坏的效果）的卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c98956134.condition)
	e1:SetCost(c98956134.cost)
	e1:SetTarget(c98956134.target)
	e1:SetOperation(c98956134.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查被连锁的效果是否可以被无效，且该效果是否包含破坏场上怪兽的效果
function c98956134.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁的发动是否可以被无效
	if not Duel.IsChainNegatable(ev) then return false end
	-- 获取当前连锁中关于破坏分类的操作信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)-tg:GetCount()>0
end
-- 代价：丢弃1张手卡
function c98956134.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否受到免除丢弃手卡代价效果的影响（如解放之阿里阿德涅）
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then return true end
	-- 在发动阶段，检查手卡中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡中丢弃1张卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 目标：设置无效发动和破坏的操作信息
function c98956134.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动效果的卡可被破坏且仍与效果相关联，则设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使发动无效并破坏
function c98956134.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且发动效果的卡仍与效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动效果的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
