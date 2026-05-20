--左腕の代償
-- 效果：
-- 这张卡发动的回合，自己不能把魔法·陷阱卡盖放。
-- ①：这张卡以外的自己手卡是2张以上的场合，把那些手卡全部除外才能发动。从卡组把1张魔法卡加入手卡。
function c86541496.initial_effect(c)
	-- ①：这张卡以外的自己手卡是2张以上的场合，把那些手卡全部除外才能发动。从卡组把1张魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c86541496.cost)
	e1:SetTarget(c86541496.target)
	e1:SetOperation(c86541496.activate)
	c:RegisterEffect(e1)
	if not c86541496.global_check then
		c86541496.global_check=true
		-- 这张卡发动的回合，自己不能把魔法·陷阱卡盖放。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(c86541496.checkop)
		-- 注册全局环境效果，用于监测玩家盖放魔法·陷阱卡的操作
		Duel.RegisterEffect(ge1,0)
	end
end
-- 盖放卡片时的操作函数，为盖放卡片的玩家注册一个回合内有效的标识效果
function c86541496.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为盖放卡片的玩家注册一个在回合结束时重置的标识效果，表示该玩家在本回合进行过盖放
	Duel.RegisterFlagEffect(rp,86541496,RESET_PHASE+PHASE_END,0,1)
end
-- 发动代价与限制检查函数，检查本回合是否未盖放过魔陷，且手卡（除这张卡外）是否在2张以上且均可作为代价除外
function c86541496.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取除这张卡以外的自己手卡
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,e:GetHandler())
	-- 检查玩家本回合是否没有盖放过魔法·陷阱卡
	if chk==0 then return Duel.GetFlagEffect(tp,86541496)==0
		and g:GetCount()>1 and g:GetCount()==g:FilterCount(Card.IsAbleToRemoveAsCost,nil) end
	-- 将这些手卡全部表侧表示除外作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 这张卡发动的回合，自己不能把魔法·陷阱卡盖放。①：这张卡以外的自己手卡是2张以上的场合，把那些手卡全部除外才能发动。从卡组把1张魔法卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SSET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 给玩家注册“不能盖放魔法·陷阱卡”的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：卡片是魔法卡且可以加入手卡
function c86541496.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果的目标处理函数，检查卡组中是否存在可检索的魔法卡，并设置操作信息
function c86541496.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c86541496.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果会将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的运行处理函数，从卡组选择1张魔法卡加入手卡并给对方确认
function c86541496.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c86541496.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
