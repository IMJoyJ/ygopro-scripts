--先史遺産クリスタル・スカル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上有「先史遗产」怪兽存在的场合，把这张卡从手卡丢弃去墓地才能发动。从自己的卡组·墓地选「先史遗产 水晶头骨」以外的1只「先史遗产」怪兽加入手卡。
function c51435705.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：自己场上有「先史遗产」怪兽存在的场合，把这张卡从手卡丢弃去墓地才能发动。从自己的卡组·墓地选「先史遗产 水晶头骨」以外的1只「先史遗产」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51435705,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,51435705)
	e1:SetCondition(c51435705.shcon)
	e1:SetCost(c51435705.shcost)
	e1:SetTarget(c51435705.shtg)
	e1:SetOperation(c51435705.shop)
	c:RegisterEffect(e1)
end
-- 定义过滤条件：卡片为表侧表示且属于「先史遗产」系列（0x70），用于检查场上是否存在表侧表示的「先史遗产」怪兽。
function c51435705.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x70)
end
-- 效果发动条件判定：检查我方主要怪兽区是否存在至少1张表侧表示的「先史遗产」怪兽（通过 cfilter 过滤），满足“自己场上有「先史遗产」怪兽存在”的发动条件。
function c51435705.shcon(e,tp,eg,ep,ev,re,r,rp)
	-- 调用 Duel.IsExistingMatchingCard 在己方主要怪兽区检索是否存在至少1张表侧表示且属「先史遗产」系列的怪兽，作为效果能否发动的判定。
	return Duel.IsExistingMatchingCard(c51435705.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 代价函数：chk==0 时检查此卡能否被丢弃且能作为代价送去墓地；满足后实际将此卡从手卡丢弃去墓地，作为发动效果的代价。
function c51435705.shcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() and e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡从手卡送去墓地，丢弃原因标记为 REASON_DISCARD 和 REASON_COST，即作为发动效果的代价被丢弃。
	Duel.SendtoGrave(e:GetHandler(),REASON_DISCARD+REASON_COST)
end
-- 定义检索目标过滤条件：属于「先史遗产」系列、卡名不是「先史遗产 水晶头骨」（51435705）、是怪兽且能够加入手卡。
function c51435705.filter(c)
	return c:IsSetCard(0x70) and not c:IsCode(51435705) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时确定目标并登记操作：先检查卡组·墓地是否存在至少1张符合条件的「先史遗产」怪兽，然后 SetOperationInfo 登记本次效果将把1张卡加入手牌。
function c51435705.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在 chk==0 时检查己方卡组·墓地中是否存在至少1张满足 filter 条件的「先史遗产」怪兽（即「先史遗产 水晶头骨」以外的先史遗产怪兽），存在则允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c51435705.filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	-- 将操作信息设为 CATEGORY_TOHAND，表示将从自己的卡组·墓地中取1张卡加入手牌（对象未确定，故 targets 为 nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果处理：提示玩家选择卡后，从己方卡组·墓地中用 NecroValleyFilter 过滤出符合条件的「先史遗产」怪兽（排除自身）选1张加入手牌，并向对方展示。
function c51435705.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示“请选择要加入手牌的卡”，让玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组·墓地中筛选1张满足 filter 且不受王家长眠之谷影响的「先史遗产」怪兽（除「先史遗产 水晶头骨」外），作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c51435705.filter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「先史遗产」怪兽加入其持有者的手牌，原因标记为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手牌的卡片展示给对方玩家确认，保证信息公开。
		Duel.ConfirmCards(1-tp,g)
	end
end
