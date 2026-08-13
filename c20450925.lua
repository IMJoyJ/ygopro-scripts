--ハネワタ
-- 效果：
-- ①：把这张卡从手卡丢弃才能发动。这个回合，自己受到的效果伤害变成0。这个效果在对方回合也能发动。
function c20450925.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。这个回合，自己受到的效果伤害变成0。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20450925,0))  --"效果伤害变成０"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c20450925.cost)
	e1:SetOperation(c20450925.operation)
	c:RegisterEffect(e1)
end
-- 代价函数：若为检查阶段(chk==0)，则判断手牌的这张卡能否作为代价丢弃；若为执行阶段，则将其丢弃。
function c20450925.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手卡丢弃送去墓地，作为发动效果的代价（REASON_COST+REASON_DISCARD）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果处理：在场上登记一个针对己方玩家的领域效果，将本回合自己受到的效果伤害改为0，并另设一个标记效果。
function c20450925.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己受到的效果伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c20450925.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将伤害变更效果e1注册给玩家tp，使其本回合受到效果伤害时调用damval进行计算。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将EFFECT_NO_EFFECT_DAMAGE标记效果注册给玩家tp，表示本回合已适用效果伤害变成0的防护。
	Duel.RegisterEffect(e2,tp)
end
-- 伤害值变更函数：若伤害来源含REASON_EFFECT（效果伤害），则把伤害改为0；否则保留原伤害值。
function c20450925.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end
