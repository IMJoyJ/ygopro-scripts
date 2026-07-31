--黒魔力の精製者
-- 效果：
-- ①：1回合1次，以自己场上1张可以放置魔力指示物的卡为对象才能发动。自己场上的攻击表示的这张卡变成表侧守备表示，给作为对象的自己的卡放置1个魔力指示物。
function c78121572.initial_effect(c)
	-- ①：1回合1次，以自己场上1张可以放置魔力指示物的卡为对象才能发动。自己场上的攻击表示的这张卡变成表侧守备表示，给作为对象的自己的卡放置1个魔力指示物。
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
c78121572.mentioned_counter={
	[0x1]=true,
}
-- 发动条件：自己场上的这张卡为表侧攻击表示
function c78121572.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 指示物放置对象过滤：自己场上表侧表示且可以放置魔力指示物的卡
function c78121572.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- 放置指示物效果的发动准备与目标选择
function c78121572.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c78121572.filter(chkc) end
	-- 发动条件检查：自己场上存在可以放置魔力指示物的卡
	if chk==0 then return Duel.IsExistingTarget(c78121572.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要放置指示物的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 选择自己场上1张可以放置魔力指示物的卡作为对象
	local g=Duel.SelectTarget(tp,c78121572.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置连锁操作信息：放置1个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 放置指示物效果处理：这张卡变成表侧守备表示，并给作为对象的卡放置1个魔力指示物
function c78121572.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中的对象卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) then
		-- 将这张卡变成表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		if tc:IsRelateToEffect(e) then
			tc:AddCounter(0x1,1)
		end
	end
end
