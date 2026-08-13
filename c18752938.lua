--偽りの種
-- 效果：
-- 从手卡把1只2星以下的植物族怪兽特殊召唤。
function c18752938.initial_effect(c)
	-- 从手卡把1只2星以下的植物族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c18752938.target)
	e1:SetOperation(c18752938.activate)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤对象的筛选条件：怪兽必须为等级2以下的植物族，且可以被效果特殊召唤。
function c18752938.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性判定：确认我方主要怪兽区有空位，且手牌中存在符合条件的植物族怪兽。
function c18752938.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否存在可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张满足筛选条件的植物族怪兽。
		and Duel.IsExistingMatchingCard(c18752938.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果涉及从手卡特殊召唤1只怪兽，系统据此进行相关时点/卡片的联动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理流程：若场地仍有空位，则提示玩家选择手牌中符合条件的1只植物族怪兽，并将其特殊召唤。
function c18752938.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查我方主要怪兽区是否有空位，若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发出选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手牌中选择1张满足 c18752938.filter 条件的植物族怪兽。
	local g=Duel.SelectMatchingCard(tp,c18752938.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到我方主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
