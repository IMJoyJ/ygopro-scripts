--静寂の聖者
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，对方玩家在下个回合不能发动魔法卡。
function c26669055.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，对方玩家在下个回合不能发动魔法卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26669055,0))  --"发动限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置触发条件：此卡在与对方怪兽的战斗中将其战斗破坏（且此卡仍与该战斗相关）时，才满足效果发动条件。
	e1:SetCondition(aux.bdocon)
	e1:SetOperation(c26669055.operation)
	c:RegisterEffect(e1)
end
-- 创建并注册一个影响对方玩家的永续效果，使其不能发动魔法卡；效果通过记录当前回合数限定从下个回合起生效，并在两个结束阶段后自动重置。
function c26669055.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 对方玩家在下个回合不能发动魔法卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c26669055.accon)
	e1:SetValue(c26669055.aclimit)
	-- 记录效果生成时的当前回合数，作为判断“下个回合”是否到来的基准。
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将该“对方玩家不能发动魔法卡”的限制效果注册到决斗中，使其开始适用。
	Duel.RegisterEffect(e1,tp)
end
-- 定义限制效果的适用条件：仅当已经进入记录回合数之后的新的回合（即下个回合）时，限制效果才适用。
function c26669055.accon(e)
	-- 判断保存的回合数与当前回合数是否不同；不同则说明已到下一个回合，限制效果生效。
	return e:GetLabel()~=Duel.GetTurnCount()
end
-- 定义限制内容：对方发动的效果若属于魔法卡的发动（EFFECT_TYPE_ACTIVATE 且为魔法卡），则禁止该发动。
function c26669055.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
