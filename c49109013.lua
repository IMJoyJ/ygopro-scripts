--魔星のウルカ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：只让自己场上的怪兽1只因对方的效果从场上离开时，把手卡·墓地的这张卡除外才能发动。那只怪兽在墓地存在的场合或者是表侧除外状态的场合，那只怪兽特殊召唤。那以外的场合，除外状态的这张卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。这张卡的攻击力直到下个回合的结束时上升1500。
local s,id,o=GetID()
-- 初始化并注册两个效果：①为场地诱发选发效果，在满足离场条件时从手卡·墓地除外自身并特殊召唤离场怪兽或自身；②为特殊召唤成功时诱发选发，使自身攻击力上升1500。
function s.initial_effect(c)
	-- ①：只让自己场上的怪兽1只因对方的效果从场上离开时，把手卡·墓地的这张卡除外才能发动。那只怪兽在墓地存在的场合或者是表侧除外状态的场合，那只怪兽特殊召唤。那以外的场合，除外状态的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	-- 设置①效果的发动代价为把这张卡从手卡或墓地除外。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合才能发动。这张卡的攻击力直到下个回合的结束时上升1500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- ①的发动条件：只有1只自己场上的怪兽因对方的效果从场上离开，且该怪兽之前由自己控制、之前位于主要怪兽区，离场的控制者变更原因为对方玩家且离场原因为效果。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return #eg==1 and tc:IsPreviousControler(tp) and tc:IsPreviousLocation(LOCATION_MZONE)
		and tc:GetReasonPlayer()==1-tp and tc:IsReason(REASON_EFFECT)
end
-- ①的发动时点合法性检查：自己主要怪兽区有空位，且离场的那只怪兽可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	-- 效果发动时确认自己场上主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local c=e:GetHandler()
	c:CreateEffectRelation(e)
	-- 将离场的那只怪兽设为效果关联对象，用于后续处理时确认其仍与本效果相关。
	Duel.SetTargetCard(tc)
	local g=Group.FromCards(c,tc)
	-- 声明本次连锁将进行1只怪兽的特殊召唤，处理对象可能是离场怪兽或除外状态的这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：若对象怪兽仍与效果关联且位于墓地或表侧除外区，则特殊召唤该怪兽（并处理王家长眠之谷的无效）；否则若自身仍在除外区，则特殊召唤这张卡自身。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理对象，即之前离场的那只怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and tc:IsFaceupEx() then
		-- 检查对象怪兽是否受王家长眠之谷影响，若是则本次特殊召唤被无效并直接结束处理。
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 将符合条件的离场怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif c:IsRelateToEffect(e) and c:IsLocation(LOCATION_REMOVED) then
		-- 将除外状态的这张卡自身以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果处理：自己特殊召唤成功时，给自身附加攻击力上升1500的效果，持续到下个回合结束。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or c:IsFacedown() then return end
	-- 这张卡的攻击力直到下个回合的结束时上升1500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
	e1:SetValue(1500)
	c:RegisterEffect(e1)
end
