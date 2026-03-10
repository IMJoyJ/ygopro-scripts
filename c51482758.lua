--罠はずし
-- 效果：
-- 破坏表侧表示的场上的存在的1张陷阱卡。
function c51482758.initial_effect(c)
	-- 效果原文内容：破坏表侧表示的场上的存在的1张陷阱卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c51482758.target)
	e1:SetOperation(c51482758.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：筛选场上表侧表示的陷阱卡
function c51482758.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP)
end
-- 效果作用：选择目标，设置破坏对象
function c51482758.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c51482758.filter(chkc) end
	-- 效果作用：判断是否满足发动条件
	if chk==0 then return Duel.IsExistingTarget(c51482758.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 效果作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择场上一张表侧表示的陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c51482758.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 效果作用：设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果作用：处理效果，将选中的陷阱卡破坏
function c51482758.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果作用：将目标陷阱卡以效果为原因进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
