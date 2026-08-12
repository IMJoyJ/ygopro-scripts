--チェーン・リゾネーター
-- 效果：
-- ①：场上有同调怪兽存在，这张卡召唤成功时才能发动。从卡组把「锁链共鸣者」以外的1只「共鸣者」怪兽特殊召唤。
function c13764881.initial_effect(c)
	-- ①：场上有同调怪兽存在，这张卡召唤成功时才能发动。从卡组把「锁链共鸣者」以外的1只「共鸣者」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13764881,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c13764881.spcon)
	e1:SetTarget(c13764881.sptg)
	e1:SetOperation(c13764881.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查场上是否存在表侧表示的同调怪兽
function c13764881.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 效果发动的条件函数，判断场上有无同调怪兽
function c13764881.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以玩家tp来看，自己的场上是否存在至少1只表侧表示的同调怪兽
	return Duel.IsExistingMatchingCard(c13764881.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤函数，用于筛选可以特殊召唤的「共鸣者」怪兽
function c13764881.filter(c,e,tp)
	return c:IsSetCard(0x57) and not c:IsCode(13764881) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动时点处理函数，用于设置效果的目标
function c13764881.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，检查玩家tp的场上是否有可用空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查玩家tp的卡组中是否存在至少1张满足条件的「共鸣者」怪兽
		and Duel.IsExistingMatchingCard(c13764881.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果的发动处理函数，用于执行效果的处理流程
function c13764881.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家tp的场上是否还有可用空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家tp发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从玩家tp的卡组中选择1张满足条件的「共鸣者」怪兽
	local g=Duel.SelectMatchingCard(tp,c13764881.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以正面表示的形式特殊召唤到玩家tp的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
