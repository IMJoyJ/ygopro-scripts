--天空聖者メルティウス
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把反击陷阱卡发动，自己回复1000基本分，场上有「天空的圣域」存在的场合，再选对方场上1张卡破坏。
function c49905576.initial_effect(c)
	-- 将「天空的圣域」（卡号56433456）登记到本卡的代码列表中，用于记录本卡上记载了该卡名。
	aux.AddCodeList(c,56433456)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把反击陷阱卡发动，自己回复1000基本分，场上有「天空的圣域」存在的场合，再选对方场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c49905576.drop)
	c:RegisterEffect(e1)
end
-- 定义效果处理函数：在连锁结算后，若满足发动的是反击陷阱且此卡仍表侧存在于怪兽区，则回复1000基本分；若场上有「天空的圣域」，再选择对方场上1张卡破坏。
function c49905576.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_COUNTER) or not c:IsLocation(LOCATION_MZONE) or c:IsFacedown() then return end
	-- 以效果原因让效果发动者回复1000基本分。
	Duel.Recover(tp,1000,REASON_EFFECT)
	-- 检查当前是否处于「天空的圣域」存在的环境；若不存在，则不执行后续的破坏处理。
	if not Duel.IsEnvironment(56433456) then return end
	-- 向当前玩家显示“请选择要破坏的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家选择对方场上的1张卡作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 以效果原因将选择的卡片破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
