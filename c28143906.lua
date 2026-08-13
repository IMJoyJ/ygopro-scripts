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
-- 触发条件判定：这张卡被送去墓地前所在的位置是手牌，即效果只在这个场合发动。
function c28143906.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 效果发动时的目标处理：无取对象，直接允许发动，并设置本次操作将包含回卡组的效果信息。
function c28143906.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将这张卡自身确定为回卡组处理的对象，数量为1，回持有者卡组（位置不确定，由后续处理决定）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果处理时的操作：若这张卡仍与当前效果保持关联，则将其送回卡组并按规则洗切。
function c28143906.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡送去其持有者的卡组，并指定为洗牌（洗切）处理，原因是效果所致。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
