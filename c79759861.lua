--死者への手向け
-- 效果：
-- ①：丢弃1张手卡，以场上1只怪兽为对象才能发动。那只怪兽破坏。
function c79759861.initial_effect(c)
	-- ①：丢弃1张手卡，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c79759861.cost)
	e1:SetTarget(c79759861.target)
	e1:SetOperation(c79759861.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价，检查并执行丢弃1张手卡的操作
function c79759861.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手卡中是否存在至少1张可以丢弃的卡（排除自身）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家从手卡中选择1张卡丢弃送去墓地作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义效果的目标，进行取对象判定并选择要破坏的怪兽
function c79759861.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 在发动阶段检查双方场上是否存在至少1只可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表明此效果将破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果处理，将选中的对象怪兽破坏
function c79759861.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
