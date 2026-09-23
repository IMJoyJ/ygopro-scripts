--ポルターガイスト
-- 效果：
-- ①：以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡回到持有者手卡。这张卡的发动和效果不会被无效化。
function c15866454.initial_effect(c)
	-- ①：以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetTarget(c15866454.target)
	e1:SetOperation(c15866454.activate)
	c:RegisterEffect(e1)
	-- 这张卡的发动和效果不会被无效化。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
end
-- 过滤要返回手牌的对方场上的魔法·陷阱卡
function c15866454.filter(c)
	return c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动取对象
function c15866454.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c15866454.filter(chkc) end
	-- 检查对方场上是否存在满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c15866454.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,c15866454.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将选中的对象卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将目标卡送回手卡
function c15866454.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡返回持有者手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
