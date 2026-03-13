--カイザー・グライダー
-- 效果：
-- ①：这张卡不会被和相同攻击力的怪兽的战斗破坏。
-- ②：这张卡被破坏送去墓地的场合，以场上1只怪兽为对象发动。那只怪兽回到持有者手卡。
function c52824910.initial_effect(c)
	-- 效果原文内容：①：这张卡不会被和相同攻击力的怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c52824910.indes)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡被破坏送去墓地的场合，以场上1只怪兽为对象发动。那只怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52824910,0))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c52824910.condition)
	e2:SetTarget(c52824910.target)
	e2:SetOperation(c52824910.operation)
	c:RegisterEffect(e2)
end
-- 规则层面操作：判断攻击怪兽是否与自身攻击力相同
function c52824910.indes(e,c)
	return c:IsAttack(e:GetHandler():GetAttack())
end
-- 规则层面操作：判断此卡是否因战斗破坏而进入墓地
function c52824910.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 规则层面操作：选择场上一只可送回手牌的怪兽作为对象
function c52824910.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 规则层面操作：向玩家提示“请选择要返回手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 规则层面操作：选择目标怪兽
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 规则层面操作：设置连锁操作信息为将目标怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 规则层面操作：执行将目标怪兽送回手牌的效果处理
function c52824910.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁的处理对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 规则层面操作：将目标怪兽以效果原因送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
