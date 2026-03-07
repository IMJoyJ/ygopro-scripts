--シューティングコード・トーカー
-- 效果：
-- 电子界族怪兽2只以上
-- ①：自己战斗阶段开始时才能发动。这次战斗阶段中，这张卡可以向对方怪兽作出最多有这张卡所连接区的怪兽数量＋1次的攻击。这个回合，对方场上的怪兽只有1只的场合，和那只怪兽进行战斗的这张卡的攻击力只在那次伤害计算时下降400。
-- ②：自己·对方的战斗阶段结束时才能发动。自己从卡组抽出这个回合这张卡战斗破坏的怪兽的数量。
function c33897356.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用至少2只电子界族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2)
	-- ①：自己战斗阶段开始时才能发动。这次战斗阶段中，这张卡可以向对方怪兽作出最多有这张卡所连接区的怪兽数量＋1次的攻击。
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
	-- ②：自己·对方的战斗阶段结束时才能发动。自己从卡组抽出这个回合这张卡战斗破坏的怪兽的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetOperation(c33897356.regop)
	c:RegisterEffect(e2)
	-- 设置战斗阶段结束时触发的效果，用于在战斗阶段结束时抽卡
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
-- 判断是否为当前回合玩家
function c33897356.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家才能发动
	return Duel.GetTurnPlayer()==tp
end
-- 判断连接区是否有怪兽
function c33897356.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetLinkedGroupCount()>0 end
end
-- 设置效果处理，使这张卡在战斗阶段中可以进行额外攻击，并在特定条件下降低攻击力
function c33897356.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 使这张卡在战斗阶段中可以向对方怪兽作出最多有这张卡所连接区的怪兽数量＋1次的攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetValue(e:GetHandler():GetLinkedGroupCount())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
		-- 当对方场上的怪兽只有1只时，和那只怪兽进行战斗的这张卡的攻击力只在那次伤害计算时下降400
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
-- 判断是否在伤害计算阶段且对方场上只有一只怪兽
function c33897356.atkcon(e)
	-- 判断当前阶段是否为伤害计算阶段
	if not Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL then return false end
	local tp=e:GetHandlerPlayer()
	-- 获取对方场上的怪兽数量
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if #g~=1 then return false end
	local c=e:GetHandler()
	local bc=g:GetFirst()
	-- 判断攻击怪兽和被攻击怪兽是否为当前卡和对方场上唯一怪兽
	return (c==Duel.GetAttacker() and bc==Duel.GetAttackTarget()) or (bc==Duel.GetAttacker() and c==Duel.GetAttackTarget())
end
-- 记录战斗破坏的怪兽数量
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
-- 设置抽卡效果的目标
function c33897356.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetFlagEffectLabel(33897356)
	-- 检查是否可以抽卡
	if chk==0 then return ct and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 执行抽卡操作
function c33897356.drop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetFlagEffectLabel(33897356)
	-- 让玩家从卡组抽指定数量的卡
	Duel.Draw(tp,ct,REASON_EFFECT)
end
