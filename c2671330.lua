--ハイパーハンマーヘッド
-- 效果：
-- 与这张卡进行战斗且未被破坏的对方怪兽，在伤害步骤终了时弹回其持有者手卡。
function c2671330.initial_effect(c)
	-- 创建一个诱发必发效果，用于在伤害步骤结束时触发
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2671330,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c2671330.retcon)
	e1:SetTarget(c2671330.rettg)
	e1:SetOperation(c2671330.retop)
	c:RegisterEffect(e1)
end
-- 判断效果发动条件：获取战斗中的对方怪兽并检查其是否与战斗相关
function c2671330.retcon(e,tp,eg,ep,ev,re,r,rp)
	local t=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(t)
	-- 条件判断：确保怪兽在战斗中且未被破坏
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and t and t:IsRelateToBattle()
end
-- 设置效果目标：将参与战斗的对方怪兽设为回手牌的目标
function c2671330.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：指定回手牌效果的处理对象和数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetLabelObject(),1,0,0)
end
-- 执行效果处理：若怪兽仍与战斗相关则将其送回持有者手牌
function c2671330.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():IsRelateToBattle() then
		-- 将指定怪兽以效果原因送回其持有者手牌
		Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
	end
end
