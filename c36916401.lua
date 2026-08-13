--バーニングナックル・スピリッツ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把卡组最上面的卡送去墓地，以自己墓地1只「燃烧拳击手」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c36916401.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把卡组最上面的卡送去墓地，以自己墓地1只「燃烧拳击手」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,36916401+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c36916401.cost)
	e1:SetTarget(c36916401.target)
	e1:SetOperation(c36916401.operation)
	c:RegisterEffect(e1)
end
-- 代价处理：检查是否能将卡组最上方1张卡作为代价送去墓地；若能，则实际执行该代价。
function c36916401.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：判定玩家是否能把卡组最上方1张卡作为代价送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	-- 执行代价：将卡组最上方1张卡以代价原因送去墓地。
	Duel.DiscardDeck(tp,1,REASON_COST)
end
-- 对象筛选条件：选择自己墓地中「燃烧拳击手」怪兽，且该怪兽能够以表侧守备表示特殊召唤。
function c36916401.filter(c,e,tp)
	return c:IsSetCard(0x1084) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动目标设定：检查是否满足发动条件（有可用怪兽区、存在可选对象），并选择自己墓地1只符合条件的「燃烧拳击手」怪兽作为效果对象。
function c36916401.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36916401.filter(chkc,e,tp) end
	-- 检查自己场上是否存在可用的主要怪兽区，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在1只满足条件的「燃烧拳击手」怪兽能够成为效果对象。
		and Duel.IsExistingTarget(c36916401.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的「燃烧拳击手」怪兽，并将其设定为本次效果的对象。
	local g=Duel.SelectTarget(tp,c36916401.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次效果的操作信息：包含特殊召唤分类，对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：获取效果对象，若对象仍与效果关联，则将其以表侧守备表示特殊召唤。
function c36916401.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果处理时的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
