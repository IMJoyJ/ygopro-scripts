--ウィジェット・キッド
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把1只电子界族怪兽守备表示特殊召唤。
function c10705656.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10705656,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,10705656)
	e1:SetTarget(c10705656.sptg)
	e1:SetOperation(c10705656.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查手卡中是否存在满足条件的电子界族怪兽
function c10705656.filter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果的处理目标函数，用于判断是否可以发动此效果
function c10705656.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位以及手卡中是否存在满足条件的电子界族怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在满足条件的电子界族怪兽
		and Duel.IsExistingMatchingCard(c10705656.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果的处理函数，用于执行特殊召唤操作
function c10705656.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位以进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从手卡中选择一只满足条件的电子界族怪兽
	local g=Duel.SelectMatchingCard(tp,c10705656.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的电子界族怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
