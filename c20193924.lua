--白夜の女王
-- 效果：
-- 这张卡不能特殊召唤。1回合1次，可以把场上盖放的1张卡破坏。
function c20193924.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把场上盖放的1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20193924,0))  --"场上盖放的1张卡破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c20193924.target)
	e3:SetOperation(c20193924.activate)
	c:RegisterEffect(e3)
end
-- 筛选场上盖放的卡的过滤器函数
function c20193924.filter(c)
	return c:IsFacedown()
end
-- 设置效果的目标选择逻辑
function c20193924.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c20193924.filter(chkc) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c20193924.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上盖放的一张卡作为目标
	local g=Duel.SelectTarget(tp,c20193924.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果的处理信息为破坏类别
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动时的处理函数
function c20193924.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
