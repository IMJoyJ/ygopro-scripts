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
	-- 「连成的振动」的效果1回合只能使用1次。①：以自己的灵摆区域1张卡为对象才能把这个效果发动。那张卡破坏，那之后，自己从卡组抽1张。
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
-- 发动条件与取对象判定：若指定对象，则对象必须是自己灵摆区域的卡；发动时需满足自己可以抽1张卡且自己灵摆区域存在至少1张可选对象。
function c15582767.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) end
	-- 检查自己是否可以进行效果抽卡，若不能抽卡则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查自己灵摆区域是否存在至少1张可以成为对象的卡。
		and Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,1,nil) end
	-- 向操作者显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己灵摆区域选择1张卡作为效果对象，并登记为本次连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,0,1,1,nil)
	-- 设定破坏效果的操作信息：对象为已选择的1张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设定抽卡效果的操作信息：自己预计抽1张卡，对象不固定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：取得对象，若对象仍与效果关联且被破坏成功，则中断当前效果处理并抽1张卡。
function c15582767.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象仍与效果关联，并执行破坏；若破坏成功（返回非0）则进入后续抽卡处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 中断当前效果处理，使后续的抽卡视为与破坏不同时处理，避免错失时点。
		Duel.BreakEffect()
		-- 自己以效果原因从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
