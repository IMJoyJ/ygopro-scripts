--精神同調波
-- 效果：
-- 自己场上有同调怪兽表侧表示存在的场合才能发动。对方场上存在的1只怪兽破坏。
function c35537860.initial_effect(c)
	-- 效果定义：将效果注册为发动时点为自由时点、具有取对象、破坏分类的魔法卡效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c35537860.condition)
	e1:SetTarget(c35537860.target)
	e1:SetOperation(c35537860.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查自己场上是否存在表侧表示的同调怪兽
function c35537860.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 发动条件：判断自己场上是否存在至少1只表侧表示的同调怪兽
function c35537860.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查自己场上是否存在至少1只表侧表示的同调怪兽
	return Duel.IsExistingMatchingCard(c35537860.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果目标：选择对方场上1只怪兽作为破坏对象
function c35537860.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 规则层面作用：检查对方场上是否存在至少1只怪兽可以成为破坏对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示信息：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标：从对方场上选择1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将本次效果的破坏对象及数量记录到连锁信息中
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：对选定的怪兽进行破坏处理
function c35537860.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标：获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标怪兽以效果原因进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
