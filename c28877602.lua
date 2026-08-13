--エヴォルド・オドケリス
-- 效果：
-- 这张卡召唤成功时，可以从手卡把1只名字带有「进化龙」的怪兽特殊召唤。
function c28877602.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡把1只名字带有「进化龙」的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28877602,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c28877602.sumtg)
	e2:SetOperation(c28877602.sumop)
	c:RegisterEffect(e2)
end
-- 筛选条件：手卡中满足名字带有「进化龙」且可以被当前效果特殊召唤的怪兽。
function c28877602.filter(c,e,tp)
	return c:IsSetCard(0x604e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标判定阶段：确认自己怪兽区域有空位且手卡存在符合条件的「进化龙」怪兽，满足条件才可发动。
function c28877602.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否还有可用的主要怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足「进化龙」且可被特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c28877602.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果处理的操作信息：将从手卡特殊召唤1只怪兽（不取对象，处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理阶段：若仍有可用怪兽区域，则从手卡选择1只符合条件的「进化龙」怪兽进行特殊召唤。
function c28877602.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否有可用的主要怪兽区域，若没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发出“请选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只符合筛选条件的「进化龙」怪兽。
	local g=Duel.SelectMatchingCard(tp,c28877602.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
