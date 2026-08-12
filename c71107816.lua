--悪魔の調理師
-- 效果：
-- 这张卡给与对方战斗伤害时，对方在卡组最上面抽2张卡。
function c71107816.initial_effect(c)
	-- 这张卡给与对方战斗伤害时，对方在卡组最上面抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71107816,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c71107816.condition)
	e1:SetTarget(c71107816.target)
	e1:SetOperation(c71107816.operation)
	c:RegisterEffect(e1)
end
-- 诱发效果的发动条件：给与对方战斗伤害时
function c71107816.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 诱发效果的Target（确定效果的对象玩家和参数，并设置操作信息）
function c71107816.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的参数为2（抽卡张数）
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：对方玩家从卡组抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,2)
end
-- 诱发效果的Operation（效果处理：对方抽2张卡）
function c71107816.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家和参数（即对方玩家和抽卡张数2）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
