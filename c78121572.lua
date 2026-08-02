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
-- 起动效果的发动条件：此卡必须是表侧攻击表示
function c78121572.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 过滤函数：检查卡片是否表侧表示且可以放置1个魔力指示物
function c78121572.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- 起动效果的目标：选择自己场上1张符合条件的卡作为对象，并设置指示物相关的操作信息
function c78121572.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c78121572.filter(chkc) end
	-- 检查自己场上是否存在符合条件的可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(c78121572.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 给玩家发送选择要放置指示物的卡的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 让玩家从自己场上选择1张符合条件的卡作为目标对象
	local g=Duel.SelectTarget(tp,c78121572.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息：包含放置1个魔力指示物的效果
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 起动效果的处理：将此卡变为表侧守备表示，然后给目标卡放置1个魔力指示物
function c78121572.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动效果时选择的目标卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) then
		-- 将此卡的表示形式改变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		if tc:IsRelateToEffect(e) then
			tc:AddCounter(0x1,1)
		end
	end
end
