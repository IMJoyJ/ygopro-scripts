--幻影の壁
-- 效果：
-- 向这张卡攻击的怪兽回到持有者手卡。伤害计算适用。
function c13945283.initial_effect(c)
	-- 向这张卡攻击的怪兽回到持有者手卡。伤害计算适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13945283,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c13945283.condition)
	e1:SetTarget(c13945283.target)
	e1:SetOperation(c13945283.operation)
	c:RegisterEffect(e1)
end
-- 效果条件函数定义
function c13945283.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击目标为该卡且攻击怪兽未因战斗破坏而离场
	return Duel.GetAttackTarget()==e:GetHandler() and not Duel.GetAttacker():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果目标函数定义
function c13945283.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，指定将攻击怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,Duel.GetAttacker(),1,0,0)
end
-- 效果处理函数定义
function c13945283.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	if not a:IsRelateToBattle() then return end
	-- 将攻击怪兽送回持有者手牌
	Duel.SendtoHand(a,nil,REASON_EFFECT)
end
