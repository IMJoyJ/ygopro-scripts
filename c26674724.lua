--ブリューナクの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡若非以只使用除「光枪龙之影灵衣」以外的怪兽来作的仪式召唤则不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把「光枪龙之影灵衣」以外的1只「影灵衣」怪兽加入手卡。
-- ②：以从额外卡组特殊召唤的场上最多2只怪兽为对象才能发动。那些怪兽回到卡组。
function c26674724.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡若非以只使用除「光枪龙之影灵衣」以外的怪兽来作的仪式召唤则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置本卡的特殊召唤条件判定函数为aux.ritlimit，即只允许以仪式召唤方式特殊召唤，其他特殊召唤方式无法进行。
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把「光枪龙之影灵衣」以外的1只「影灵衣」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26674724,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,26674724)
	e2:SetCost(c26674724.thcost)
	e2:SetTarget(c26674724.thtg)
	e2:SetOperation(c26674724.thop)
	c:RegisterEffect(e2)
	-- ②：以从额外卡组特殊召唤的场上最多2只怪兽为对象才能发动。那些怪兽回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26674724,1))  --"回到卡组"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,26674725)
	e3:SetTarget(c26674724.tdtg)
	e3:SetOperation(c26674724.tdop)
	c:RegisterEffect(e3)
end
-- 定义仪式召唤素材的过滤条件：排除卡号26674724（光枪龙之影灵衣）自身，保证仪式召唤只能使用除本卡以外的怪兽作为素材。
function c26674724.mat_filter(c)
	return not c:IsCode(26674724)
end
-- ①效果的发动代价函数：检查手卡中的这张卡是否可丢弃，若可以则丢弃它作为发动代价。
function c26674724.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手卡送去墓地，作为发动①效果的代价（丢弃）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- ①效果检索的过滤条件：属于「影灵衣」字段、不是光枪龙之影灵衣自身、是怪兽卡，并且可以加入手卡。
function c26674724.thfilter(c)
	return c:IsSetCard(0xb4) and not c:IsCode(26674724) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动条件和操作信息设置：检查卡组是否存在至少1张满足thfilter的卡，并登记效果信息为从卡组将1张卡加入手卡。
function c26674724.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查自己卡组中是否存在至少1张满足thfilter条件的「影灵衣」怪兽，以此判断效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c26674724.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本连锁的操作信息：效果分类为加入手卡，预定处理1张卡，来自卡组，持有者为tp，用于相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：玩家从卡组选择1张满足条件的「影灵衣」怪兽加入手卡，然后向对方展示。
function c26674724.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，告知玩家正在选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己的卡组中筛选并选择1张满足thfilter条件的「影灵衣」怪兽（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c26674724.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的那张卡，以示公开检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果取对象的过滤条件：该怪兽是从额外卡组特殊召唤的，并且可以被送回卡组。
function c26674724.tdfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToDeck()
end
-- ②效果的发动条件和取对象处理：检查场上是否存在满足条件的怪兽，选择场上1~2只从额外卡组特殊召唤的怪兽作为对象，并登记回卡组的操作信息。
function c26674724.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c26674724.tdfilter(chkc) end
	-- 发动时检查场上是否存在至少1只满足tdfilter（从额外卡组特殊召唤且可回卡组）的怪兽，能作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c26674724.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，告知玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上1~2只从额外卡组特殊召唤的怪兽作为效果对象，并自动将这些卡与当前连锁关联。
	local g=Duel.SelectTarget(tp,c26674724.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
	-- 登记操作信息：将选择的对象怪兽返回卡组，数量为对象数量，用于效果处理时的判定。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ②效果处理：取得仍与效果相关的对象怪兽，将其全部返回持有者卡组并洗牌。
function c26674724.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁发动时选择的对象卡，并过滤出仍然与该效果相关的怪兽（去除已离场或不受影响的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将对象怪兽送回持有者卡组，并执行洗牌，处理原因为效果。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
