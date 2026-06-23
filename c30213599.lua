--墓守の末裔
-- 效果：
-- 把这张卡以外的自己场上表侧表示存在的1只名字带有「守墓」的怪兽解放才能发动。选择对方场上1张卡破坏。
function c30213599.initial_effect(c)
	-- 创建一个起动效果，效果描述为“破坏”，分类为破坏，类型为起动效果，具有取对象属性，生效位置为主怪兽区，设定了费用函数、目标函数和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30213599,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c30213599.cost)
	e1:SetTarget(c30213599.target)
	e1:SetOperation(c30213599.operation)
	c:RegisterEffect(e1)
end
-- 费用过滤器函数，用于判断怪兽是否为表侧表示且名字带有「守墓」
function c30213599.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2e)
end
-- 效果的费用处理函数，检查是否满足解放条件并选择解放对象，然后进行解放操作
function c30213599.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少一张满足费用过滤条件且不等于自身的效果对象
	if chk==0 then return Duel.CheckReleaseGroup(tp,c30213599.costfilter,1,e:GetHandler()) end
	-- 从玩家场上选择一张满足费用过滤条件且不等于自身的卡作为解放对象
	local sg=Duel.SelectReleaseGroup(tp,c30213599.costfilter,1,1,e:GetHandler())
	-- 以代价原因解放已选择的卡
	Duel.Release(sg,REASON_COST)
end
-- 效果的目标选择函数，用于选择对方场上的卡作为破坏对象
function c30213599.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查对方场上是否存在至少一张可以成为破坏对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送提示信息“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息，指定破坏效果的目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果的处理函数，用于对目标卡进行破坏
function c30213599.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
