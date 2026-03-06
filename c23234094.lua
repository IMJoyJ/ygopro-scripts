--エヴォルダー・エリアス
-- 效果：
-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，可以从手卡把1只恐龙族·炎属性·6星以下的怪兽特殊召唤。
function c23234094.initial_effect(c)
	-- 效果原文内容：这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，可以从手卡把1只恐龙族·炎属性·6星以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23234094,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 规则层面作用：判断此卡是否由带有「进化虫」的怪兽的效果特殊召唤成功
	e1:SetCondition(aux.evospcon)
	e1:SetTarget(c23234094.sptg)
	e1:SetOperation(c23234094.spop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：定义可用于特殊召唤的怪兽的过滤条件，包括等级不超过6星、种族为恐龙族、属性为炎、且可以被特殊召唤
function c23234094.filter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_DINOSAUR) and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置效果的发动条件，检查玩家场上是否有空位以及手牌中是否存在满足条件的怪兽
function c23234094.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查玩家手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c23234094.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面作用：设置连锁处理信息，表明此效果将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 规则层面作用：定义效果发动后的处理流程，包括检查场上空位、提示选择、选择目标怪兽并进行特殊召唤
function c23234094.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查玩家场上是否还有空位，如果没有则不继续处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：向玩家发送提示信息，提示其选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：从玩家手牌中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c23234094.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
