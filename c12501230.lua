--コンバット・ホイール
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：场上的这张卡1回合只有1次不会被对方的效果破坏。
-- ②：对方战斗阶段1次，丢弃1张手卡才能发动。这张卡的攻击力上升自己场上的其他怪兽的攻击力合计数值的一半。那之后，给这张卡放置1个指示物。这个回合中，对方怪兽不能选择其他怪兽作为攻击对象。
-- ③：有指示物放置的这张卡被战斗破坏的场合发动。自己场上的怪兽全部破坏。
local s,id,o=GetID()
-- 定义卡片的初始效果，包括同调召唤手续、不会被对方效果破坏的效果、对方战斗阶段丢弃手卡发动的效果、以及有指示物时被战斗破坏的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤手续，要求调整1只和调整以外的怪兽至少1只。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableCounterPermit(0x67)
	-- 场上的这张卡1回合只有1次不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.indct)
	c:RegisterEffect(e1)
	-- 对方战斗阶段1次，丢弃1张手卡才能发动。这张卡的攻击力上升自己场上的其他怪兽的攻击力合计数值的一半。那之后，给这张卡放置1个指示物。这个回合中，对方怪兽不能选择其他怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_DAMAGE_STEP)
	e2:SetCondition(s.ctcon)
	e2:SetCost(s.ctcost)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	-- 有指示物放置的这张卡
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	-- 有指示物放置的这张卡被战斗破坏的场合发动。自己场上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	e3:SetLabelObject(e0)
	c:RegisterEffect(e3)
end
-- 判断是否满足不会被对方效果破坏的条件，如果是对方效果且不是持有者，则返回1表示一次不被破坏。
function s.indct(e,re,r,rp)
	if r&REASON_EFFECT>0 and e:GetOwnerPlayer()~=rp then
		return 1
	else return 0 end
end
-- 检查效果发动条件：对方回合且不在伤害计算后，且处于战斗阶段内。
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方，并且不在伤害计算后。
	return Duel.GetTurnPlayer()~=tp and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
		-- 检查当前阶段是否在战斗阶段开始到战斗阶段结束之间。
		and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 定义发动代价：检查是否可以添加指示物且手卡有可丢弃的卡。
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x67,1)
		-- 检查手卡中是否存在至少1张可丢弃的卡。
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手卡作为发动代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义效果目标：检查自己场上其他表侧表示怪兽的攻击力合计是否大于0。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标检查时，返回自己场上其他表侧表示怪兽的攻击力合计是否大于0。
	if chk==0 then return Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,e:GetHandler()):GetSum(Card.GetAttack)>0 end
end
-- 定义效果操作：计算其他怪兽攻击力合计的一半，上升自身攻击力，添加指示物，并设置对方怪兽只能攻击此卡的效果。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上除自身以外的所有表侧表示怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
	if c:IsFaceup() and c:IsRelateToEffect(e) and #g>0 then
		local atk=g:GetSum(Card.GetAttack)/2
		-- 这张卡的攻击力上升自己场上的其他怪兽的攻击力合计数值的一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
		-- 中断当前效果处理，使后续操作错时点进行。
		Duel.BreakEffect()
		if c:IsCanAddCounter(0x67,1) then c:AddCounter(0x67,1) end
	end
	local fid=0
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		fid=c:GetFieldID()
	end
	-- 这个回合中，对方怪兽不能选择其他怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetLabel(fid)
	e2:SetValue(s.atlimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将攻击对象限制效果注册给玩家，使其在回合结束前持续适用。
	Duel.RegisterEffect(e2,tp)
end
-- 定义攻击对象限制条件：只有此卡自身可以被选择为攻击对象。
function s.atlimit(e,c)
	return c~=e:GetHandler() or e:GetHandler():GetFieldID()~=e:GetLabel()
end
-- 在卡片离场前，检查是否有指示物，并设置标签以记录状态。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetCounter(0x67)>0 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
-- 定义效果③的发动条件：此卡因战斗破坏且离场前有指示物。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return e:GetHandler():IsReason(REASON_BATTLE) and e:GetLabelObject():GetLabel()==1
end
-- 定义效果③的目标：设置要破坏的自己场上所有怪兽。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上的所有怪兽。
	local sg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 设置操作信息，指示将破坏自己场上所有怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
-- 定义效果③的操作：破坏自己场上所有怪兽。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的所有怪兽以进行破坏。
	local sg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 以效果原因破坏自己场上所有怪兽。
	Duel.Destroy(sg,REASON_EFFECT)
end
