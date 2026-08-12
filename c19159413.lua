--魔法除去
-- 效果：
-- ①：以场上1张表侧表示的魔法卡或者场上盖放的1张魔法·陷阱卡为对象才能发动。那张魔法卡破坏（那张卡在场上盖放中的场合，翻开确认）。
function c19159413.initial_effect(c)
	-- 创建效果，设置为魔法卡发动效果，具有取对象属性，破坏效果分类，自由时点
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c19159413.target)
	e1:SetOperation(c19159413.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择里侧表示或魔法卡类型的目标
function c19159413.filter(c)
	return c:IsFacedown() or c:IsType(TYPE_SPELL)
end
-- 效果处理目标选择函数，判断目标是否满足条件并进行选择
function c19159413.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c19159413.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否满足发动条件，判断场上是否存在符合条件的目标
	if chk==0 then return Duel.IsExistingTarget(c19159413.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择一个符合条件的目标卡
	local g=Duel.SelectTarget(tp,c19159413.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
	if g:GetFirst():IsFaceup() then
		-- 设置操作信息，确定破坏效果的处理对象
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果发动时的处理函数，执行破坏操作
function c19159413.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 若目标卡为里侧表示则翻开确认
		if tc:IsFacedown() then Duel.ConfirmCards(tp,tc) end
		-- 若目标卡为魔法卡则将其破坏
		if tc:IsType(TYPE_SPELL) then Duel.Destroy(tc,REASON_EFFECT) end
	end
end
