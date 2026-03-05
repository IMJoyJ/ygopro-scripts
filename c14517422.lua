--堕天使の戒壇
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地把1只「堕天使」怪兽守备表示特殊召唤。
function c14517422.initial_effect(c)
	-- ①：从自己墓地把1只「堕天使」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,14517422+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c14517422.sptg)
	e1:SetOperation(c14517422.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断墓地中的怪兽是否为堕天使族且可以被特殊召唤到守备表示
function c14517422.filter(c,e,tp)
	return c:IsSetCard(0xef) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果的发动时点处理函数，用于判断是否满足发动条件
function c14517422.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在至少1只符合条件的堕天使族怪兽
		and Duel.IsExistingMatchingCard(c14517422.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果的发动处理函数，用于执行特殊召唤操作
function c14517422.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从玩家墓地中选择1只符合条件的堕天使族怪兽
	local g=Duel.SelectMatchingCard(tp,c14517422.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
