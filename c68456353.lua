--エクストリオの牙
-- 效果：
-- 自己场上有名字带有「自然」的怪兽表侧表示存在的场合才能发动。对方发动的魔法·陷阱卡的发动无效并破坏。那之后，把自己1张手卡送去墓地。
function c68456353.initial_effect(c)
	-- 自己场上有名字带有「自然」的怪兽表侧表示存在的场合才能发动。对方发动的魔法·陷阱卡的发动无效并破坏。那之后，把自己1张手卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c68456353.condition)
	e1:SetTarget(c68456353.target)
	e1:SetOperation(c68456353.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「自然」怪兽
function c68456353.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a)
end
-- 发动条件：对方发动魔陷且自己场上有表侧表示的「自然」怪兽
function c68456353.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查连锁中发动的效果是否为对方发动的魔法·陷阱卡的发动，且该发动能否被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==1-tp and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在至少1只表侧表示的「自然」怪兽
		and Duel.IsExistingMatchingCard(c68456353.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的合法性检测与操作信息注册
function c68456353.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检测自己手卡数量是否大于0（因为后续处理必须能将手卡送去墓地）
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	-- 设置操作信息：无效该魔法·陷阱卡的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该魔法·陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	-- 设置操作信息：将自己1张手卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：无效并破坏对方魔陷，之后将自己1张手卡送去墓地
function c68456353.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该发动的卡，若成功且该卡与该效果仍有联系，则执行破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
	-- 让玩家选择并以效果原因将自己1张手卡送去墓地
	Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT,nil)
end
