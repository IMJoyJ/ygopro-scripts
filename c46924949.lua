--縄張恐竜
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在主要怪兽区域存在，额外怪兽区域的怪兽的效果无效化。
-- ②：这张卡被战斗破坏时才能发动。从卡组把1只「领地恐龙」特殊召唤。
function c46924949.initial_effect(c)
	-- 效果原文内容：①：只要这张卡在主要怪兽区域存在，额外怪兽区域的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(c46924949.discon)
	e1:SetTarget(c46924949.distg)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡被战斗破坏时才能发动。从卡组把1只「领地恐龙」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCountLimit(1,46924949)
	e2:SetTarget(c46924949.sptg)
	e2:SetOperation(c46924949.spop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断当前卡片是否在主要怪兽区域（序号小于5）
function c46924949.discon(e)
	return e:GetHandler():GetSequence()<5
end
-- 规则层面作用：判断目标怪兽是否在额外怪兽区域（序号大于4）
function c46924949.distg(e,c)
	return c:GetSequence()>4
end
-- 规则层面作用：过滤满足条件的「领地恐龙」卡片，用于特殊召唤
function c46924949.spfilter(c,e,tp)
	return c:IsCode(46924949) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：检查是否满足发动条件，包括场上是否有空位和卡组中是否存在符合条件的卡片
function c46924949.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查卡组中是否存在至少一张符合条件的「领地恐龙」
		and Duel.IsExistingMatchingCard(c46924949.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面作用：设置连锁操作信息，表明将要特殊召唤1张来自卡组的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：执行特殊召唤操作，从卡组选择并特殊召唤符合条件的卡片
function c46924949.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断场上是否还有空位用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：从卡组中选择一张符合条件的「领地恐龙」
	local g=Duel.SelectMatchingCard(tp,c46924949.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的卡片正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
