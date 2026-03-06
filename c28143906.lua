--霞の谷の大怪鳥
-- 效果：
-- 这张卡从手卡送去墓地时，这张卡加入卡组并且洗切。
function c28143906.initial_effect(c)
	-- 这张卡从手卡送去墓地时，这张卡加入卡组并且洗切。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28143906,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c28143906.retcon)
	e1:SetTarget(c28143906.rettg)
	e1:SetOperation(c28143906.retop)
	c:RegisterEffect(e1)
end
-- 效果发动的发动条件为：这张卡是从手卡送去墓地的
function c28143906.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 效果的处理目标设定为：将自身送回卡组
function c28143906.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，表明该效果属于回卡组类别
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果的处理执行函数，将符合条件的卡片送回卡组并洗切
function c28143906.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以效果原因送回卡组底部并洗牌
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
