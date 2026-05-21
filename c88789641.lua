--ホーリーライフバリアー
-- 效果：
-- 丢弃1张手卡。这张卡发动的回合，对方造成的伤害全部为0。
function c88789641.initial_effect(c)
	-- 丢弃1张手卡。这张卡发动的回合，对方造成的伤害全部为0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c88789641.cost)
	e1:SetTarget(c88789641.target)
	e1:SetOperation(c88789641.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价函数，用于处理丢弃手牌的代价。
function c88789641.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己手牌中是否存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手牌中选择1张卡丢弃送去墓地作为发动的代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义效果的目标确认函数，仅用于确认该卡作为魔法陷阱卡发动。
function c88789641.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
end
-- 定义效果处理函数，在全局注册“对方造成的伤害为0”和“自己怪兽不会被战斗破坏”的效果，持续到回合结束。
function c88789641.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡发动的回合，对方造成的伤害全部为0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c88789641.val)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将伤害改变的效果注册给玩家，使其在当前回合内生效。
	Duel.RegisterEffect(e1,tp)
	-- 这张卡发动的回合，对方造成的伤害全部为0。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	-- 将怪兽不会被战斗破坏的效果注册给玩家，使其在当前回合内生效。
	Duel.RegisterEffect(e2,tp)
end
-- 判断伤害来源是否为对方，如果是对方造成的伤害则将其变为0。
function c88789641.val(e,re,val,r,rp,rc)
	if 1-e:GetHandlerPlayer()==rp then
		return 0
	else return val end
end
