--魔法除去
-- 效果：
-- ①：以场上1张表侧表示的魔法卡或者场上盖放的1张魔法·陷阱卡为对象才能发动。那张魔法卡破坏（那张卡在场上盖放中的场合，翻开确认）。
function c19159413.initial_effect(c)
	-- ①：以场上1张表侧表示的魔法卡或者场上盖放的1张魔法·陷阱卡为对象才能发动。那张魔法卡破坏（那张卡在场上盖放中的场合，翻开确认）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c19159413.target)
	e1:SetOperation(c19159413.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择场上满足条件的对象，即里侧表示的卡或魔法卡（对应表侧表示的魔法卡或盖放的魔法·陷阱卡）。
function c19159413.filter(c)
	return c:IsFacedown() or c:IsType(TYPE_SPELL)
end
-- 效果发动时的目标选择处理：先检查是否存在合法对象，再让玩家选择1张符合条件的卡作为对象，并根据对象状态设置对应的破坏操作信息。
function c19159413.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c19159413.filter(chkc) and chkc~=e:GetHandler() end
	-- 发动时合法性检查：确认场上存在至少1张满足条件且不是效果发动者自身的卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c19159413.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	-- 向玩家显示选择提示消息，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方魔陷区选择1张符合条件的卡作为效果对象，并自动将该卡记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c19159413.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
	if g:GetFirst():IsFaceup() then
		-- 若选择的对象是表侧表示，则设定本次操作信息为破坏1张卡，用于后续连锁判定。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理阶段：取得效果对象，若对象仍与该效果关联则先确认里侧卡，然后破坏满足条件的魔法卡。
function c19159413.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象卡（发动时选择的那1张卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 若对象卡处于里侧表示，则将其翻转确认（翻开给对方玩家查看）。
		if tc:IsFacedown() then Duel.ConfirmCards(tp,tc) end
		-- 若对象卡是魔法卡，则将其以效果原因破坏送去墓地。
		if tc:IsType(TYPE_SPELL) then Duel.Destroy(tc,REASON_EFFECT) end
	end
end
