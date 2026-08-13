--トラップ・マスター
-- 效果：
-- 反转：场上1张陷阱卡破坏。里侧表示翻开确认后破坏。
function c46461247.initial_effect(c)
	-- 反转：场上1张陷阱卡破坏。里侧表示翻开确认后破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46461247,0))  --"陷阱破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c46461247.target)
	e1:SetOperation(c46461247.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：满足里侧表示或陷阱卡之一的卡片即可成为效果对象。
function c46461247.filter(c)
	return c:IsFacedown() or c:IsType(TYPE_TRAP)
end
-- 发动时的取对象处理：从双方魔法与陷阱区域选择1张符合条件的卡作为对象；仅当对象为表侧表示时设置破坏的操作信息，里侧表示的对象在效果处理时确认后再破坏。
function c46461247.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c46461247.filter(chkc) end
	if chk==0 then return true end
	-- 弹出“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择双方魔法与陷阱区域中1张满足过滤条件的卡作为效果对象。
	local g=Duel.SelectTarget(tp,c46461247.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
	if g:GetCount()>0 and g:GetFirst():IsFaceup() then
		-- 设置本次连锁的操作信息为破坏效果，对象为已选择的卡，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理：取得对象卡，若对象仍与效果关联则进行确认和破坏处理：里侧表示先确认，是陷阱卡则破坏。
function c46461247.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 若对象卡为里侧表示，则将这张卡确认给发动玩家。
		if tc:IsFacedown() then Duel.ConfirmCards(tp,tc) end
		-- 若对象卡是陷阱卡，则将其以效果原因破坏。
		if tc:IsType(TYPE_TRAP) then Duel.Destroy(tc,REASON_EFFECT) end
	end
end
