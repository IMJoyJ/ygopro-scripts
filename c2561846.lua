--侵食細胞「A」
-- 效果：
-- 对方场上表侧表示存在的1只怪兽放置1个A指示物。
function c2561846.initial_effect(c)
	-- 效果定义：将效果注册为发动时取对象的魔法卡，具有指示物效果，可自由连锁发动。
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
-- 效果处理：选择对方场上表侧表示存在的1只可放置A指示物的怪兽作为对象。
function c2561846.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x100e,1) end
	-- 条件判断：检查对方场上是否存在可放置A指示物的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 提示信息：向玩家提示选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标：选择对方场上1只可放置A指示物的怪兽作为目标。
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x100e,1)
	-- 设置操作信息：设置本次效果将放置1个A指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x100e,1)
end
-- 效果执行：对目标怪兽放置1个A指示物。
function c2561846.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标：获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		tc:AddCounter(0x100e,1)
	end
end
