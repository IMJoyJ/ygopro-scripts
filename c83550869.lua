--トワイライトロード・ファイター ライコウ
-- 效果：
-- ①：这张卡召唤·反转的场合，从自己的手卡·墓地把1只「光道」怪兽除外才能发动。选场上1张卡除外。
-- ②：1回合1次，这张卡以外的自己的「光道」怪兽的效果发动的场合发动。从自己卡组上面把3张卡送去墓地。
function c83550869.initial_effect(c)
	-- ①：这张卡召唤·反转的场合，从自己的手卡·墓地把1只「光道」怪兽除外才能发动。选场上1张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83550869,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCost(c83550869.rmcost)
	e1:SetTarget(c83550869.rmtg)
	e1:SetOperation(c83550869.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP)
	c:RegisterEffect(e2)
	-- ②：1回合1次，这张卡以外的自己的「光道」怪兽的效果发动的场合发动。从自己卡组上面把3张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83550869,1))
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c83550869.ddcon)
	e3:SetTarget(c83550869.ddtg)
	e3:SetOperation(c83550869.ddop)
	c:RegisterEffect(e3)
end
-- 过滤条件：手牌或墓地中可以作为代价除外的「光道」怪兽
function c83550869.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x38) and c:IsAbleToRemoveAsCost()
end
-- 效果①的代价：从自己的手牌或墓地把1只「光道」怪兽除外
function c83550869.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手牌或墓地是否存在至少1只可以作为代价除外的「光道」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c83550869.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手牌或墓地选择1只满足过滤条件的「光道」怪兽
	local g=Duel.SelectMatchingCard(tp,c83550869.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果①的靶标：检查场上是否存在可除外的卡，并设置除外操作信息
function c83550869.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查场上是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 设置当前连锁的处理信息为：除外场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
-- 效果①的处理：选场上1张卡除外
function c83550869.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择场上1张可以除外的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 为选中的卡片显示被选择的动画效果
		Duel.HintSelection(g)
		-- 将选中的卡片表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡以外的自己的「光道」怪兽的效果发动
function c83550869.ddcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc~=c
		and rc:IsSetCard(0x38) and rc:IsControler(tp)
end
-- 效果②的靶标：设置从卡组送去墓地的操作信息
function c83550869.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的处理信息为：从自己卡组上面把3张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 效果②的处理：从自己卡组上面把3张卡送去墓地
function c83550869.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己卡组最上方的3张卡送去墓地
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
