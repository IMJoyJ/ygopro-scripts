--バーニングナックル・スピリッツ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把卡组最上面的卡送去墓地，以自己墓地1只「燃烧拳击手」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c36916401.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
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
-- 效果作用：支付1张卡组最上面的卡送去墓地的费用。
function c36916401.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否能作为Cost把1张卡送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	-- 效果作用：将玩家1张卡组最上面的卡送去墓地。
	Duel.DiscardDeck(tp,1,REASON_COST)
end
-- 效果作用：过滤满足条件的「燃烧拳击手」怪兽。
function c36916401.filter(c,e,tp)
	return c:IsSetCard(0x1084) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果作用：设置效果的目标为玩家墓地的「燃烧拳击手」怪兽。
function c36916401.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36916401.filter(chkc,e,tp) end
	-- 效果作用：检查玩家场上是否有可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查玩家墓地是否存在满足条件的「燃烧拳击手」怪兽。
		and Duel.IsExistingTarget(c36916401.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的1只「燃烧拳击手」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c36916401.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 效果作用：设置效果处理信息为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用：将选中的「燃烧拳击手」怪兽守备表示特殊召唤。
function c36916401.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果作用：将对象卡以守备表示特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
