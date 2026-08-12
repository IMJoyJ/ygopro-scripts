--エクシーズエナジー
-- 效果：
-- 把自己场上存在的1个超量素材取除发动。选择对方场上表侧表示存在的1只怪兽破坏。
function c85839825.initial_effect(c)
	-- 把自己场上存在的1个超量素材取除发动。选择对方场上表侧表示存在的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c85839825.cost)
	e1:SetTarget(c85839825.target)
	e1:SetOperation(c85839825.activate)
	c:RegisterEffect(e1)
end
-- 发动代价：把自己场上存在的1个超量素材取除
function c85839825.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可以取除超量素材的怪兽
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 提示玩家选择要取除超量素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	-- 选择自己场上1只拥有超量素材的怪兽
	local sg=Duel.SelectMatchingCard(tp,Card.CheckRemoveOverlayCard,tp,LOCATION_MZONE,0,1,1,nil,tp,1,REASON_COST)
	sg:GetFirst():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：表侧表示的卡片
function c85839825.filter(c)
	return c:IsFaceup()
end
-- 效果的目标选择：选择对方场上表侧表示存在的1只怪兽
function c85839825.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c85839825.filter(chkc) end
	-- 检查对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c85839825.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c85839825.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，准备破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：将选择的怪兽破坏
function c85839825.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 因效果将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
