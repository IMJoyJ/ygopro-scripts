--“Case of K9”
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「K9」怪兽加入手卡。
-- ②：对方把手卡·墓地的怪兽的效果发动的回合，自己场上的「K9」怪兽的攻击力上升900。
-- ③：魔法与陷阱区域的这张卡被效果破坏的场合才能发动。从自己的卡组·墓地把1张「K9」速攻魔法卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动时的检索效果、场上「K9」怪兽的永续增攻效果、被破坏时盖放速攻魔法的效果，并注册自定义活动计数器。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只「K9」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：对方把手卡·墓地的怪兽的效果发动的回合，自己场上的「K9」怪兽的攻击力上升900。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置永续效果的影响对象为自己场上的「K9」怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1cb))
	e2:SetCondition(s.atkcon)
	e2:SetValue(900)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：魔法与陷阱区域的这张卡被效果破坏的场合才能发动。从自己的卡组·墓地把1张「K9」速攻魔法卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"盖放"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	-- 注册一个自定义活动计数器，用于监测玩家发动的连锁，当满足过滤条件返回false（即在手卡或墓地发动怪兽效果）时计数器增加。
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 自定义计数器的过滤函数，当发动的效果是在手卡或墓地发动的怪兽效果时返回false，使计数器增加。
function s.chainfilter(re,tp,cid)
	-- 获取当前连锁发生的位置。
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	return not (re:IsActiveType(TYPE_MONSTER) and loc&(LOCATION_HAND|LOCATION_GRAVE)>0)
end
-- 过滤卡组中「K9」怪兽且能加入手卡的卡片过滤函数。
function s.thfilter(c)
	return c:IsSetCard(0x1cb) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 卡片发动时的效果处理函数，若卡组有满足条件的卡，玩家可以选择将1只「K9」怪兽加入手卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的「K9」怪兽。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 如果卡组中存在符合条件的卡，则询问玩家是否选择发动检索效果。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡因效果加入玩家手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 攻击力上升效果的启用条件函数，检查对方本回合是否在手卡或墓地发动过怪兽效果。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方玩家本回合在手卡或墓地发动怪兽效果的次数是否大于0。
	return Duel.GetCustomActivityCount(id,1-e:GetHandlerPlayer(),ACTIVITY_CHAIN)>0
end
-- 效果③的发动条件函数，检查这张卡是否在魔法与陷阱区域被效果破坏。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsReason(REASON_EFFECT)
end
-- 过滤卡组或墓地中「K9」速攻魔法卡且能在场上盖放的卡片过滤函数。
function s.setfilter(c)
	return c:IsSetCard(0x1cb) and c:IsType(TYPE_QUICKPLAY) and c:IsSSetable()
end
-- 效果③的靶向/可行性检查函数，确认卡组或墓地是否存在可盖放的「K9」速攻魔法。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查自己卡组或墓地是否存在至少1张可盖放的「K9」速攻魔法。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 效果③的效果处理函数，从卡组或墓地选择1张「K9」速攻魔法在自己场上盖放（受王家之谷影响）。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组或墓地选择1张满足条件的「K9」速攻魔法（适用墓地效果时受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片在自己场上盖放。
		Duel.SSet(tp,g:GetFirst())
	end
end
