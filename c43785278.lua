--フーコーの魔砲石
-- 效果：
-- ←2 【灵摆】 2→
-- ①：这张卡发动的回合的结束阶段，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
-- 【怪兽描述】
-- 是彷徨于梦幻空间的机关生命体，本应是如此。
-- 最大的谜团是，过去的记录却几乎··留下来。
-- 那理由···呢，·····干涉···它在···拒··？
-- ···消去···
function c43785278.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，但不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：这张卡发动的回合的结束阶段，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c43785278.reg)
	c:RegisterEffect(e1)
	-- ①：这张卡发动的回合的结束阶段，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43785278,0))  --"魔陷破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c43785278.descon)
	e2:SetTarget(c43785278.destg)
	e2:SetOperation(c43785278.desop)
	c:RegisterEffect(e2)
end
-- 支付发动费用时，为该卡注册一个标记，用于判断是否在发动回合的结束阶段触发效果
function c43785278.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(43785278,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 判断是否在发动回合的结束阶段触发效果，通过检查是否有标记来判断
function c43785278.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(43785278)~=0
end
-- 过滤函数，用于筛选场上表侧表示的魔法·陷阱卡
function c43785278.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果的目标选择逻辑，选择场上一张表侧表示的魔法·陷阱卡作为破坏对象
function c43785278.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c43785278.filter(chkc) end
	-- 检查是否有满足条件的魔法·陷阱卡可作为破坏对象
	if chk==0 then return Duel.IsExistingTarget(c43785278.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张表侧表示的魔法·陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c43785278.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果的操作信息，确定破坏的卡为选择的目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果的处理逻辑，若目标卡存在且表侧表示，则将其破坏
function c43785278.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 以效果原因将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
