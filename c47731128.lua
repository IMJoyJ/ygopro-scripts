--結界術師 メイコウ
-- 效果：
-- 把这张卡解放发动。场上表侧表示存在的1张永续魔法或者永续陷阱卡破坏。
function c47731128.initial_effect(c)
	-- 创建效果，设置效果描述为“破坏”，分类为破坏，属性为取对象，类型为起动效果，生效位置为主怪区，设置费用、目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47731128,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c47731128.cost)
	e1:SetTarget(c47731128.target)
	e1:SetOperation(c47731128.operation)
	c:RegisterEffect(e1)
end
-- 费用函数：检查是否可以解放此卡，若可以则进行解放操作
function c47731128.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡以代價原因进行解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：判断目标卡片是否为表侧表示的永续魔法或永续陷阱卡
function c47731128.filter(c)
	local tpe=c:GetType()
	return c:IsFaceup() and (tpe==0x20002 or bit.band(tpe,0x20004)==0x20004)
end
-- 目标选择函数：设置目标选择条件并选择一张符合条件的场上卡片作为破坏对象
function c47731128.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c47731128.filter(chkc) end
	-- 检查是否有满足条件的目标卡片存在
	if chk==0 then return Duel.IsExistingTarget(c47731128.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家发送提示信息“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择一张符合条件的场上卡片作为目标
	local g=Duel.SelectTarget(tp,c47731128.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，确定本次效果处理将破坏一张卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数：获取目标卡片并判断其是否仍然有效，若有效则将其破坏
function c47731128.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
