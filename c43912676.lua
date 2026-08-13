--異層空間
-- 效果：
-- ①：场上的幻龙族怪兽的攻击力·守备力上升300。
-- ②：1回合1次，把自己墓地3只幻龙族怪兽除外，以场上1张卡为对象才能发动。那张卡破坏。
function c43912676.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的幻龙族怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置此永续效果只对场上的幻龙族怪兽适用。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WYRM))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，把自己墓地3只幻龙族怪兽除外，以场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(43912676,0))  --"卡片破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c43912676.cost)
	e4:SetTarget(c43912676.target)
	e4:SetOperation(c43912676.operation)
	c:RegisterEffect(e4)
end
-- 该过滤函数判断一张卡是否为幻龙族怪兽且可作为发动代价除外。
function c43912676.cfilter(c)
	return c:IsRace(RACE_WYRM) and c:IsAbleToRemoveAsCost()
end
-- 该代价处理：从自己墓地选择3只幻龙族怪兽除外，作为发动本效果的代价。
function c43912676.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少3只符合条件的幻龙族怪兽，若不足则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c43912676.cfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 向玩家显示提示，让其选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择3只符合条件的幻龙族怪兽。
	local g=Duel.SelectMatchingCard(tp,c43912676.cfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 将选择的3只幻龙族怪兽以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 该取对象处理：选择场上的1张卡作为要破坏的对象，并进行相关判定。
function c43912676.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在至少1张可以被选择为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示提示，让其选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张卡作为本效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表明本次效果将破坏1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 该效果处理：将对象卡破坏。
function c43912676.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
