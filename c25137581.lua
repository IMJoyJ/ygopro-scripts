--潜伏するG
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方对怪兽的特殊召唤成功时才能发动。这张卡从手卡里侧守备表示特殊召唤。这个效果特殊召唤的这张卡在这个回合的结束阶段变成表侧守备表示。
-- ②：这张卡在结束阶段反转的场合发动。场上的特殊召唤的怪兽全部破坏。
local s,id,o=GetID()
-- 创建效果，注册两个效果：①特殊召唤效果和②反转时破坏效果
function s.initial_effect(c)
	-- ①：对方对怪兽的特殊召唤成功时才能发动。这张卡从手卡里侧守备表示特殊召唤。这个效果特殊召唤的这张卡在这个回合的结束阶段变成表侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在结束阶段反转的场合发动。场上的特殊召唤的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 判断是否为对方特殊召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 判断是否满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤操作，包括确认卡片、注册flag、设置结束阶段反转效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否还在连锁中且特殊召唤成功
	if c:IsRelateToChain() and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE) then
		-- 向对方确认特殊召唤的卡片
		Duel.ConfirmCards(1-tp,c)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 注册结束阶段反转效果，使特殊召唤的卡片在结束阶段变为表侧守备表示
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetOperation(s.flipup)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将结束阶段反转效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 反转时触发的效果函数，将卡片变为表侧守备表示
function s.flipup(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	-- 如果flag存在则改变卡片表示形式为表侧守备表示
	if c:GetFlagEffect(id)>0 then Duel.ChangePosition(c,POS_FACEUP_DEFENSE) end
	e:Reset()
end
-- 判断是否在结束阶段
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为结束阶段
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 设置破坏效果的目标
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSummonType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
	-- 设置破坏操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 执行破坏效果
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSummonType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
	-- 以效果原因破坏场上所有特殊召唤的怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
