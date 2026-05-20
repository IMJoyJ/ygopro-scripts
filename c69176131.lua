--スペース・サイクロン
-- 效果：
-- 把场上存在的1个超量素材取除。
function c69176131.initial_effect(c)
	-- 把场上存在的1个超量素材取除。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c69176131.target)
	e1:SetOperation(c69176131.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的可行性检查函数，用于确认当前时点是否满足发动条件
function c69176131.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1个可以因效果取除的超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) end
end
-- 效果处理函数，执行选择场上怪兽并取除其1个超量素材的操作
function c69176131.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家提示选择要取除超量素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	-- 让玩家从双方场上选择1只拥有可被效果取除的超量素材的怪兽
	local sg=Duel.SelectMatchingCard(tp,Card.CheckRemoveOverlayCard,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,1,REASON_EFFECT)
	if sg:GetCount()==0 then return end
	-- 为选中的怪兽显示对象选择动画效果，并记录为被选择的状态
	Duel.HintSelection(sg)
	sg:GetFirst():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
