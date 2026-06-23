--先史遺産クリスタル・スカル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上有「先史遗产」怪兽存在的场合，把这张卡从手卡丢弃去墓地才能发动。从自己的卡组·墓地选「先史遗产 水晶头骨」以外的1只「先史遗产」怪兽加入手卡。
function c51435705.initial_effect(c)
	-- 创建效果1，用于处理卡名效果的起动，设置描述为检索，分类为回手牌和检索，类型为起动效果，发动位置为手卡，限制每回合只能发动1次，条件为己方场上存在先史遗产怪兽，代价为丢弃此卡并送入墓地，目标为选择1张先史遗产怪兽加入手牌，处理为执行检索并加入手牌操作
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
-- 过滤函数：检查目标怪兽是否为表侧表示且为先史遗产卡组
function c51435705.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x70)
end
-- 效果条件函数：判断己方场上是否存在至少1只表侧表示的先史遗产怪兽
function c51435705.shcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在至少1只表侧表示的先史遗产怪兽
	return Duel.IsExistingMatchingCard(c51435705.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果代价函数：判断此卡是否可以丢弃并送入墓地作为发动代价，若满足则执行将此卡送入墓地的操作
function c51435705.shcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() and e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡以丢弃和代价原因送入墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_DISCARD+REASON_COST)
end
-- 过滤函数：检查目标怪兽是否为先史遗产卡组、不是水晶头骨本身、是怪兽类型且可以加入手牌
function c51435705.filter(c)
	return c:IsSetCard(0x70) and not c:IsCode(51435705) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果目标函数：判断己方墓地或卡组是否存在至少1张满足条件的先史遗产怪兽，若满足则设置操作信息为选择1张先史遗产怪兽回手牌
function c51435705.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方墓地或卡组是否存在至少1张满足条件的先史遗产怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c51435705.filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：指定将从己方墓地或卡组中选择1张先史遗产怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果处理函数：提示玩家选择要加入手牌的卡，然后选择满足条件的卡并将其加入手牌，并确认对方查看该卡
function c51435705.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方墓地或卡组中选择满足条件的1张先史遗产怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c51435705.filter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看已加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
