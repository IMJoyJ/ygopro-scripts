--黒魔術の継承
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地把2张魔法卡除外才能发动。把「黑魔术的继承」以外的有「黑魔术师」的卡名或者「黑魔术少女」的卡名记述的1张魔法·陷阱卡从卡组加入手卡。
function c41735184.initial_effect(c)
	-- 记录该卡效果文本上记载着「黑魔术师」和「黑魔术少女」这两张卡的卡名
	aux.AddCodeList(c,46986414,38033121)
	-- ①：从自己墓地把2张魔法卡除外才能发动。把「黑魔术的继承」以外的有「黑魔术师」的卡名或者「黑魔术少女」的卡名记述的1张魔法·陷阱卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,41735184+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c41735184.cost)
	e1:SetTarget(c41735184.target)
	e1:SetOperation(c41735184.activate)
	c:RegisterEffect(e1)
end
-- 定义用于判断是否满足除外代价的魔法卡过滤器，即是否为魔法卡且可以作为除外代价
function c41735184.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 定义效果发动时的除外代价处理函数，检查是否满足除外2张魔法卡的条件并执行除外操作
function c41735184.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在自己墓地是否存在至少2张满足cfilter条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c41735184.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2张魔法卡作为除外代价
	local g=Duel.SelectMatchingCard(tp,c41735184.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的卡以除外形式从墓地移除作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义用于检索卡组中符合条件的魔法·陷阱卡的过滤器，即是否为「黑魔术师」或「黑魔术少女」的卡名且不是「黑魔术的继承」
function c41735184.filter(c)
	-- 判断该卡是否记载着「黑魔术师」或「黑魔术少女」的卡名
	return (aux.IsCodeListed(c,46986414) or aux.IsCodeListed(c,38033121))
		and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(41735184) and c:IsAbleToHand()
end
-- 定义效果发动时的目标选择处理函数，检查卡组中是否存在满足条件的魔法·陷阱卡
function c41735184.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在自己卡组中是否存在至少1张满足filter条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c41735184.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的操作信息，表示将从卡组检索1张魔法·陷阱卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果发动时的处理函数，选择满足条件的魔法·陷阱卡并加入手牌
function c41735184.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张魔法·陷阱卡作为处理对象
	local g=Duel.SelectMatchingCard(tp,c41735184.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认选中的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
