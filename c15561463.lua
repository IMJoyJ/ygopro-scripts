--ガントレット・シューター
-- 效果：
-- 6星怪兽×2
-- 自己的主要阶段时，把这张卡1个超量素材取除，选择对方场上1只怪兽才能发动。选择的怪兽破坏。
function c15561463.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用任意2只等级6的怪兽作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- 自己的主要阶段时，把这张卡1个超量素材取除，选择对方场上1只怪兽才能发动。选择的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetDescription(aux.Stringid(15561463,0))  --"怪兽破坏"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c15561463.descost)
	e1:SetTarget(c15561463.destg)
	e1:SetOperation(c15561463.desop)
	c:RegisterEffect(e1)
end
-- 效果发动代价：首先检查这张卡能否由自己取除1个超量素材；可以则实际以REASON_COST取除1个超量素材作为发动代价。
function c15561463.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果对象选择与合法性判定：确认指定对象是对方场上的怪兽且存在可选择的怪兽，随后提示并选择1只对方场上的怪兽作为效果对象，同时登记破坏信息。
function c15561463.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动前检查：确认对方场上存在至少1只能够成为效果对象的怪兽，否则不能发动效果。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示信息，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1只怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：向引擎登记本次效果将破坏这1张对象怪兽，以便其他卡牌响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取回连锁开始时选择的对象怪兽，若该卡仍与效果关联，则将其破坏。
function c15561463.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时需要破坏的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
