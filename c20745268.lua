--魔弾－デスペラード
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「魔弹」怪兽存在的场合，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
function c20745268.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「魔弹」怪兽存在的场合，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,20745268+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c20745268.condition)
	e1:SetTarget(c20745268.target)
	e1:SetOperation(c20745268.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡片为表侧表示且字段为「魔弹」（0x108）。
function c20745268.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x108)
end
-- 发动条件：自己场上有满足条件的「魔弹」怪兽存在。
function c20745268.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方主要怪兽区是否存在至少1张表侧表示且为「魔弹」字段的怪兽。
	return Duel.IsExistingMatchingCard(c20745268.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 取对象效果的目标选择处理：从双方场上选择1张表侧表示卡（不能选自身）作为对象，并设置破坏信息。
function c20745268.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc~=c end
	-- 效果发动时点检查：场上是否存在符合条件的表侧表示卡可以作为对象（除自身外）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张表侧表示卡作为效果对象（不能选自身），并将该卡设为连锁对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置本次连锁的操作信息为破坏1张卡，记录对象卡组和数量，供后续效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得效果对象，若对象仍与效果关联，则将其破坏。
function c20745268.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
