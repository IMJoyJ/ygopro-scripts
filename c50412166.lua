--シャブティのお守り
-- 效果：
-- 从手卡丢弃这张卡。到本回合结束阶段为止，自己场上名称中带有「守墓」的怪兽卡所受战斗伤害为0。
function c50412166.initial_effect(c)
	-- 从手卡丢弃这张卡。到本回合结束阶段为止，自己场上名称中带有「守墓」的怪兽卡所受战斗伤害为0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50412166,0))  --"名称中带有「守墓」的怪兽卡所受战斗伤害为0"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c50412166.condition)
	e1:SetCost(c50412166.cost)
	e1:SetOperation(c50412166.operation)
	c:RegisterEffect(e1)
end
-- 限制效果只能在主要阶段2和结束阶段以外的阶段发动
function c50412166.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph~=PHASE_MAIN2 and ph~=PHASE_END
end
-- 定义效果发动的代价，要求将自身从手牌丢弃
function c50412166.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为发动代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 定义效果处理，在全局注册一个直到回合结束为止使我方「守墓」怪兽不会被战斗破坏的效果
function c50412166.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 到本回合结束阶段为止，自己场上名称中带有「守墓」的怪兽卡所受战斗伤害为0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 过滤并指定受影响的卡片为名称中带有「守墓」（0x2e）的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2e))
	e1:SetValue(1)
	-- 将该效果注册给玩家，使其在全局环境中生效
	Duel.RegisterEffect(e1,tp)
end
