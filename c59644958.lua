--オーバーレイ・オウル
-- 效果：
-- 1回合1次，支付600基本分才能发动。把场上1个超量素材取除。
function c59644958.initial_effect(c)
	-- 1回合1次，支付600基本分才能发动。把场上1个超量素材取除。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59644958,0))  --"去除素材"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c59644958.cost)
	e1:SetTarget(c59644958.target)
	e1:SetOperation(c59644958.operation)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理：检查并支付600基本分
function c59644958.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付600点基本分
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 支付600点基本分
	Duel.PayLPCost(tp,600)
end
-- 发动条件（Target）处理：检查场上是否存在可取除的超量素材
function c59644958.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少拥有1个超量素材的怪兽
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) end
end
-- 效果处理（Operation）：选择场上1只怪兽并取除其1个超量素材
function c59644958.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的提示信息为“请选择要取除超量素材的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	-- 让玩家在双方场上选择1只拥有超量素材的怪兽
	local sg=Duel.SelectMatchingCard(tp,Card.CheckRemoveOverlayCard,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,1,REASON_EFFECT)
	if sg:GetCount()==0 then return end
	-- 对选中的怪兽进行闪烁提示以确认对象
	Duel.HintSelection(sg)
	sg:GetFirst():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
