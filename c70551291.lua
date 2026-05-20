--伝説の剣闘士 カオス・ソルジャー
-- 效果：
-- 「混沌形态」「超战士的仪式」降临
-- 这张卡不用仪式召唤不能特殊召唤。
-- ①：自己抽卡阶段的抽卡前，把手卡的这张卡给对方观看才能发动。作为这个回合进行通常抽卡的代替，从卡组把1张仪式魔法卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己战斗阶段中对方不能把效果发动。
-- ③：使用通常怪兽作仪式召唤的这张卡的攻击破坏对方怪兽时才能发动。对方场上的卡全部回到卡组。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含特殊召唤限制、抽卡阶段检索仪式魔法、战斗阶段封锁对方效果、战斗破坏怪兽时洗全场，以及检测仪式素材是否包含通常怪兽的辅助效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不用仪式召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为仅能通过仪式召唤进行特殊召唤。
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：自己抽卡阶段的抽卡前，把手卡的这张卡给对方观看才能发动。作为这个回合进行通常抽卡的代替，从卡组把1张仪式魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己战斗阶段中对方不能把效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.actcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：使用通常怪兽作仪式召唤的这张卡的攻击破坏对方怪兽时才能发动。对方场上的卡全部回到卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(s.rhcon)
	e4:SetTarget(s.rhtg)
	e4:SetOperation(s.rhop)
	c:RegisterEffect(e4)
	-- 使用通常怪兽作仪式召唤的这张卡
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(s.matcon)
	e5:SetOperation(s.matop)
	c:RegisterEffect(e5)
	-- 使用通常怪兽作仪式召唤的这张卡
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_MATERIAL_CHECK)
	e6:SetValue(s.valcheck)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
-- 抽卡阶段检索效果的发动条件：当前回合玩家是自己。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- 抽卡阶段检索效果的发动消耗：确认手牌中的这张卡（要求这张卡在手牌中且未公开）。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数：筛选卡组中可以加入手牌的仪式魔法卡。
function s.thfilter(c)
	return bit.band(c:GetType(),0x82)==0x82 and c:IsAbleToHand()
end
-- 抽卡阶段检索效果的靶向处理：确认玩家可以进行通常抽卡，且卡组中存在仪式魔法卡，并向双方展示将要从卡组检索卡片的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家当前是否能进行通常抽卡，且卡组中是否存在可检索的仪式魔法卡。
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 抽卡阶段检索效果的实际处理：使玩家放弃本回合的通常抽卡，并将抽卡数设为0，然后从卡组选择1张仪式魔法卡加入手牌并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 若玩家当前无法进行通常抽卡，则不处理后续效果。
	if not aux.IsPlayerCanNormalDraw(tp) then return end
	-- 使玩家放弃本回合的通常抽卡。
	aux.GiveUpNormalDraw(e,tp)
	-- ①：作为这个回合进行通常抽卡的代替，从卡组把1张仪式魔法卡加入手卡。②：只要这张卡在怪兽区域存在，自己战斗阶段中对方不能把效果发动。③：使用通常怪兽作仪式召唤的这张卡的攻击破坏对方怪兽时才能发动。对方场上的卡全部回到卡组。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_DRAW_COUNT)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DRAW)
	e1:SetValue(0)
	-- 注册将玩家本回合抽卡阶段抽卡数设为0的效果。
	Duel.RegisterEffect(e1,tp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的仪式魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 战斗阶段封锁效果的发动条件：当前是自己的回合，且处于战斗阶段。
function s.actcon(e)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否为自己回合的战斗阶段。
	return Duel.GetTurnPlayer()==e:GetHandler():GetControler() and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 仪式素材检测效果的条件：这张卡是通过仪式召唤特殊召唤，且仪式素材中包含通常怪兽。
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end
-- 仪式素材检测效果的处理：给这张卡注册一个特定的标记效果，用于后续判断是否满足③效果的发动条件。
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 仪式素材检查函数：检查用于仪式召唤的素材中是否存在通常怪兽，若存在则将Label设为1，否则设为0。
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	if mg:IsExists(Card.IsType,1,nil,TYPE_NORMAL) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 破坏对方怪兽时洗全场效果的发动条件：这张卡具有使用通常怪兽仪式召唤的标记，且当前进行攻击的怪兽是这张卡。
function s.rhcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否带有使用通常怪兽仪式召唤的标记，且当前是这张卡进行攻击。
	return c:GetFlagEffect(id)>0 and Duel.GetAttacker()==c
end
-- 破坏对方怪兽时洗全场效果的靶向处理：确认对方场上存在可以回到卡组的卡，并向双方展示将对方场上所有卡送回卡组的操作信息。
function s.rhtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否存在可以送回卡组的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有可以送回卡组的卡片。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：将对方场上的所有卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 破坏对方怪兽时洗全场效果的实际处理：获取对方场上所有可以送回卡组的卡，并将其全部送回卡组并洗牌。
function s.rhop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以送回卡组的卡片。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 将获取到的卡片全部送回持有者卡组并洗牌。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
