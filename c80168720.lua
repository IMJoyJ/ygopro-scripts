--闇の訪れ
-- 效果：
-- 丢弃2张手卡。选择表侧表示的1只怪兽，变成里侧守备表示。
function c80168720.initial_effect(c)
	-- 丢弃2张手卡。选择表侧表示的1只怪兽，变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c80168720.cost)
	e1:SetTarget(c80168720.target)
	e1:SetOperation(c80168720.activate)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）：丢弃2张手卡
function c80168720.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认手牌中是否存在至少2张可以丢弃的卡（排除这张卡自身）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 玩家选择并丢弃2张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：筛选场上表侧表示且可以转为里侧表示的怪兽
function c80168720.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果的目标选择（Target）处理
function c80168720.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c80168720.filter(chkc) end
	-- 在发动检查阶段，确认双方场上是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c80168720.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 发送系统提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择双方场上1只满足过滤条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c80168720.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：此效果包含改变表示形式的操作，涉及1个对象
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理（Operation）阶段
function c80168720.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽的表示形式变更为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
