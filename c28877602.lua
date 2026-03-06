--エヴォルド・オドケリス
-- 效果：
-- 这张卡召唤成功时，可以从手卡把1只名字带有「进化龙」的怪兽特殊召唤。
function c28877602.initial_effect(c)
	-- 诱发选发效果，通常召唤成功时发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28877602,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c28877602.sumtg)
	e2:SetOperation(c28877602.sumop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中名字带有「进化龙」且可以特殊召唤的怪兽
function c28877602.filter(c,e,tp)
	return c:IsSetCard(0x604e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理，判断是否满足发动条件
function c28877602.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c28877602.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果发动时的处理，执行特殊召唤操作
function c28877602.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有可用怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c28877602.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
