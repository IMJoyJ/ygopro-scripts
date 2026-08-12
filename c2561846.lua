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
-- 效果发动的取对象处理：确认对方场上存在可以放置A指示物的表侧表示怪兽，选择其中1只作为效果对象，并设置指示物效果的操作信息
function c2561846.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x100e,1) end
	-- 发动条件检测：确认对方场上存在1只可以放置1个A指示物的、能成为效果对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 向发动玩家提示请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只可以放置1个A指示物的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x100e,1)
	-- 设置连锁的操作信息为指示物效果（CATEGORY_COUNTER），对象为选择的怪兽，处理数量为1只
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x100e,1)
end
-- 效果处理：取得对象怪兽，若其为表侧表示、仍与本效果有联系且由对方控制，则为其放置1个A指示物
function c2561846.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		tc:AddCounter(0x100e,1)
	end
end
