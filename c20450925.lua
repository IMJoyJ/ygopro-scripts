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
-- 检查是否可以丢弃此卡作为发动代价
function c20450925.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡丢入墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 将效果伤害变为0并使玩家不受效果伤害
function c20450925.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使玩家在本回合内受到的效果伤害归零
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c20450925.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果伤害变更效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册玩家不受效果伤害效果
	Duel.RegisterEffect(e2,tp)
end
-- 判断伤害是否由效果造成，若是则伤害归零
function c20450925.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end
