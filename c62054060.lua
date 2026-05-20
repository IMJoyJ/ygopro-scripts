--平穏の賢者
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，对方玩家在下个回合不能发动陷阱卡。
function c62054060.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，对方玩家在下个回合不能发动陷阱卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62054060,0))  --"发动限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c62054060.condition)
	e1:SetOperation(c62054060.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否与战斗相关，且战斗破坏的对方怪兽是否是怪兽卡
function c62054060.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 创建并注册一个影响对方玩家的全局效果，使其在下个回合不能发动陷阱卡
function c62054060.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 对方玩家在下个回合不能发动陷阱卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c62054060.accon)
	e1:SetValue(c62054060.aclimit)
	-- 将当前回合数记录在效果的Label中，用于后续判断是否为下个回合
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将限制发动的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的生效条件函数，用于过滤掉当前回合
function c62054060.accon(e)
	-- 当当前回合数不等于记录的回合数（即进入下个回合）时，效果生效
	return e:GetLabel()~=Duel.GetTurnCount()
end
-- 限制发动的类型：必须是陷阱卡的发动（卡片的发动）
function c62054060.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
