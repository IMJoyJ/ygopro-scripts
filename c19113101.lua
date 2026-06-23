--プリベントマト
-- 效果：
-- 把墓地的这张卡从游戏中除外才能发动。这个回合，自己受到的效果伤害变成0。这个效果在对方回合才能发动。
function c19113101.initial_effect(c)
	-- 把墓地的这张卡从游戏中除外才能发动。这个回合，自己受到的效果伤害变成0。这个效果在对方回合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19113101,0))  --"效果无效"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c19113101.condition)
	-- 将此卡从游戏中除外作为费用
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c19113101.operation)
	c:RegisterEffect(e1)
end
-- 检查是否为对方回合
function c19113101.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是使用者则满足条件
	return Duel.GetTurnPlayer()~=tp
end
-- 将效果伤害变为0并使玩家不受效果伤害
function c19113101.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己受到的效果伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c19113101.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
end
-- 当伤害由效果造成时，伤害值变为0
function c19113101.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end
