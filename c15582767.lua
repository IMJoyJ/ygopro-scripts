--連成する振動
-- 效果：
-- 「连成的振动」的效果1回合只能使用1次。
-- ①：以自己的灵摆区域1张卡为对象才能把这个效果发动。那张卡破坏，那之后，自己从卡组抽1张。
function c15582767.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己的灵摆区域1张卡为对象才能把这个效果发动。那张卡破坏，那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15582767,0))  --"是否立刻使用这张卡的效果？"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,15582767)
	e2:SetTarget(c15582767.target)
	e2:SetOperation(c15582767.operation)
	c:RegisterEffect(e2)
end
-- 检查是否满足发动条件
function c15582767.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) end
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查场上是否存在满足条件的目标卡
		and Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择一个目标卡
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,0,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理效果的发动
function c15582767.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡有效且成功破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 让玩家抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
