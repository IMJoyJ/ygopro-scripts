--聖蔓の守護者
-- 效果：
-- 植物族通常怪兽1只
-- ①：自己场上的「圣天树」连接怪兽因效果从场上离开的场合发动。这张卡破坏。
-- ②：和「圣天树」连接怪兽成为连接状态的这张卡在和对方怪兽进行战斗的攻击宣言时才能发动。那次战斗发生的对自己的战斗伤害变成一半。
-- ③：这张卡被战斗破坏时才能发动。那次伤害步骤结束后战斗阶段结束。
function c28168762.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用1到1张满足条件的植物族通常怪兽作为连接素材
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
-- 连接素材过滤函数，筛选通常怪兽且种族为植物族的卡片
function c28168762.mfilter(c)
	return c:IsLinkType(TYPE_NORMAL) and c:IsLinkRace(RACE_PLANT)
end
-- 离场条件过滤函数，判断离场的怪兽是否为「圣天树」连接怪兽且因效果离场
function c28168762.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
		and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0 and c:IsPreviousSetCard(0x2158) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果①的发动条件，检查是否有满足条件的怪兽离场
function c28168762.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28168762.cfilter,1,nil,tp)
end
-- 效果①的发动目标设定，设置将自身破坏为效果处理目标
function c28168762.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果①的处理目标为自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理，若自身存在于场上则将其破坏
function c28168762.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以效果原因破坏
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 战斗伤害减半条件过滤函数，筛选与自身连接的「圣天树」连接怪兽
function c28168762.filter(c,ec)
	return c:IsFaceup() and c:IsSetCard(0x2158) and c:IsType(TYPE_LINK) and (c:GetLinkedGroup():IsContains(ec) or ec:GetLinkedGroup():IsContains(c))
end
-- 效果②的发动条件，判断是否为自身攻击且有连接的「圣天树」怪兽
function c28168762.dmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的攻击怪兽和防守怪兽
	local a,d=Duel.GetBattleMonster(tp)
	local c=e:GetHandler()
	-- 判断是否为自身攻击且存在连接的「圣天树」怪兽
	return d and a==c and Duel.IsExistingMatchingCard(c28168762.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
-- 效果②的发动处理，设置自身受到的战斗伤害减半
function c28168762.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置战斗伤害减半效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(HALF_DAMAGE)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册战斗伤害减半效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果③的发动处理，注册战斗阶段结束跳过效果
function c28168762.op(e,tp,eg,ep,ev,re,r,rp)
	-- 注册战斗阶段结束跳过效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c28168762.skipop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	-- 注册战斗阶段结束跳过效果
	Duel.RegisterEffect(e1,tp)
end
-- 跳过战斗阶段结束步骤
function c28168762.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过当前回合的战斗阶段结束步骤
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
