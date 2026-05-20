--融爆
-- 效果：
-- ①：自己场上的卡被魔法卡的效果破坏时，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：自己场上的卡被魔法卡的效果破坏时，把墓地的这张卡除外，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果在这张卡送去墓地的回合不能发动。
function c68077936.initial_effect(c)
	-- ①：自己场上的卡被魔法卡的效果破坏时，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c68077936.condition)
	e1:SetTarget(c68077936.target)
	e1:SetOperation(c68077936.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的卡被魔法卡的效果破坏时，把墓地的这张卡除外，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c68077936.descon)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c68077936.target)
	e2:SetOperation(c68077936.activate)
	c:RegisterEffect(e2)
end
-- 过滤条件：原本在自己场上且因效果被破坏的卡
function c68077936.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
end
-- 效果①的发动条件：自己场上的卡被魔法卡的效果破坏时
function c68077936.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c68077936.cfilter,1,nil,tp) and re and re:IsActiveType(TYPE_SPELL)
end
-- 效果的发动准备：检查并选择对方场上1张卡作为对象，并设置破坏的操作信息
function c68077936.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 在发动阶段，检查对方场上是否存在至少1张可以作为对象的目标卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向发动玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏作为对象的卡
function c68077936.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果②的发动条件：自己场上的卡被魔法卡的效果破坏时，且不在送去墓地的回合
function c68077936.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有自己场上的卡被魔法卡的效果破坏，并确认当前不是该卡送去墓地的回合
	return eg:IsExists(c68077936.cfilter,1,nil,tp) and re and re:IsActiveType(TYPE_SPELL) and aux.exccon(e)
end
