--シンクロ・バリアー
-- 效果：
-- 把自己场上存在的1只同调怪兽解放发动。直到下个回合的结束阶段时，自己受到的全部伤害变成0。
function c21879581.initial_effect(c)
	-- 把自己场上存在的1只同调怪兽解放发动。直到下个回合的结束阶段时，自己受到的全部伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c21879581.cost)
	e1:SetOperation(c21879581.activate)
	c:RegisterEffect(e1)
end
-- 发动代价处理：从自己场上选择并解放1只同调怪兽作为发动费用。
function c21879581.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动时是否存在满足条件的可解放的同调怪兽（1只）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsType,1,nil,TYPE_SYNCHRO) end
	-- 从自己场上选择1只同调怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,1,1,nil,TYPE_SYNCHRO)
	-- 将选择的同调怪兽解放，作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 效果处理：给自己赋予直到下个回合结束阶段为止受到的伤害全部变成0的持续效果。
function c21879581.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 直到下个回合的结束阶段时，自己受到的全部伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将改变伤害数值为0的效果注册到己方，在该效果持续期间自己受到的任何伤害均变为0。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将效果伤害无效化的标记效果注册到己方，用于与其他效果联动，确保自身效果伤害也被视为0。
	Duel.RegisterEffect(e2,tp)
end
