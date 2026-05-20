--ダーク・バースト
-- 效果：
-- ①：以自己墓地1只攻击力1500以下的暗属性怪兽为对象才能发动。那只暗属性怪兽加入手卡。
function c674561.initial_effect(c)
	-- ①：以自己墓地1只攻击力1500以下的暗属性怪兽为对象才能发动。那只暗属性怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c674561.target)
	e1:SetOperation(c674561.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：攻击力1500以下、暗属性且可以加入手牌的怪兽
function c674561.filter(c)
	return c:IsAttackBelow(1500) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 效果发动的目标选择：检查并选择自己墓地1只符合条件的暗属性怪兽作为对象
function c674561.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c674561.filter(chkc) end
	-- 在发动阶段（chk==0）检查自己墓地是否存在至少1只符合条件的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c674561.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向发动效果的玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c674561.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，表示该连锁的操作是将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将发动时选择的对象怪兽加入手牌
function c674561.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttribute(ATTRIBUTE_DARK) then
		-- 将目标怪兽因效果加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
