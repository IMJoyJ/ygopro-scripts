--神の居城－ヴァルハラ
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只天使族怪兽特殊召唤。这个效果在自己场上没有怪兽存在的场合才能发动和处理。
function c1353770.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只天使族怪兽特殊召唤。这个效果在自己场上没有怪兽存在的场合才能发动和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 从手卡把1只天使族怪兽特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1353770,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c1353770.condition)
	e1:SetTarget(c1353770.target)
	e1:SetOperation(c1353770.operation)
	c:RegisterEffect(e1)
end
-- 检查自己场上是否没有怪兽
function c1353770.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤手卡中可以特殊召唤的天使族怪兽
function c1353770.filter(c,e,sp)
	return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 设置效果的发动目标
function c1353770.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在满足条件的天使族怪兽
		and Duel.IsExistingMatchingCard(c1353770.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 设置效果的发动处理流程
function c1353770.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上没有空位则不发动效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 若自己场上已有怪兽则不发动效果
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的1只天使族怪兽
	local g=Duel.SelectMatchingCard(tp,c1353770.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
