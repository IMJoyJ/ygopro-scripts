--花札衛－五光－
-- 效果：
-- 调整＋调整以外的怪兽4只
-- ①：1回合1次，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：自己的「花札卫」怪兽和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
-- ③：同调召唤的这张卡被战斗破坏的场合或者因对方的效果从场上离开的场合才能发动。从额外卡组把「花札卫-五光-」以外的1只「花札卫」同调怪兽特殊召唤。
function c87460579.initial_effect(c)
	-- 设置同调召唤手续：需要1只调整怪兽和4只调整以外的怪兽。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),4,4)
	c:EnableReviveLimit()
	-- ①：1回合1次，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87460579,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c87460579.negcon)
	e2:SetTarget(c87460579.negtg)
	e2:SetOperation(c87460579.negop)
	c:RegisterEffect(e2)
	-- ②：自己的「花札卫」怪兽和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(c87460579.discon)
	e3:SetOperation(c87460579.disop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e4)
	-- ②：自己的「花札卫」怪兽和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_DISABLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetTarget(c87460579.distg)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e7)
	-- ③：同调召唤的这张卡被战斗破坏的场合或者因对方的效果从场上离开的场合才能发动。从额外卡组把「花札卫-五光-」以外的1只「花札卫」同调怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(87460579,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(c87460579.spcon)
	e5:SetTarget(c87460579.sptg)
	e5:SetOperation(c87460579.spop)
	c:RegisterEffect(e5)
end
-- 魔法·陷阱卡发动无效效果的发动条件：此卡未被战斗破坏，且对方发动了魔法·陷阱卡，且该发动可以被无效。
function c87460579.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp
		-- 检查发动的效果是否为魔法·陷阱卡的发动，且该连锁的发动可以被无效。
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 魔法·陷阱卡发动无效效果的靶向/操作信息设置：设置无效和破坏的操作信息。
function c87460579.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将该连锁的发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：如果发动的卡可以被破坏且仍存在于连锁中，则将其破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 魔法·陷阱卡发动无效效果的处理：使发动无效并破坏该卡。
function c87460579.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该连锁的发动无效，且该卡仍与效果相关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果将该卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上表侧表示的「花札卫」怪兽。
function c87460579.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xe6) and c:IsControler(tp)
end
-- 战斗阶段效果无效化的触发条件：自己的「花札卫」怪兽与对方怪兽进行战斗。
function c87460579.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击对象。
	local c=Duel.GetAttackTarget()
	if not c then return false end
	-- 如果攻击对象是对方怪兽，则将c指向攻击怪兽（即确保c是自己场上的怪兽）。
	if c:IsControler(1-tp) then c=Duel.GetAttacker() end
	return c and c87460579.cfilter(c,tp)
end
-- 战斗阶段效果无效化的处理：给进行战斗的对方怪兽注册一个在战斗阶段内有效的Flag，并立即刷新场上卡片状态。
function c87460579.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击对象。
	local tc=Duel.GetAttackTarget()
	-- 如果攻击对象是自己怪兽，则将tc指向攻击怪兽（即确保tc是对方场上的怪兽）。
	if tc:IsControler(tp) then tc=Duel.GetAttacker() end
	tc:RegisterFlagEffect(87460579,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	-- 立即刷新场上卡片的状态，使无效化效果立刻生效。
	Duel.AdjustInstantly(c)
end
-- 效果无效化的适用对象过滤：带有特定Flag（即与「花札卫」进行战斗的对方怪兽）的怪兽。
function c87460579.distg(e,c)
	return c:GetFlagEffect(87460579)~=0
end
-- 特殊召唤效果的发动条件：同调召唤的此卡被战斗破坏，或者因对方的效果从场上离开。
function c87460579.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：额外卡组中「花札卫-五光-」以外的、可以特殊召唤的「花札卫」同调怪兽。
function c87460579.spfilter(c,e,tp)
	return c:IsSetCard(0xe6) and not c:IsCode(87460579) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组怪兽特殊召唤到场上所需的可用怪兽区域空格数是否大于0。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 特殊召唤效果的靶向/操作信息设置：检查额外卡组是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息。
function c87460579.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只满足过滤条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c87460579.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 特殊召唤效果的处理：从额外卡组选择1只满足条件的「花札卫」同调怪兽特殊召唤。
function c87460579.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 过滤并让玩家从额外卡组选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c87460579.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
