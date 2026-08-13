--暗黒界の策士 グリン
-- 效果：
-- ①：这张卡被效果从手卡丢弃去墓地的场合，以场上1张魔法·陷阱卡为对象发动。那张卡破坏。
function c51232472.initial_effect(c)
	-- ①：这张卡被效果从手卡丢弃去墓地的场合，以场上1张魔法·陷阱卡为对象发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51232472,0))  --"把场上1张魔法或者陷阱卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c51232472.descon)
	e1:SetTarget(c51232472.destg)
	e1:SetOperation(c51232472.desop)
	c:RegisterEffect(e1)
end
-- 判断触发条件：这张卡是从手牌被效果丢弃去墓地（之前位置为手牌且丢弃原因为效果丢弃）。
function c51232472.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 判断卡片是否为魔法或陷阱卡。
function c51232472.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时的目标处理：先排除已确定对象的情况，然后检查是否需要发动；接着提示玩家选择要破坏的卡，选择场上1张魔法·陷阱卡作为对象，并登记破坏效果的操作信息。
function c51232472.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c51232472.desfilter(chkc) end
	if chk==0 then return true end
	-- 弹出选择提示，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c51232472.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记操作信息：本次连锁将破坏所选择的对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时：取得对象卡，若该卡仍与效果关联，则将其破坏。
function c51232472.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
