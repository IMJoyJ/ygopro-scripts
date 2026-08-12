--ブラック・コア
-- 效果：
-- 丢弃1张手卡。将场上1只表侧表示的怪兽从游戏中除外。
function c70231910.initial_effect(c)
	-- 丢弃1张手卡。将场上1只表侧表示的怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c70231910.cost)
	e1:SetTarget(c70231910.target)
	e1:SetOperation(c70231910.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价：丢弃1张手卡
function c70231910.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可丢弃的卡作为代价
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：场上表侧表示且可以被除外的怪兽
function c70231910.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 定义效果的目标选择：选择场上1只表侧表示的怪兽作为对象
function c70231910.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c70231910.filter(chkc) end
	-- 检查场上是否存在可以作为除外对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c70231910.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1只表侧表示的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c70231910.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示此效果会除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 定义效果处理：将选择的对象怪兽除外
function c70231910.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
