--フォトン・カイザー
-- 效果：
-- 这张卡召唤·反转召唤成功时，可以从自己的手卡·卡组把1只「光子帝王」特殊召唤。
function c13492423.initial_effect(c)
	-- 这张卡召唤·反转召唤成功时，可以从自己的手卡·卡组把1只「光子帝王」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13492423,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c13492423.sptg)
	e1:SetOperation(c13492423.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否可以特殊召唤
function c13492423.filter(c,e,tp)
	return c:IsCode(13492423) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理函数，用于设置效果目标
function c13492423.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡或卡组中是否存在满足条件的「光子帝王」
		and Duel.IsExistingMatchingCard(c13492423.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果发动时的处理函数，用于执行效果操作
function c13492423.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的「光子帝王」卡片
	local g=Duel.SelectMatchingCard(tp,c13492423.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡片特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
