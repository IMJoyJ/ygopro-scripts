--セイクリッド・スピカ
-- 效果：
-- 这张卡召唤成功时，可以从手卡把1只名字带有「星圣」的5星怪兽表侧守备表示特殊召唤。
function c40143123.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡把1只名字带有「星圣」的5星怪兽表侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40143123,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c40143123.sptg)
	e2:SetOperation(c40143123.spop)
	c:RegisterEffect(e2)
	c40143123.star_knight_summon_effect=e2
end
-- 过滤函数，用于筛选手卡中满足条件的「星圣」5星怪兽
function c40143123.filter(c,e,tp)
	return c:IsSetCard(0x53) and c:IsLevel(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果的处理目标函数，判断是否可以发动此效果
function c40143123.sptg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 检查玩家场上是否有可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c40143123.filter,tp,LOCATION_HAND,0,1,exc,e,tp) end
	-- 设置效果发动时的操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果的处理函数，执行特殊召唤操作
function c40143123.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认玩家场上是否有可用怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡中选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c40143123.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
