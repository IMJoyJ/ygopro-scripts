--戦火の残滓
-- 效果：
-- ①：双方场上没有其他卡存在的场合，以自己墓地1只水·风属性怪兽为对象才能发动。那只水·风属性怪兽加入手卡。
function c82263578.initial_effect(c)
	-- ①：双方场上没有其他卡存在的场合，以自己墓地1只水·风属性怪兽为对象才能发动。那只水·风属性怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c82263578.condition)
	e1:SetTarget(c82263578.target)
	e1:SetOperation(c82263578.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：双方场上没有其他卡存在
function c82263578.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在除这张卡以外的任何卡片
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
end
-- 过滤函数：筛选自己墓地可以加入手牌的水属性或风属性怪兽
function c82263578.filter(c)
	return c:IsAttribute(ATTRIBUTE_WATER+ATTRIBUTE_WIND) and c:IsAbleToHand()
end
-- 定义效果发动时的目标选择与处理信息设置
function c82263578.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c82263578.filter(chkc) end
	-- 在发动阶段，检查自己墓地是否存在至少1只符合条件的水·风属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c82263578.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的水·风属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c82263578.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果处理（发动效果的实际执行）
function c82263578.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttribute(ATTRIBUTE_WATER+ATTRIBUTE_WIND) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
