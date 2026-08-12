--ケルベク
-- 效果：
-- 向这张卡攻击的怪兽回到持有者手卡。伤害计算适用。
function c54878498.initial_effect(c)
	-- 向这张卡攻击的怪兽回到持有者手卡。伤害计算适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54878498,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c54878498.condition)
	e1:SetTarget(c54878498.target)
	e1:SetOperation(c54878498.operation)
	c:RegisterEffect(e1)
end
-- 定义效果触发条件函数：此卡被攻击且攻击怪兽未被战斗破坏
function c54878498.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击对象是否为自身，且攻击怪兽未处于战斗破坏确定状态
	return Duel.GetAttackTarget()==e:GetHandler() and not Duel.GetAttacker():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 定义效果发动目标函数：设置将攻击怪兽送回手牌的操作信息
function c54878498.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将攻击怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,Duel.GetAttacker(),1,0,0)
end
-- 定义效果处理函数：将攻击怪兽送回持有者手牌
function c54878498.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	if not a:IsRelateToBattle() then return end
	-- 通过效果将攻击怪兽送回持有者的手牌
	Duel.SendtoHand(a,nil,REASON_EFFECT)
end
