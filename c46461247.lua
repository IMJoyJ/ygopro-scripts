--トラップ・マスター
-- 效果：
-- 反转：场上1张陷阱卡破坏。里侧表示翻开确认后破坏。
function c46461247.initial_effect(c)
	-- 反转效果：场上1张陷阱卡破坏。里侧表示翻开确认后破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46461247,0))  --"陷阱破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c46461247.target)
	e1:SetOperation(c46461247.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断目标是否为里侧表示或陷阱卡类型
function c46461247.filter(c)
	return c:IsFacedown() or c:IsType(TYPE_TRAP)
end
-- 选择目标：从魔法陷阱区域选择一张符合条件的卡作为破坏对象
function c46461247.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c46461247.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 执行选择操作，选取一张魔法陷阱区域的卡作为目标
	local g=Duel.SelectTarget(tp,c46461247.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
	if g:GetCount()>0 and g:GetFirst():IsFaceup() then
		-- 设置连锁操作信息为破坏效果
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理函数：确认目标卡并根据其状态进行破坏
function c46461247.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 若目标卡为里侧表示则翻开确认
		if tc:IsFacedown() then Duel.ConfirmCards(tp,tc) end
		-- 若目标卡为陷阱卡类型则将其破坏
		if tc:IsType(TYPE_TRAP) then Duel.Destroy(tc,REASON_EFFECT) end
	end
end
