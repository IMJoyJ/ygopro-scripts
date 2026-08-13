--武神器－ヤサカニ
-- 效果：
-- 自己的主要阶段2，把这张卡从手卡送去墓地才能发动。从卡组把1只名字带有「武神」的怪兽加入手卡。这个效果发动的回合，自己不能把名字带有「武神」的卡以外的魔法·陷阱·效果怪兽的效果发动。「武神器-八尺琼」的效果1回合只能使用1次。
function c50474354.initial_effect(c)
	-- 自己的主要阶段2，把这张卡从手卡送去墓地才能发动。从卡组把1只名字带有「武神」的怪兽加入手卡。「武神器-八尺琼」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50474354,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,50474354)
	e1:SetCondition(c50474354.condition)
	e1:SetCost(c50474354.cost)
	e1:SetTarget(c50474354.target)
	e1:SetOperation(c50474354.operation)
	c:RegisterEffect(e1)
	-- 注册自定义活动计数器，记录本回合自己发动过非「武神」卡的效果；若发动过，计数器变为1，用于自肃判定。
	Duel.AddCustomActivityCounter(50474354,ACTIVITY_CHAIN,c50474354.chainfilter)
end
-- 活动计数器过滤器：当发动效果的卡是名字带有「武神」的卡时返回true，不增加计数器；否则返回false，该操作会计入计数器。
function c50474354.chainfilter(re,tp,cid)
	return re:GetHandler():IsSetCard(0x88)
end
-- 效果发动条件判定：发动时机必须在自己主要阶段2。
function c50474354.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前阶段是否为主要阶段2（满足条件为true）。
	return Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 发动代价处理：先检查自肃计数为0且此卡可从手牌送去墓地；满足后把此卡作为代价送入墓地，同时给自己施加本回合不能发动非「武神」卡效果的誓约限制。
function c50474354.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价确认阶段：要求本回合未发动过非「武神」的效果（计数器为0），且此卡可作为代价从手牌送去墓地。
	if chk==0 then return Duel.GetCustomActivityCount(50474354,tp,ACTIVITY_CHAIN)==0 and c:IsAbleToGraveAsCost() end
	-- 将这张手牌的“武神器-八尺琼”送去墓地，作为效果发动代价。
	Duel.SendtoGrave(c,REASON_COST)
	-- 这个效果发动的回合，自己不能把名字带有「武神」的卡以外的魔法·陷阱·效果怪兽的效果发动。从卡组把1只名字带有「武神」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c50474354.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果（不能发动非「武神」卡效果）作为永续效果注册给当前玩家，效果持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定函数：如果发动效果的卡不是名字带有「武神」的卡，则禁止其发动（返回true表示不能发动）。
function c50474354.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(0x88)
end
-- 检索过滤器：选择卡组中名字带有「武神」的怪兽卡，且该卡可以加入手牌。
function c50474354.filter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动目标判定：先检查卡组中是否存在符合条件的「武神」怪兽；并设置本次操作信息为加入手牌，为处理阶段做准备。
function c50474354.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标确认阶段：检查自己卡组中是否存在至少1只满足条件的「武神」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c50474354.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将执行“从卡组把1张卡加入手牌”的处理（目标玩家为自己，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的「武神」怪兽加入手牌，并给对手确认。
function c50474354.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只满足条件的「武神」怪兽。
	local g=Duel.SelectMatchingCard(tp,c50474354.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入持有者手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对手确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
