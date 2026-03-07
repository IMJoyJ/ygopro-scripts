--炎星皇－チョウライオ
-- 效果：
-- 炎属性3星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己墓地1只炎属性怪兽为对象才能发动。那只炎属性怪兽加入手卡。这个效果的发动后，直到回合结束时自己不能把作为对象的怪兽以及那些同名怪兽召唤·特殊召唤。
function c37057743.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足炎属性条件的怪兽作为素材进行叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),3,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己墓地1只炎属性怪兽为对象才能发动。那只炎属性怪兽加入手卡。这个效果的发动后，直到回合结束时自己不能把作为对象的怪兽以及那些同名怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37057743,0))  --"加入手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c37057743.thcost)
	e1:SetTarget(c37057743.thtg)
	e1:SetOperation(c37057743.thop)
	c:RegisterEffect(e1)
end
-- 支付效果代价，从自己场上移除1个超量素材
function c37057743.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤满足炎属性且能加入手牌的怪兽
function c37057743.filter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 设置效果目标，选择自己墓地1只符合条件的怪兽
function c37057743.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37057743.filter(chkc) end
	-- 检查是否存符合条件的墓地怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c37057743.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择符合条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c37057743.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，确定将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果发动后的操作，将对象怪兽加入手牌并设置召唤限制
function c37057743.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽有效且为炎属性，并成功将其加入手牌
	if tc:IsRelateToEffect(e) and tc:IsAttribute(ATTRIBUTE_FIRE) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		-- 这个效果的发动后，直到回合结束时自己不能把作为对象的怪兽以及那些同名怪兽召唤·特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c37057743.sumlimit)
		e1:SetLabel(tc:GetCode())
		-- 注册不能特殊召唤效果，限制对象怪兽及其同名怪兽在本回合召唤或特殊召唤
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SUMMON)
		-- 注册不能召唤效果，限制对象怪兽及其同名怪兽在本回合召唤或特殊召唤
		Duel.RegisterEffect(e2,tp)
	end
end
-- 设置召唤限制效果的目标，限制同名怪兽的召唤与特殊召唤
function c37057743.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end
