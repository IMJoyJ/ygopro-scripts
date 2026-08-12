--ガントレット・シューター
-- 效果：
-- 6星怪兽×2
-- 自己的主要阶段时，把这张卡1个超量素材取除，选择对方场上1只怪兽才能发动。选择的怪兽破坏。
function c15561463.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足条件的6星怪兽叠放2只以上
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
-- 效果处理时检查是否能移除1个超量素材作为费用
function c15561463.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果的目标选择函数，选择对方场上的1只怪兽
function c15561463.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 判断是否对方场上存在可以成为破坏对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果的处理信息，确定将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，对选中的怪兽进行破坏
function c15561463.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果为原因进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
