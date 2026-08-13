--黒魔術の継承
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地把2张魔法卡除外才能发动。把「黑魔术的继承」以外的有「黑魔术师」的卡名或者「黑魔术少女」的卡名记述的1张魔法·陷阱卡从卡组加入手卡。
function c41735184.initial_effect(c)
	-- 记录本卡的效果文本中记载了「黑魔术师」(46986414)和「黑魔术少女」(38033121)，用于后续判断卡名记述条件。
	aux.AddCodeList(c,46986414,38033121)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己墓地把2张魔法卡除外才能发动。把「黑魔术的继承」以外的有「黑魔术师」的卡名或者「黑魔术少女」的卡名记述的1张魔法·陷阱卡从卡组加入手卡。
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
-- 定义除外代价的筛选函数：卡必须是魔法卡，且可以作为代价从墓地除外。
function c41735184.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 定义发动代价：从自己墓地选择2张魔法卡除外，满足条件才可发动。
function c41735184.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段检查自己墓地是否存在至少2张满足条件的魔法卡（可除外），若不足则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c41735184.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 弹出选择提示，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地的魔法卡中选出2张符合条件的卡，作为代价除外的对象。
	local g=Duel.SelectMatchingCard(tp,c41735184.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的2张魔法卡以表侧表示除外，作为发动效果的代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义检索对象筛选函数：检查卡片是否为魔法·陷阱卡，效果文本是否记载了「黑魔术师」或「黑魔术少女」，且不是「黑魔术的继承」本身，并且可以被加入手卡。
function c41735184.filter(c)
	-- 判断卡片效果文本是否记载了「黑魔术师」(46986414)或「黑魔术少女」(38033121)。
	return (aux.IsCodeListed(c,46986414) or aux.IsCodeListed(c,38033121))
		and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(41735184) and c:IsAbleToHand()
end
-- 定义效果发动时的目标检查：确认卡组存在符合条件的检索对象，并设置操作信息。
function c41735184.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否存在至少1张满足检索条件的魔法·陷阱卡，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c41735184.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：将进行的操作是回手牌，从卡组选1张卡加入手卡（用于卡组检索相关检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理操作：从卡组挑选1张符合条件的魔法·陷阱卡加入手牌，并让对方确认。
function c41735184.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足检索条件的魔法·陷阱卡（不取对象）。
	local g=Duel.SelectMatchingCard(tp,c41735184.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手牌，处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片（公开信息）。
		Duel.ConfirmCards(1-tp,g)
	end
end
