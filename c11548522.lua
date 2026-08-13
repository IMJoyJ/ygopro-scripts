--迷犬マロン
-- 效果：
-- 当这张卡被送去墓地时，将这张卡回到卡组。
function c11548522.initial_effect(c)
	-- 当这张卡被送去墓地时，将这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11548522,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c11548522.target)
	e1:SetOperation(c11548522.operation)
	c:RegisterEffect(e1)
end
-- 发动时判定：在检查阶段直接允许发动；随后登记将这张卡返回卡组的操作信息。
function c11548522.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次效果处理将把这张卡返回卡组（CATEGORY_TODECK），对象为效果持有者，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果处理时：若这张卡仍与此效果关联，则将其返回持有者卡组并洗牌。
function c11548522.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 以效果原因将这张卡返回持有者卡组，并置于卡组中洗牌（SEQ_DECKSHUFFLE）。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
