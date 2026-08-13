--エヴォルダー・エリアス
-- 效果：
-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，可以从手卡把1只恐龙族·炎属性·6星以下的怪兽特殊召唤。
function c23234094.initial_effect(c)
	-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，可以从手卡把1只恐龙族·炎属性·6星以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23234094,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置效果的发动条件：仅当这张卡是用名字带有「进化虫」的怪兽的效果特殊召唤成功时，该效果才满足发动条件。
	e1:SetCondition(aux.evospcon)
	e1:SetTarget(c23234094.sptg)
	e1:SetOperation(c23234094.spop)
	c:RegisterEffect(e1)
end
-- 定义可选择怪兽的过滤条件：必须是恐龙族、炎属性、6星以下，且能被效果特殊召唤（不忽略召唤条件与苏生限制）。
function c23234094.filter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_DINOSAUR) and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的条件检查（chk==0）：确认自己场上存在可用怪兽区，且手牌中至少有1只符合条件的怪兽，才允许发动。
function c23234094.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己的主要怪兽区是否有可用的空格，用于放置将要特殊召唤的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足filter条件的恐龙族·炎属性·6星以下的怪兽，作为特殊召唤的候选目标。
		and Duel.IsExistingMatchingCard(c23234094.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本效果的操作信息：效果处理时将进行特殊召唤，预期从手牌特殊召唤1只怪兽（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果解决时的处理：若仍有可用怪兽区，则提示玩家选择手牌中符合条件的1只怪兽，并将其特殊召唤到场上。
function c23234094.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己的主要怪兽区是否有空位；没有空位则直接终止处理，无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示信息，辅助后续手牌选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手牌中选择1只满足filter条件的恐龙族·炎属性·6星以下的怪兽，作为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c23234094.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区，并正常检查其召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
