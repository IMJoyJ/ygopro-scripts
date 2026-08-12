--サイバー・ジムナティクス
-- 效果：
-- ①：1回合1次，丢弃1张手卡，以对方场上1只表侧攻击表示怪兽为对象才能发动。那只对方的表侧攻击表示怪兽破坏。
function c76763417.initial_effect(c)
	-- ①：1回合1次，丢弃1张手卡，以对方场上1只表侧攻击表示怪兽为对象才能发动。那只对方的表侧攻击表示怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76763417,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c76763417.descost)
	e1:SetTarget(c76763417.destg)
	e1:SetOperation(c76763417.desop)
	c:RegisterEffect(e1)
end
-- 发动的代价（Cost）处理：丢弃1张手卡
function c76763417.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查手牌中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中丢弃1张卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：处于表侧攻击表示的卡
function c76763417.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
-- 效果的目标（Target）处理：选择对方场上1只表侧攻击表示怪兽作为对象
function c76763417.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c76763417.filter(chkc) end
	-- 在发动阶段（chk==0）检查对方场上是否存在符合条件的表侧攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c76763417.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1只表侧攻击表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c76763417.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表明此效果将破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果的运行（Operation）处理：破坏作为对象的怪兽
function c76763417.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取已成为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsPosition(POS_FACEUP_ATTACK) and tc:IsRelateToEffect(e) then
		-- 因效果将该对象怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
