--暗黒界の援軍
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只4星以下的恶魔族怪兽为对象才能发动。那只怪兽特殊召唤。那之后，从手卡选1只恶魔族怪兽丢弃。
function c85325774.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只4星以下的恶魔族怪兽为对象才能发动。那只怪兽特殊召唤。那之后，从手卡选1只恶魔族怪兽丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,85325774+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c85325774.target)
	e1:SetOperation(c85325774.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：等级4以下且可以特殊召唤的恶魔族怪兽
function c85325774.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与可行性检查
function c85325774.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c85325774.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的恶魔族怪兽
		and Duel.IsExistingTarget(c85325774.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己手卡是否存在至少1只恶魔族怪兽以满足后续丢弃的条件
		and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_HAND,0,1,nil,RACE_FIEND) end
	-- 设置提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的恶魔族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c85325774.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息：从手卡丢弃1张卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,1)
end
-- 效果处理：特殊召唤目标怪兽，那之后从手卡丢弃1只恶魔族怪兽
function c85325774.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合条件，则将其在自己场上表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断效果处理，使后续的丢弃手卡与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 从手卡选择1只恶魔族怪兽因效果丢弃
		Duel.DiscardHand(tp,Card.IsRace,1,1,REASON_EFFECT+REASON_DISCARD,nil,RACE_FIEND)
	end
end
