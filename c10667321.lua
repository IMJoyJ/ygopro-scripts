--古のルール
-- 效果：
-- 从手卡把1只5星以上的通常怪兽特殊召唤。
function c10667321.initial_effect(c)
	-- 从手卡把1只5星以上的通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c10667321.target)
	e1:SetOperation(c10667321.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断手卡中是否满足条件的怪兽
function c10667321.filter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的处理目标函数，用于确认是否可以发动此效果
function c10667321.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡中是否存在至少1只5星以上且为通常怪兽的卡片
		and Duel.IsExistingMatchingCard(c10667321.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置此效果发动时将要处理的卡片信息为1只手卡中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果的处理函数，用于执行特殊召唤操作
function c10667321.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从玩家手卡中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c10667321.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
