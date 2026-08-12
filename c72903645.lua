--マグナ・スラッシュドラゴン
-- 效果：
-- 把自己场上存在的1张表侧表示的永续魔法卡送去墓地。对方场上的1张魔法或者陷阱卡破坏。
function c72903645.initial_effect(c)
	-- 把自己场上存在的1张表侧表示的永续魔法卡送去墓地。对方场上的1张魔法或者陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72903645,0))  --"魔陷破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c72903645.descost)
	e1:SetTarget(c72903645.destg)
	e1:SetOperation(c72903645.desop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示且可以作为代价送去墓地的永续魔法卡
function c72903645.cfilter(c)
	return c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsAbleToGraveAsCost()
end
-- 代价处理：把自己场上1张表侧表示的永续魔法卡送去墓地
function c72903645.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在满足送去墓地条件的表侧表示永续魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c72903645.cfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1张表侧表示的永续魔法卡
	local g=Duel.SelectMatchingCard(tp,c72903645.cfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选择的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：魔法或陷阱卡
function c72903645.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 目标处理：选择对方场上1张魔法或陷阱卡作为效果对象
function c72903645.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c72903645.filter(chkc) end
	-- 检查对方场上是否存在可以作为对象的魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c72903645.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法或陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c72903645.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏该对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏作为对象的卡
function c72903645.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
