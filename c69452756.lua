--醒めない悪夢
-- 效果：
-- 这个卡名的效果在同一连锁上只能发动1次。
-- ①：支付1000基本分，以场上1张表侧表示的魔法·陷阱卡为对象才能把这个效果发动。那张卡破坏。
function c69452756.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	c:RegisterEffect(e1)
	-- 这个卡名的效果在同一连锁上只能发动1次。①：支付1000基本分，以场上1张表侧表示的魔法·陷阱卡为对象才能把这个效果发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69452756,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e2:SetCountLimit(1,69452756+EFFECT_COUNT_CODE_CHAIN)
	e2:SetCost(c69452756.cost)
	e2:SetTarget(c69452756.target)
	e2:SetOperation(c69452756.operation)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示的魔法·陷阱卡
function c69452756.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动的代价（Cost）处理函数
function c69452756.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分作为发动代价
	Duel.PayLPCost(tp,1000)
end
-- 效果发动的目标选择（Target）与合法性检查函数
function c69452756.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c69452756.filter(chkc) end
	local exc=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then exc=e:GetHandler() end
	-- 检查场上是否存在至少1张可以作为对象的表侧表示魔法·陷阱卡（若自身作为魔法·陷阱卡发动且尚未适用效果，则排除自身）
	if chk==0 then return Duel.IsExistingTarget(c69452756.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exc) end
	-- 向玩家发送提示信息，要求选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张表侧表示的魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c69452756.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exc)
	-- 设置效果处理信息，表明该效果包含破坏1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理（Operation）函数
function c69452756.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
