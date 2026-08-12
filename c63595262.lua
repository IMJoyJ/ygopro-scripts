--ユニコーンの導き
-- 效果：
-- 选择从游戏中除外的1只5星以下的兽族或者鸟兽族怪兽发动。把1张手卡从游戏中除外，选择的怪兽攻击表示特殊召唤。
function c63595262.initial_effect(c)
	-- 选择从游戏中除外的1只5星以下的兽族或者鸟兽族怪兽发动。把1张手卡从游戏中除外，选择的怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c63595262.target)
	e1:SetOperation(c63595262.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：除外状态的表侧表示、5星以下、兽族或鸟兽族且能以攻击表示特殊召唤的怪兽
function c63595262.filter(c,e,tp)
	return c:IsFaceup() and c:IsLevelBelow(5) and c:IsRace(RACE_BEAST+RACE_WINDBEAST)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动时的对象选择与可行性检查
function c63595262.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c63595262.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在可以除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 检查除外区是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(c63595262.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外区1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c63595262.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	-- 设置效果处理信息：从手牌除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	-- 设置效果处理信息：特殊召唤选择的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数
function c63595262.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择手牌中1张要除外的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 将选择的手牌表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
