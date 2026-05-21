--プラズマ・ボール
-- 效果：
-- 这张卡可以直接攻击对方玩家。这张卡直接攻击给与对方基本分战斗伤害时，这张卡破坏。
function c92595545.initial_effect(c)
	-- 这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- 这张卡直接攻击给与对方基本分战斗伤害时，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92595545,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c92595545.condition)
	e2:SetTarget(c92595545.target)
	e2:SetOperation(c92595545.operation)
	c:RegisterEffect(e2)
end
-- 定义效果发动的条件函数：给与对方玩家战斗伤害且为直接攻击
function c92595545.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否满足：受到伤害的玩家是对方，且攻击对象为空（即直接攻击）
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 定义效果发动的目标处理函数：因为是必发效果，直接返回true，并设置破坏自身的操作信息
function c92595545.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：破坏这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 定义效果运行函数：若这张卡在场上，则将其破坏
function c92595545.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 因效果破坏这张卡自身
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
