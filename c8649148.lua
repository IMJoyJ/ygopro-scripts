--ディープ・スィーパー
-- 效果：
-- 把这张卡解放才能发动。选择场上1张魔法·陷阱卡破坏。
function c8649148.initial_effect(c)
	-- 把这张卡解放才能发动。选择场上1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8649148,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c8649148.cost)
	e1:SetTarget(c8649148.target)
	e1:SetOperation(c8649148.operation)
	c:RegisterEffect(e1)
end
-- 发动代价处理：检查自身是否可以解放，并执行解放操作。
function c8649148.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：判断卡片是否为魔法或陷阱卡。
function c8649148.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果目标处理：检查并选择场上1张魔法·陷阱卡作为对象，并设置破坏的操作信息。
function c8649148.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c8649148.filter(chkc) end
	-- 在发动阶段检查场上是否存在可以作为对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c8649148.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向发动玩家发送提示信息，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为效果的对象。
	local g=Duel.SelectTarget(tp,c8649148.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理的操作信息，准备破坏选中的卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：获取对象卡片，若其仍符合条件则将其破坏。
function c8649148.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选中的第一个对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
