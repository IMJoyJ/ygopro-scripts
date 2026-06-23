--賢者の宝石
-- 效果：
-- ①：自己场上有「黑魔术少女」存在的场合才能发动。从手卡·卡组把1只「黑魔术师」特殊召唤。
function c13604200.initial_effect(c)
	-- 为卡片注册关联卡片代码，标记该卡效果中提及了「黑魔术少女」和「黑魔术师」
	aux.AddCodeList(c,46986414,38033121)
	-- ①：自己场上有「黑魔术少女」存在的场合才能发动。从手卡·卡组把1只「黑魔术师」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c13604200.condition)
	e1:SetTarget(c13604200.target)
	e1:SetOperation(c13604200.activate)
	c:RegisterEffect(e1)
end
-- 检查场上是否存在表侧表示的「黑魔术少女」
function c13604200.cfilter(c)
	return c:IsFaceup() and c:IsCode(38033121)
end
-- 判断效果发动条件是否满足，即自己场上有「黑魔术少女」
function c13604200.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「黑魔术少女」
	return Duel.IsExistingMatchingCard(c13604200.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数，用于筛选可以特殊召唤的「黑魔术师」
function c13604200.filter(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动目标，判断是否满足发动条件
function c13604200.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件，检查手卡或卡组中是否存在可特殊召唤的「黑魔术师」
		and Duel.IsExistingMatchingCard(c13604200.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息，标记将要特殊召唤的卡为「黑魔术师」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 设置效果的发动处理函数，执行特殊召唤操作
function c13604200.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的「黑魔术师」
	local g=Duel.SelectMatchingCard(tp,c13604200.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「黑魔术师」特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
