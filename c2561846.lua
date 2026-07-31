--侵食細胞「A」
-- 效果：
-- 对方场上表侧表示存在的1只怪兽放置1个A指示物。
function c2561846.initial_effect(c)
	-- 对方场上表侧表示存在的1只怪兽放置1个A指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c2561846.target)
	e1:SetOperation(c2561846.operation)
	c:RegisterEffect(e1)
end
c2561846.counter_add_list={0x100e}
c2561846.mentioned_counter={
	[0x100e]=true,
}
-- 检索满足条件的卡片组，即对方场上的表侧表示怪兽且能放置A指示物的怪兽
function c2561846.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x100e,1) end
	-- 判断是否满足发动条件，即对方场上是否存在可以放置A指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 向玩家提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽，要求为对方场上的表侧表示怪兽且能放置A指示物
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x100e,1)
	-- 设置连锁操作信息，指定将要放置1个A指示物到目标怪兽上
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x100e,1)
end
-- 效果处理函数，用于执行放置A指示物的操作
function c2561846.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		tc:AddCounter(0x100e,1)
	end
end
