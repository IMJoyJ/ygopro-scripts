--魔星のウルカ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：只让自己场上的怪兽1只因对方的效果从场上离开时，把手卡·墓地的这张卡除外才能发动。那只怪兽在墓地存在的场合或者是表侧除外状态的场合，那只怪兽特殊召唤。那以外的场合，除外状态的这张卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。这张卡的攻击力直到下个回合的结束时上升1500。
local s,id,o=GetID()
-- 注册两个效果，分别为①和②的效果
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
	-- 将此卡从手牌或墓地除外作为费用
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
-- 判断是否满足①效果的发动条件，即只有一只己方怪兽因对方效果离场
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return #eg==1 and tc:IsPreviousControler(tp) and tc:IsPreviousLocation(LOCATION_MZONE)
		and tc:GetReasonPlayer()==1-tp and tc:IsReason(REASON_EFFECT)
end
-- 设置①效果的目标和处理条件，检查是否有足够的召唤位置并确认目标怪兽可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	-- 检查是否满足特殊召唤的条件，包括是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local c=e:GetHandler()
	c:CreateEffectRelation(e)
	-- 将目标怪兽设为连锁对象
	Duel.SetTargetCard(tc)
	local g=Group.FromCards(c,tc)
	-- 设置操作信息，表明此效果会特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理①效果的发动，根据目标怪兽状态决定是将其特殊召唤还是将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and tc:IsFaceupEx() then
		-- 检查目标怪兽是否受王家长眠之谷保护，若受保护则无效此效果
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif c:IsRelateToEffect(e) and c:IsLocation(LOCATION_REMOVED) then
		-- 将自身从除外状态特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 处理②效果的发动，使自身攻击力上升1500点直到回合结束
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or c:IsFacedown() then return end
	-- 使自身攻击力上升1500点直到回合结束
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
	e1:SetValue(1500)
	c:RegisterEffect(e1)
end
