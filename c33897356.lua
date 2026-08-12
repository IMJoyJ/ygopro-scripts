--シューティングコード・トーカー
-- 效果：
-- 电子界族怪兽2只以上
-- ①：自己战斗阶段开始时才能发动。这次战斗阶段中，这张卡可以向对方怪兽作出最多有这张卡所连接区的怪兽数量＋1次的攻击。这个回合，对方场上的怪兽只有1只的场合，和那只怪兽进行战斗的这张卡的攻击力只在那次伤害计算时下降400。
-- ②：自己·对方的战斗阶段结束时才能发动。自己从卡组抽出这个回合这张卡战斗破坏的怪兽的数量。
function c33897356.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：用2只以上的电子界族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2)
	-- ①：自己战斗阶段开始时才能发动。这次战斗阶段中，这张卡可以向对方怪兽作出最多有这张卡所连接区的怪兽数量＋1次的攻击。这个回合，对方场上的怪兽只有1只的场合，和那只怪兽进行战斗的这张卡的攻击力只在那次伤害计算时下降400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33897356,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c33897356.condition)
	e1:SetTarget(c33897356.target)
	e1:SetOperation(c33897356.operation)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏怪兽送去墓地时，记录这个回合这张卡战斗破坏的怪兽数量（为②效果的抽卡数量做计数）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetOperation(c33897356.regop)
	c:RegisterEffect(e2)
	-- ②：自己·对方的战斗阶段结束时才能发动。自己从卡组抽出这个回合这张卡战斗破坏的怪兽的数量。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c33897356.drtg)
	e3:SetOperation(c33897356.drop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件判断函数：只有自己的回合才能发动
function c33897356.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为自己，即只能在自己的战斗阶段开始时发动
	return Duel.GetTurnPlayer()==tp
end
-- ①效果的发动对象检查函数：这张卡的所连接区必须有怪兽存在才能发动
function c33897356.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetLinkedGroupCount()>0 end
end
-- ①效果的处理函数：赋予这张卡本战斗阶段可对对方怪兽作出所连接区怪兽数量＋1次攻击的效果，并注册与对方唯一怪兽战斗时伤害计算时攻击力下降400的效果
function c33897356.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这次战斗阶段中，这张卡可以向对方怪兽作出最多有这张卡所连接区的怪兽数量＋1次的攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetValue(e:GetHandler():GetLinkedGroupCount())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
		-- 这个回合，对方场上的怪兽只有1只的场合，和那只怪兽进行战斗的这张卡的攻击力只在那次伤害计算时下降400。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCondition(c33897356.atkcon)
		e2:SetValue(-400)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 攻击力下降效果的适用条件判断函数：仅在伤害计算时、对方场上只有1只怪兽、且这张卡正与那只怪兽进行战斗时适用
function c33897356.atkcon(e)
	-- 当前阶段不是伤害计算时则不适用攻击力下降
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
	local tp=e:GetHandlerPlayer()
	-- 获取对方场上（怪兽区域）的全部怪兽
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if #g~=1 then return false end
	local c=e:GetHandler()
	local bc=g:GetFirst()
	-- 判断这张卡是否正在与对方那只唯一的怪兽进行战斗（无论哪一方是攻击方）
	return (c==Duel.GetAttacker() and bc==Duel.GetAttackTarget()) or (bc==Duel.GetAttacker() and c==Duel.GetAttackTarget())
end
-- 战斗破坏计数处理函数：这张卡以战斗破坏怪兽送去墓地时，将本回合战斗破坏数量的计数加1（首次则注册计数为1的标记效果）
function c33897356.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() then return end
	local ct=c:GetFlagEffectLabel(33897356)
	if ct then
		c:SetFlagEffectLabel(33897356,ct+1)
	else
		c:RegisterFlagEffect(33897356,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,1)
	end
end
-- ②效果的发动目标函数：读取本回合战斗破坏的怪兽数量，确认可以抽出该数量的卡，并设置抽卡的操作信息
function c33897356.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetFlagEffectLabel(33897356)
	-- 发动条件检查：本回合曾战斗破坏过怪兽，且自己可以抽出该数量的卡
	if chk==0 then return ct and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置操作信息：宣告将从卡组抽出ct张卡（CATEGORY_DRAW），用于其他效果的连锁检测
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- ②效果的处理函数：自己从卡组抽出本回合这张卡战斗破坏的怪兽数量的卡
function c33897356.drop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetFlagEffectLabel(33897356)
	-- 让自己以效果原因从卡组抽出ct张卡
	Duel.Draw(tp,ct,REASON_EFFECT)
end
