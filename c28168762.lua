--聖蔓の守護者
-- 效果：
-- 植物族通常怪兽1只
-- ①：自己场上的「圣天树」连接怪兽因效果从场上离开的场合发动。这张卡破坏。
-- ②：和「圣天树」连接怪兽成为连接状态的这张卡在和对方怪兽进行战斗的攻击宣言时才能发动。那次战斗发生的对自己的战斗伤害变成一半。
-- ③：这张卡被战斗破坏时才能发动。那次伤害步骤结束后战斗阶段结束。
function c28168762.initial_effect(c)
	-- 为这张卡添加连接召唤手续：以1只植物族通常怪兽作为连接素材。
	aux.AddLinkProcedure(c,c28168762.mfilter,1,1)
	c:EnableReviveLimit()
	-- ①：自己场上的「圣天树」连接怪兽因效果从场上离开的场合发动。这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28168762,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c28168762.descon)
	e1:SetTarget(c28168762.destg)
	e1:SetOperation(c28168762.desop)
	c:RegisterEffect(e1)
	-- ②：和「圣天树」连接怪兽成为连接状态的这张卡在和对方怪兽进行战斗的攻击宣言时才能发动。那次战斗发生的对自己的战斗伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28168762,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(c28168762.dmcon)
	e2:SetOperation(c28168762.dmop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗破坏时才能发动。那次伤害步骤结束后战斗阶段结束。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetOperation(c28168762.op)
	c:RegisterEffect(e3)
end
-- 连接素材过滤：判定素材是否为植物族通常怪兽。
function c28168762.mfilter(c)
	return c:IsLinkType(TYPE_NORMAL) and c:IsLinkRace(RACE_PLANT)
end
-- 判定离场怪兽是否为表侧表示、由自己控制且因效果从怪兽区离开的「圣天树」连接怪兽。
function c28168762.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
		and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0 and c:IsPreviousSetCard(0x2158) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果①的发动条件：存在满足条件的「圣天树」连接怪兽因效果离场。
function c28168762.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28168762.cfilter,1,nil,tp)
end
-- 效果①的发动目标处理：无对象，设置可发动并登记破坏本卡的操作信息。
function c28168762.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记效果处理时本卡将被破坏的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果①处理：若本卡仍与该效果关联，则将其破坏。
function c28168762.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以效果原因将本卡破坏。
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 过滤函数：判断场上是否存在与本卡处于互相连接状态的「圣天树」连接怪兽。
function c28168762.filter(c,ec)
	return c:IsFaceup() and c:IsSetCard(0x2158) and c:IsType(TYPE_LINK) and (c:GetLinkedGroup():IsContains(ec) or ec:GetLinkedGroup():IsContains(c))
end
-- 效果②的发动条件：本卡正与对方怪兽进行战斗攻击宣言，且场上存在与本卡连接的「圣天树」连接怪兽。
function c28168762.dmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的双方怪兽：a为tp方怪兽，d为对方怪兽。
	local a,d=Duel.GetBattleMonster(tp)
	local c=e:GetHandler()
	-- 确认攻击方是本卡且存在攻击对象，并存在满足连接条件的「圣天树」连接怪兽。
	return d and a==c and Duel.IsExistingMatchingCard(c28168762.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
-- 效果②处理：给本方玩家设置战斗伤害减半的效果，持续到伤害步骤结束。
function c28168762.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 那次战斗发生的对自己的战斗伤害变成一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(HALF_DAMAGE)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将战斗伤害减半效果注册到决斗中。
	Duel.RegisterEffect(e1,tp)
end
-- 效果③处理：创建一个持续效果，在连锁结束时跳过战斗阶段。
function c28168762.op(e,tp,eg,ep,ev,re,r,rp)
	-- ③：这张卡被战斗破坏时才能发动。那次伤害步骤结束后战斗阶段结束。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c28168762.skipop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	-- 将跳过战斗阶段的辅助效果注册到决斗中。
	Duel.RegisterEffect(e1,tp)
end
-- 执行跳过战斗阶段的操作。
function c28168762.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 令当前回合玩家跳过战斗阶段，结束战斗阶段。
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
