--「A」細胞増殖装置
-- 效果：
-- 每次自己的准备阶段给对方场上表侧表示存在的1只怪兽放置1个A指示物。
function c34541863.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发必发效果，用于在准备阶段给对方场上表侧表示存在的1只怪兽放置1个A指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34541863,0))  --"放置「A指示物」"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c34541863.condition)
	e2:SetTarget(c34541863.target)
	e2:SetOperation(c34541863.operation)
	c:RegisterEffect(e2)
end
c34541863.counter_add_list={0x100e}
-- 判断是否为自己的回合
function c34541863.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 选择对方场上可以放置A指示物的1只表侧表示怪兽作为效果对象
function c34541863.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x100e,1) end
	-- 检查对方场上是否存在可以放置A指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只可以放置A指示物的怪兽
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x100e,1)
	-- 设置效果处理时要放置1个A指示物的目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x100e,1)
end
-- 将选择的怪兽放置1个A指示物
function c34541863.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x100e,1)
	end
end
