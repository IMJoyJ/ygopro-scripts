--悪夢再び
-- 效果：
-- ①：以自己墓地2只守备力0的暗属性怪兽为对象才能发动。那些暗属性怪兽加入手卡。
function c81191584.initial_effect(c)
	-- ①：以自己墓地2只守备力0的暗属性怪兽为对象才能发动。那些暗属性怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c81191584.target)
	e1:SetOperation(c81191584.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中守备力为0、暗属性且可以加入手卡的怪兽
function c81191584.filter(c)
	return c:IsDefense(0) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 效果发动的目标选择，确认并选择自己墓地2只守备力0的暗属性怪兽作为对象
function c81191584.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c81191584.filter(chkc) end
	-- 在发动阶段，检查自己墓地是否存在至少2只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c81191584.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地2只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c81191584.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置效果处理信息，声明此效果的操作为将2张目标卡片加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理，将仍存在于墓地且成为对象的怪兽加入手卡
function c81191584.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍符合条件的对象怪兽因效果加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
