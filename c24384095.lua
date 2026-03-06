--九蛇孔雀
-- 效果：
-- 场上的这张卡被解放送去墓地的场合，可以从自己的卡组·墓地选「九蛇孔雀」以外的1只4星以下的风属性怪兽加入手卡。「九蛇孔雀」的效果1回合只能使用1次。
function c24384095.initial_effect(c)
	-- 创建一个诱发选发效果，当此卡被解放送去墓地时可以发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24384095,0))  --"加入手牌"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,24384095)
	e1:SetCondition(c24384095.thcon)
	e1:SetTarget(c24384095.thtg)
	e1:SetOperation(c24384095.thop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：此卡从前场被解放送去墓地
function c24384095.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_RELEASE)
end
-- 过滤函数：返回等级4以下、风属性、不是九蛇孔雀且能加入手牌的怪兽
function c24384095.filter(c)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WIND) and not c:IsCode(24384095) and c:IsAbleToHand()
end
-- 效果发动时点的处理：检查自己卡组或墓地是否存在满足条件的怪兽
function c24384095.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组或墓地存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c24384095.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息：将1张符合条件的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理时的执行内容：提示选择并检索符合条件的怪兽加入手牌
function c24384095.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24384095.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
