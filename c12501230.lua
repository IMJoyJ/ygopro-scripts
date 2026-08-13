--コンバット・ホイール
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：场上的这张卡1回合只有1次不会被对方的效果破坏。
-- ②：对方战斗阶段1次，丢弃1张手卡才能发动。这张卡的攻击力上升自己场上的其他怪兽的攻击力合计数值的一半。那之后，给这张卡放置1个指示物。这个回合中，对方怪兽不能选择其他怪兽作为攻击对象。
-- ③：有指示物放置的这张卡被战斗破坏的场合发动。自己场上的怪兽全部破坏。
local s,id,o=GetID()
-- 初始化函数：为战斗车轮设定同调召唤手续（调整+调整以外怪兽1只以上）、允许放置0x67指示物，并注册①的1回合1次抗对方效果破坏效果、②的对方战斗阶段丢弃手卡提升攻击力并放置指示物且限制对方攻击对象的效果、以及③判定离场前是否有指示物的辅助效果和③被战破后自爆的诱发效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定同调召唤手续：调整＋调整以外的怪兽1只以上（这里调整不限定，调整以外也不限定）进行同调召唤。
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
	-- 辅助③的效果：记录这张卡离场前是否放置有指示物，用于③“有指示物放置的这张卡被战斗破坏的场合发动”的判定。
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
-- e1的Value函数：只有被对方的效果破坏时才返回1（即本回合可免疫1次对方的效果破坏），其他情况返回0。
function s.indct(e,re,r,rp)
	if r&REASON_EFFECT>0 and e:GetOwnerPlayer()~=rp then
		return 1
	else return 0 end
end
-- ②效果的发动条件：当前不是自己的回合（即对方回合），且不处于伤害计算过程中，同时当前阶段在战斗阶段开始到战斗阶段结束之间。
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 第1个发动条件：当前回合玩家不是这张卡的控制者，且不在伤害计算的时点内（可在伤害步骤开始前/战斗步骤发动）。
	return Duel.GetTurnPlayer()~=tp and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
		-- 第2个发动条件：当前阶段必须是战斗阶段（从战斗阶段开始到战斗阶段结束）。
		and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- ②效果的代价检测：这张卡能放置1个指示物，且自己手卡中存在1张可以丢弃的卡。
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x67,1)
		-- 代价检测的另一部分：检索自己手卡中是否有可以丢弃的卡，至少1张即可满足代价条件。
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：从手卡丢弃1张卡（丢弃作为发动代价）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ②效果的发动目标检测：自己场上存在表侧表示的其他怪兽，且这些怪兽的攻击力合计大于0（用于计算攻击力上升）。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检测的具体判断：获取自己场上除这张卡以外的表侧怪兽，若它们的攻击力合计数值大于0，则效果可以发动。
	if chk==0 then return Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,e:GetHandler()):GetSum(Card.GetAttack)>0 end
end
-- ②效果处理：提升这张卡的攻击力（其他表侧怪兽攻击力合计的一半），那之后给这张卡放置1个指示物；然后给场上设置一个效果，让这个回合中对方怪兽不能选择这张卡以外的怪兽作为攻击对象。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上除这张卡以外的所有表侧表示怪兽，用于计算攻击力合计。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
	if c:IsFaceup() and c:IsRelateToEffect(e) and #g>0 then
		local atk=g:GetSum(Card.GetAttack)/2
		-- ②中的“这张卡的攻击力上升自己场上的其他怪兽的攻击力合计数值的一半”（通过EFFECT_UPDATE_ATTACK使攻击力上升）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
		-- 中断连锁处理，使“攻击力上升”和“那之后放置指示物”分别处理，以符合原文的先后顺序并避免错过时点。
		Duel.BreakEffect()
		if c:IsCanAddCounter(0x67,1) then c:AddCounter(0x67,1) end
	end
	local fid=0
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		fid=c:GetFieldID()
	end
	-- ③相关效果及后续处理函数：设置对方怪兽不能选择其他怪兽作为攻击对象的场地效果；atlimit用于判断攻击对象是否合法；regop用于记录离场前是否有指示物；descon判定被战斗破坏且有指示物；destg/desop选择并破坏自己场上全部怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetLabel(fid)
	e2:SetValue(s.atlimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将「对方怪兽不能选择其他怪兽作为攻击对象」的场地效果注册给当前回合玩家（tp），持续到回合结束。
	Duel.RegisterEffect(e2,tp)
end
-- 攻击对象限制的判定函数：若攻击对象不是战斗车轮，或其场上的FieldID不等于效果发动时所记录的FieldID，则不能选择该怪兽为攻击对象；这样就只允许对方选择这张卡（战斗车轮）作为攻击对象。
function s.atlimit(e,c)
	return c~=e:GetHandler() or e:GetHandler():GetFieldID()~=e:GetLabel()
end
-- 辅助效果e0的操作：在离场移动前判断这张卡是否放置有指示物，有则标记为1，无则标记为0。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetCounter(0x67)>0 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
-- ③的发动条件：这张卡是被战斗破坏送去墓地，并且离场前记录到有指示物（regop标记为1），即“有指示物放置的这张卡被战斗破坏的场合”。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return e:GetHandler():IsReason(REASON_BATTLE) and e:GetLabelObject():GetLabel()==1
end
-- ③的发动目标：无需要选择的对象；处理时将把自己场上所有怪兽作为将要破坏的卡，数量为当前自己场上怪兽数。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上的全部怪兽（包括这张卡自身），用于③破坏自己场上全部怪兽。
	local sg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 设置操作信息：宣告这次效果将破坏自己场上全部怪兽，用于各种连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
-- ③效果处理：把自己场上的怪兽全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的全部怪兽，作为③要破坏的对象。
	local sg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 以效果为原因破坏自己场上的全部怪兽，执行“自己场上的怪兽全部破坏”。
	Duel.Destroy(sg,REASON_EFFECT)
end
