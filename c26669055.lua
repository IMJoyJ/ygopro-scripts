--静寂の聖者
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，对方玩家在下个回合不能发动魔法卡。
function c26669055.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，对方玩家在下个回合不能发动魔法卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26669055,0))  --"发动限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测是否与对方怪兽战斗并破坏了对方怪兽
	e1:SetCondition(aux.bdocon)
	e1:SetOperation(c26669055.operation)
	c:RegisterEffect(e1)
end
-- 创建一个影响对方玩家的永续效果，禁止对方发动魔法卡
function c26669055.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 对方玩家在下个回合不能发动魔法卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c26669055.accon)
	e1:SetValue(c26669055.aclimit)
	-- 记录当前回合数用于后续判断
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将效果注册给对方玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否已过对方的回合
function c26669055.accon(e)
	-- 如果记录的回合数不等于当前回合数则生效
	return e:GetLabel()~=Duel.GetTurnCount()
end
-- 限制对方不能发动魔法卡的效果
function c26669055.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
