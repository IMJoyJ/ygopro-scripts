--アップデートジャマー
-- 效果：
-- 2星以上的电子界族怪兽2只
-- ①：自己的电子界族怪兽进行战斗的伤害计算时才能发动1次。直到伤害步骤结束时，场上的其他卡的效果无效化，那次战斗的伤害计算用原本的攻击力·守备力进行。那次战斗让对方怪兽被破坏送去墓地时，给与对方1000伤害。
-- ②：这张卡作为连接素材送去墓地的场合才能发动。这张卡为连接素材的连接怪兽在这个回合在同1次的战斗阶段中可以作2次攻击。
function c88093706.initial_effect(c)
	-- 为卡片添加连接召唤手续，并指定素材过滤条件和所需素材数量。
	aux.AddLinkProcedure(c,c88093706.mfilter,2)
	c:EnableReviveLimit()
	-- ①：自己的电子界族怪兽进行战斗的伤害计算时才能发动1次。直到伤害步骤结束时，场上的其他卡的效果无效化，那次战斗的伤害计算用原本的攻击力·守备力进行。那次战斗让对方怪兽被破坏送去墓地时，给与对方1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88093706,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c88093706.atkcon)
	e1:SetCost(c88093706.atkcost)
	e1:SetOperation(c88093706.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为连接素材送去墓地的场合才能发动。这张卡为连接素材的连接怪兽在这个回合在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88093706,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c88093706.efcon)
	e2:SetTarget(c88093706.eftg)
	e2:SetOperation(c88093706.efop)
	c:RegisterEffect(e2)
	-- 建立作为素材的卡与因该素材召唤出的怪兽之间的关联，确保后续效果能正确获取到该连接怪兽。
	aux.CreateMaterialReasonCardRelation(c,e2)
end
-- 定义连接素材的过滤条件：等级2以上的电子界族怪兽。
function c88093706.mfilter(c)
	return c:IsLevelAbove(2) and c:IsLinkRace(RACE_CYBERSE)
end
-- 判断是否满足发动条件：自己控制的电子界族怪兽进行战斗的伤害计算时。
function c88093706.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的被攻击怪兽。
	local d=Duel.GetAttackTarget()
	return a:IsControler(tp) and a:IsRace(RACE_CYBERSE)
		or d and d:IsControler(tp) and d:IsRace(RACE_CYBERSE)
end
-- 定义发动的Cost：通过注册Flag标记，限制该效果在每次伤害计算时只能发动1次。
function c88093706.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(88093706)==0 end
	c:RegisterFlagEffect(88093706,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 定义效果①发动后的具体处理逻辑：使场上其他卡的效果无效，用原本攻防进行伤害计算，并在对方怪兽被战斗破坏送去墓地时给予伤害。
function c88093706.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的被攻击怪兽。
	local d=Duel.GetAttackTarget()
	-- 直到伤害步骤结束时，场上的其他卡的效果无效化
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e1:SetTarget(c88093706.distg)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 在全局注册使场上其他卡效果无效的永续效果。
	Duel.RegisterEffect(e1,tp)
	-- 直到伤害步骤结束时，场上的其他卡的效果无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c88093706.disop)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 在全局注册一个在连锁处理时使场上卡片发动的效果无效的辅助效果。
	Duel.RegisterEffect(e2,tp)
	-- 直到伤害步骤结束时，场上的其他卡的效果无效化
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 在全局注册使陷阱怪兽效果无效的效果。
	Duel.RegisterEffect(e3,tp)
	-- 手动刷新场上卡片的无效状态，确保后续计算使用原本数值。
	Duel.AdjustInstantly()
	if a:IsRelateToBattle() then
		-- 那次战斗的伤害计算用原本的攻击力·守备力进行。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_SET_BATTLE_ATTACK)
		e4:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e4:SetValue(a:GetBaseAttack())
		a:RegisterEffect(e4,true)
		-- 那次战斗的伤害计算用原本的攻击力·守备力进行。
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_SET_BATTLE_DEFENSE)
		e5:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e5:SetValue(a:GetBaseDefense())
		a:RegisterEffect(e5,true)
	end
	if d and d:IsRelateToBattle() then
		-- 那次战斗的伤害计算用原本的攻击力·守备力进行。
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetCode(EFFECT_SET_BATTLE_ATTACK)
		e6:SetValue(d:GetBaseAttack())
		e6:SetReset(RESET_PHASE+PHASE_DAMAGE)
		d:RegisterEffect(e6,true)
		-- 那次战斗的伤害计算用原本的攻击力·守备力进行。
		local e7=Effect.CreateEffect(c)
		e7:SetType(EFFECT_TYPE_SINGLE)
		e7:SetCode(EFFECT_SET_BATTLE_DEFENSE)
		e7:SetValue(d:GetBaseDefense())
		e7:SetReset(RESET_PHASE+PHASE_DAMAGE)
		d:RegisterEffect(e7,true)
	end
	if a:IsRelateToBattle() and d and d:IsRelateToBattle() then
		local g=Group.FromCards(a,d)
		g:KeepAlive()
		-- 那次战斗让对方怪兽被破坏送去墓地时，给与对方1000伤害。
		local e8=Effect.CreateEffect(c)
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_BATTLE_DESTROYING)
		e8:SetLabelObject(g)
		e8:SetOperation(c88093706.damop)
		e8:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 在全局注册战斗破坏对方怪兽时给予伤害的辅助效果。
		Duel.RegisterEffect(e8,tp)
	end
end
-- 过滤无效化的卡片：除了自身（更新干扰员）以外的所有场上的卡。
function c88093706.distg(e,c)
	return c~=e:GetHandler()
end
-- 连锁处理时的操作：如果发动效果的卡在场上，则使该效果无效。
function c88093706.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的发动位置。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if bit.band(loc,LOCATION_ONFIELD)~=0 then
		-- 无效化该连锁的效果。
		Duel.NegateEffect(ev)
	end
end
-- 过滤被战斗破坏送去对方墓地的怪兽。
function c88093706.damfilter(c,p)
	return c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(p)
end
-- 战斗破坏对方怪兽时的伤害处理：若满足条件则给予对方1000点伤害。
function c88093706.damop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():IsExists(c88093706.damfilter,1,nil,1-tp) then
		-- 给予对方1000点效果伤害。
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
-- 判断是否满足发动条件：自身作为连接素材被送去墓地。
function c88093706.efcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
-- 定义效果②的发动准备：确认召唤出的连接怪兽存在，且当前可以进入战斗阶段，并将其设为效果处理的目标。
function c88093706.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	-- 检查召唤出的连接怪兽是否仍与本效果存在关联，且当前回合玩家是否能够进入战斗阶段。
	if chk==0 then return rc:IsRelateToEffect(e) and Duel.IsAbleToEnterBP() end
	-- 将召唤出的连接怪兽设为当前连锁的目标卡。
	Duel.SetTargetCard(rc)
end
-- 定义效果②发动后的具体处理逻辑：给作为素材的连接怪兽赋予“在这个回合的同一次战斗阶段中可以作2次攻击”的效果。
function c88093706.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡（即召唤出的连接怪兽）。
	local rc=Duel.GetFirstTarget()
	if not rc:IsRelateToChain() then return end
	-- 这张卡为连接素材的连接怪兽在这个回合在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88093706,2))  --"「更新干扰员」效果适用中"
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	rc:RegisterEffect(e1)
end
