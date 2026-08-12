--天空聖者メルティウス
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把反击陷阱卡发动，自己回复1000基本分，场上有「天空的圣域」存在的场合，再选对方场上1张卡破坏。
function c49905576.initial_effect(c)
	-- 记录该卡具有「天空的圣域」这张卡片的编号，用于后续判断场地卡是否存在
	aux.AddCodeList(c,56433456)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把反击陷阱卡发动，自己回复1000基本分，场上有「天空的圣域」存在的场合，再选对方场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c49905576.drop)
	c:RegisterEffect(e1)
end
-- 当连锁处理结束时触发的效果函数，用于判断是否满足条件并执行回复LP和破坏卡片的操作
function c49905576.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_COUNTER) or not c:IsLocation(LOCATION_MZONE) or c:IsFacedown() then return end
	-- 使玩家回复1000基本分
	Duel.Recover(tp,1000,REASON_EFFECT)
	-- 若场地上没有「天空的圣域」则不继续执行后续破坏操作
	if not Duel.IsEnvironment(56433456) then return end
	-- 向玩家发送提示信息，提示其选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 将选中的卡片从场上破坏
	Duel.Destroy(g,REASON_EFFECT)
end
