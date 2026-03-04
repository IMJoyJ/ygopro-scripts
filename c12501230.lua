--コンバット・ホイール
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：场上的这张卡1回合只有1次不会被对方的效果破坏。
-- ②：对方战斗阶段1次，丢弃1张手卡才能发动。这张卡的攻击力上升自己场上的其他怪兽的攻击力合计数值的一半。那之后，给这张卡放置1个指示物。这个回合中，对方怪兽不能选择其他怪兽作为攻击对象。
-- ③：有指示物放置的这张卡被战斗破坏的场合发动。自己场上的怪兽全部破坏。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableCounterPermit(0x67)
	-- ①：场上的这张卡1回合只有1次不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.indct)
	c:RegisterEffect(e1)
	-- ②：对方战斗阶段1次，丢弃1张手卡才能发动。这张卡的攻击力上升自己场上的其他怪兽的攻击力合计数值的一半。那之后，给这张卡放置1个指示物。这个回合中，对方怪兽不能选择其他怪兽作为攻击对象。
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
	-- ③：有指示物放置的这张卡被战斗破坏的场合发动。自己场上的怪兽全部破坏。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	-- ③：有指示物放置的这张卡被战斗破坏的场合发动。自己场上的怪兽全部破坏。
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
-- 判定效果是否可以发动的函数
function s.indct(e,re,r,rp)
	if r&REASON_EFFECT>0 and e:GetOwnerPlayer()~=rp then
		return 1
	else return 0 end
end
-- 判定效果发动时机的函数
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是效果发动者且不在伤害步骤中
	return Duel.GetTurnPlayer()~=tp and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
		-- 判断当前阶段为战斗阶段开始到战斗阶段结束之间
		and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 效果发动时的费用支付函数
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x67,1)
		-- 检查手牌中是否存在可丢弃的卡牌
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手卡作为发动费用
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果发动时的目标选择函数
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,e:GetHandler()):GetSum(Card.GetAttack)>0 end
end
-- 效果发动时的操作函数
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
	if c:IsFaceup() and c:IsRelateToEffect(e) and #g>0 then
		local atk=g:GetSum(Card.GetAttack)/2
		-- ②：对方战斗阶段1次，丢弃1张手卡才能发动。这张卡的攻击力上升自己场上的其他怪兽的攻击力合计数值的一半。那之后，给这张卡放置1个指示物。这个回合中，对方怪兽不能选择其他怪兽作为攻击对象。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
		-- 中断当前效果处理，使后续效果视为错时点
		Duel.BreakEffect()
		if c:IsCanAddCounter(0x67,1) then c:AddCounter(0x67,1) end
	end
	local fid=0
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		fid=c:GetFieldID()
	end
	-- ②：对方战斗阶段1次，丢弃1张手卡才能发动。这张卡的攻击力上升自己场上的其他怪兽的攻击力合计数值的一半。那之后，给这张卡放置1个指示物。这个回合中，对方怪兽不能选择其他怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetLabel(fid)
	e2:SetValue(s.atlimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果到全局环境
	Duel.RegisterEffect(e2,tp)
end
-- 限制对方怪兽攻击目标的函数
function s.atlimit(e,c)
	return c~=e:GetHandler() or e:GetHandler():GetFieldID()~=e:GetLabel()
end
-- 记录指示物状态的函数
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetCounter(0x67)>0 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
-- 判定效果发动条件的函数
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return e:GetHandler():IsReason(REASON_BATTLE) and e:GetLabelObject():GetLabel()==1
end
-- 设置效果发动时的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取己方场上的所有怪兽
	local sg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 设置操作信息，指定要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
-- 效果发动时的操作函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上的所有怪兽
	local sg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 将己方场上的所有怪兽破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
