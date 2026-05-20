--黒魔力の精製者
-- 效果：
-- 1回合1次，可以把自己场上表侧攻击表示存在的这张卡变更为表侧守备表示，并给自己场上表侧表示存在的1张可以放置魔力指示物的卡放置1个魔力指示物。
function c78121572.initial_effect(c)
	-- 1回合1次，可以把自己场上表侧攻击表示存在的这张卡变更为表侧守备表示，并给自己场上表侧表示存在的1张可以放置魔力指示物的卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78121572,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c78121572.con)
	e1:SetTarget(c78121572.tg)
	e1:SetOperation(c78121572.op)
	c:RegisterEffect(e1)
end
-- 判断自身是否处于表侧攻击表示（作为效果发动的条件）
function c78121572.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 过滤自己场上表侧表示且可以放置魔力指示物的卡片
function c78121572.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- 效果发动的靶向/对象选择处理，确认是否存在合法对象并选择1张卡作为效果对象
function c78121572.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c78121572.filter(chkc) end
	-- 在发动阶段，检查场上是否存在可以放置魔力指示物的合法对象
	if chk==0 then return Duel.IsExistingTarget(c78121572.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 在客户端显示提示信息：请选择要放置指示物的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 选择自己场上1张可以放置魔力指示物的表侧表示卡片作为效果对象
	local g=Duel.SelectTarget(tp,c78121572.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置效果处理信息为放置1个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 效果处理：将自身变更为表侧守备表示，并给对象卡片放置1个魔力指示物
function c78121572.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的放置魔力指示物的对象卡片
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) then
		-- 将自身变更为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		if tc:IsRelateToEffect(e) then
			tc:AddCounter(0x1,1)
		end
	end
end
