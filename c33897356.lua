--シューティングコード・トーカー
-- 效果：
-- 电子界族怪兽2只以上
-- ①：自己战斗阶段开始时才能发动。这次战斗阶段中，这张卡可以向对方怪兽作出最多有这张卡所连接区的怪兽数量＋1次的攻击。这个回合，对方场上的怪兽只有1只的场合，和那只怪兽进行战斗的这张卡的攻击力只在那次伤害计算时下降400。
-- ②：自己·对方的战斗阶段结束时才能发动。自己从卡组抽出这个回合这张卡战斗破坏的怪兽的数量。
function c33897356.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片注册连接召唤的素材要求规程
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2)
	-- ①：自己战斗阶段开始时才能发动。这次战斗阶段中，这张卡可以向对方怪兽作出最多有这连接端怪兽数量＋1次的攻击。对方场上的怪兽只有1只的场合，和那只怪兽战斗的此卡攻击力只在伤害计算时下降400。
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
	-- 注册此卡在战斗破坏怪兽时进行计数的单体持续效果
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
-- 确认当前处于自己回合的战斗阶段开始时
function c33897356.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 检查此卡连接端是否存在怪兽以决定是否能发动效果
function c33897356.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetLinkedGroupCount()>0 end
end
-- 增加攻击次数与降攻效果的适用
function c33897356.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 注册根据连接端怪兽数量增加可以向对方怪兽攻击次数的持续效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetValue(e:GetHandler():GetLinkedGroupCount())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
		-- 注册对方怪兽只有1只场合进行战斗时伤害计算时下降400攻击力的持续效果
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
-- 判断降攻效果在伤害计算时是否符合对方场上仅有1只怪兽且正在进行战斗的条件
function c33897356.atkcon(e)
	-- 确认当前处于伤害计算时点
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
	local tp=e:GetHandlerPlayer()
	-- 获取对方场上的全部怪兽
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if #g~=1 then return false end
	local c=e:GetHandler()
	local bc=g:GetFirst()
	-- 确认此卡正在与对方场上那唯一的怪兽进行战斗
	return (c==Duel.GetAttacker() and bc==Duel.GetAttackTarget()) or (bc==Duel.GetAttacker() and c==Duel.GetAttackTarget())
end
-- 在战斗破坏对方怪兽时，在此卡上累计已破坏的数量标记
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
-- 战阶结束时抽卡效果的发动准备与可行性检查
function c33897356.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetFlagEffectLabel(33897356)
	-- 检查在此卡上是否累计有破坏标记且自己可以从卡组抽取对应数量 of 卡片
	if chk==0 then return ct and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置操作信息为从卡组抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 抽卡效果的执行
function c33897356.drop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetFlagEffectLabel(33897356)
	-- 从卡组中抽取出等于已破坏标记数量的卡片
	Duel.Draw(tp,ct,REASON_EFFECT)
end
