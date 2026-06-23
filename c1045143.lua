--ギアギアーノ Mk－Ⅱ
-- 效果：
-- 这张卡召唤·反转召唤成功时，可以从自己的手卡·墓地选1只名字带有「齿轮齿轮」的怪兽表侧守备表示特殊召唤。
function c1045143.initial_effect(c)
	-- 这张卡通常召唤成功时，可以发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1045143,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c1045143.sptg)
	e1:SetOperation(c1045143.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检测满足条件的怪兽
function c1045143.filter(c,e,tp)
	return c:IsSetCard(0x72) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果的发动时点处理函数
function c1045143.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c1045143.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果的处理函数
function c1045143.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有特殊召唤怪兽的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1045143.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
