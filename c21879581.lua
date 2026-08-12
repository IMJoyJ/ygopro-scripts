--シンクロ・バリアー
-- 效果：
-- 把自己场上存在的1只同调怪兽解放发动。直到下个回合的结束阶段时，自己受到的全部伤害变成0。
function c21879581.initial_effect(c)
	-- 效果发动条件：支付1只场上同调怪兽的解放作为代价。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c21879581.cost)
	e1:SetOperation(c21879581.activate)
	c:RegisterEffect(e1)
end
-- 检查玩家场上是否存在至少1只同调怪兽可解放。
function c21879581.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索满足条件的同调怪兽组。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsType,1,nil,TYPE_SYNCHRO) end
	-- 将目标同调怪兽解放作为发动代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,1,1,nil,TYPE_SYNCHRO)
	-- 将选中的同调怪兽解放。
	Duel.Release(g,REASON_COST)
end
-- 效果发动时，使自己受到的伤害变为0。
function c21879581.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 直到下个回合的结束阶段时，自己受到的全部伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 注册伤害变更效果，使玩家受到的伤害归零。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	-- 注册效果伤害免疫效果，防止受到效果伤害。
	Duel.RegisterEffect(e2,tp)
end
