--絶対なる幻神獣
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时，从手卡丢弃1张魔法·陷阱卡，以自己墓地1只幻神兽族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。那之后，攻击对象转移为那只怪兽。
-- ②：自己场上有幻神兽族怪兽存在的场合，结束阶段才能发动。把这个回合在场上让效果发动的对方场上的表侧表示的卡全部破坏。
function c32247099.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方怪兽的攻击宣言时，从手卡丢弃1张魔法·陷阱卡，以自己墓地1只幻神兽族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。那之后，攻击对象转移为那只怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32247099,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,32247099)
	e2:SetCondition(c32247099.spcon)
	e2:SetCost(c32247099.spcost)
	e2:SetTarget(c32247099.sptg)
	e2:SetOperation(c32247099.spop)
	c:RegisterEffect(e2)
	-- ②：自己场上有幻神兽族怪兽存在的场合，结束阶段才能发动。把这个回合在场上让效果发动的对方场上的表侧表示的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32247099,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,32247100)
	e3:SetCondition(c32247099.descon)
	e3:SetTarget(c32247099.destg)
	e3:SetOperation(c32247099.desop)
	c:RegisterEffect(e3)
	if not c32247099.global_check then
		c32247099.global_check=true
		-- 用于记录和统计在场上发动的效果次数，以实现①②效果1回合各能使用1次的限制。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(c32247099.checkop1)
		-- 将效果ge1注册给玩家0（通常为场上的玩家），使其生效。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_CHAIN_NEGATED)
		ge2:SetOperation(c32247099.checkop2)
		-- 将效果ge2注册给玩家0（通常为场上的玩家），使其生效。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 当有连锁发动时，为发动的卡牌记录一个标记，用于统计该卡在本回合发动的次数。
function c32247099.checkop1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) then
		local ct=rc:GetFlagEffectLabel(32247099)
		if not ct then
			rc:RegisterFlagEffect(32247099,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,1)
		else
			rc:SetFlagEffectLabel(32247099,ct+1)
		end
	end
end
-- 当连锁被无效时，减少该卡牌的标记次数，若次数为0则清除标记。
function c32247099.checkop2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local ct=rc:GetFlagEffectLabel(32247099)
	if ct==1 then
		rc:ResetFlagEffect(32247099)
	elseif ct then
		rc:SetFlagEffectLabel(32247099,ct-1)
	end
end
-- 判断攻击方是否为对方，即是否满足①效果的发动条件。
function c32247099.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击方是否为对方，即是否满足①效果的发动条件。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤函数，用于筛选手卡中可丢弃的魔法·陷阱卡。
function c32247099.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
-- ①效果的费用处理，丢弃1张魔法·陷阱卡。
function c32247099.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃魔法·陷阱卡的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c32247099.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张魔法·陷阱卡的操作。
	Duel.DiscardHand(tp,c32247099.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于筛选墓地中的幻神兽族怪兽。
function c32247099.spfilter(c,e,tp)
	return c:IsRace(RACE_DIVINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的目标选择处理，选择墓地中的幻神兽族怪兽。
function c32247099.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32247099.spfilter(chkc,e,tp) end
	-- 检查是否有足够的特殊召唤位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有满足条件的墓地幻神兽族怪兽。
		and Duel.IsExistingTarget(c32247099.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标幻神兽族怪兽。
	local g=Duel.SelectTarget(tp,c32247099.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将特殊召唤目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理，特殊召唤目标怪兽并转移攻击对象。
function c32247099.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效并进行特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0
		-- 判断攻击怪兽是否免疫此效果。
		and not Duel.GetAttacker():IsImmuneToEffect(e) then
		-- 中断当前效果，使后续处理视为不同时处理。
		Duel.BreakEffect()
		-- 将攻击对象转移为特殊召唤的幻神兽族怪兽。
		Duel.ChangeAttackTarget(tc)
	end
end
-- 过滤函数，用于筛选场上的幻神兽族怪兽。
function c32247099.descfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DIVINE)
end
-- ②效果的发动条件，检查自己场上有幻神兽族怪兽存在。
function c32247099.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上有幻神兽族怪兽存在。
	return Duel.IsExistingMatchingCard(c32247099.descfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于筛选对方场上的表侧表示的卡。
function c32247099.desfilter(c)
	return c:IsFaceup() and c:GetFlagEffect(32247099)>0
end
-- ②效果的目标选择处理，选择对方场上的表侧表示的卡。
function c32247099.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的表侧表示的卡。
	local g=Duel.GetMatchingGroup(c32247099.desfilter,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息，表示将破坏目标卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- ②效果的处理，破坏对方场上的表侧表示的卡。
function c32247099.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的表侧表示的卡。
	local g=Duel.GetMatchingGroup(c32247099.desfilter,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		-- 执行破坏操作，将目标卡破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
