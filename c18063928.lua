--ブリキンギョ
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星怪兽特殊召唤。
function c18063928.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只4星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18063928,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c18063928.sptg)
	e1:SetOperation(c18063928.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手卡中等级为4且可以被特殊召唤的怪兽
function c18063928.filter(c,e,tp)
	return c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断，检查玩家场上是否有空位且手卡是否存在满足条件的怪兽
function c18063928.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c18063928.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的怪兽数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果的处理函数，执行特殊召唤操作
function c18063928.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有空位，若无则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c18063928.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
