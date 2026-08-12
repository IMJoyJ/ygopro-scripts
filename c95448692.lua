--ダメージ・ダイエット
-- 效果：
-- 这个回合自己受到的全部伤害变成一半。此外，可以把墓地存在的这张卡从游戏中除外，那个回合自己受到的效果伤害变成一半。
function c95448692.initial_effect(c)
	-- 这个回合自己受到的全部伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c95448692.activate)
	c:RegisterEffect(e1)
	-- 此外，可以把墓地存在的这张卡从游戏中除外，那个回合自己受到的效果伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	-- 把墓地的这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c95448692.activate2)
	c:RegisterEffect(e2)
end
c95448692[0]=0
c95448692[1]=0
-- 卡片发动时的效果处理：标记为全部伤害减半，并注册全局伤害减半效果
function c95448692.activate(e,tp,eg,ep,ev,re,r,rp)
	c95448692[tp]=1
	-- 若本回合已注册过该减半效果，则不再重复注册
	if Duel.GetFlagEffect(tp,95448692)~=0 then return end
	-- 这个回合自己受到的全部伤害变成一半。此外，可以把墓地存在的这张卡从游戏中除外，那个回合自己受到的效果伤害变成一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c95448692.val)
	e1:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将伤害减半的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个回合内有效的标识效果，防止重复注册伤害减半效果
	Duel.RegisterFlagEffect(tp,95448692,RESET_PHASE+PHASE_END,0,1)
end
-- 墓地效果发动时的效果处理：标记为仅效果伤害减半，并注册全局伤害减半效果
function c95448692.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 若本回合已注册过该减半效果，则不再重复注册
	if Duel.GetFlagEffect(tp,95448692)~=0 then return end
	c95448692[tp]=0
	-- 这个回合自己受到的全部伤害变成一半。此外，可以把墓地存在的这张卡从游戏中除外，那个回合自己受到的效果伤害变成一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c95448692.val)
	e1:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将伤害减半的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个回合内有效的标识效果，防止重复注册伤害减半效果
	Duel.RegisterFlagEffect(tp,95448692,RESET_PHASE+PHASE_END,0,1)
end
-- 伤害计算时的过滤与处理：若为卡片发动回合则全部伤害减半，若为墓地效果发动回合则仅效果伤害减半
function c95448692.val(e,re,dam,r,rp,rc)
	if c95448692[e:GetOwnerPlayer()]==1 or bit.band(r,REASON_EFFECT)~=0 then
		return math.floor(dam/2)
	else return dam end
end
