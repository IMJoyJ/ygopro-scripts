--ヴァイロン・エプシロン
-- 效果：
-- 光属性调整＋调整以外的怪兽1只以上
-- 这张卡装备的装备卡不能成为魔法·陷阱·效果怪兽的效果的对象。1回合1次，可以把这张卡装备的1张装备卡送去墓地，选择对方场上存在的1只怪兽破坏。
function c75779210.initial_effect(c)
	-- 添加同调召唤手续：光属性调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡装备的装备卡不能成为魔法·陷阱·效果怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c75779210.uttg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把这张卡装备的1张装备卡送去墓地，选择对方场上存在的1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75779210,0))  --"对方场上的1只怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c75779210.descost)
	e2:SetTarget(c75779210.destg)
	e2:SetOperation(c75779210.desop)
	c:RegisterEffect(e2)
end
-- 过滤出属于这张卡装备卡组中的卡片（用于确定不能成为效果对象的目标范围）
function c75779210.uttg(e,c)
	return e:GetHandler():GetEquipGroup():IsContains(c)
end
-- 破坏效果的发动代价：检查并选择这张卡装备的1张装备卡送去墓地
function c75779210.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():IsExists(Card.IsAbleToGraveAsCost,1,nil) end
	-- 给玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():FilterSelect(tp,Card.IsAbleToGraveAsCost,1,1,nil)
	-- 将选中的装备卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 破坏效果的发动准备：检查并选择对方场上的1只怪兽作为效果对象
function c75779210.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动准备阶段：检查对方场上是否存在可以作为对象的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的实际处理：破坏选中的对方怪兽
function c75779210.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
