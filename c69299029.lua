--王の遺宝祀りし聖域
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「阿匹卜」陷阱卡在自己场上盖放。
-- ②：这张卡只要在场地区域存在，卡名当作「王家的神殿」使用。
-- ③：1回合1次，自己场上有里侧表示卡2张以上存在的场合或者自己墓地有陷阱卡存在的场合才能发动。从卡组把有「王家的神殿」的卡名记述的1只怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 注册该卡片在效果文本中记载了「王家的神殿」（卡号29762407）。
	aux.AddCodeList(c,29762407)
	-- 设置该卡在场上时卡名当作「王家的神殿」使用。
	aux.EnableChangeCode(c,29762407,LOCATION_ONFIELD)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1张「阿匹卜」陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ③：1回合1次，自己场上有里侧表示卡2张以上存在的场合或者自己墓地有陷阱卡存在的场合才能发动。从卡组把有「王家的神殿」的卡名记述的1只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可盖放的「阿匹卜」陷阱卡的条件函数。
function s.setfilter(c)
	return c:IsSetCard(0x1c8) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 魔法卡发动时的效果处理函数，可选择从卡组盖放1张「阿匹卜」陷阱卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的「阿匹卜」陷阱卡。
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的卡，则询问玩家是否进行盖放。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把陷阱卡盖放？"
		-- 提示玩家选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡在自己场上盖放。
		Duel.SSet(tp,sg)
	end
end
-- 检索效果的发动条件函数。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在2张或以上的里侧表示卡。
	return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,0,2,nil)
		-- 或者检查自己墓地是否存在陷阱卡。
		or Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_TRAP)
end
-- 过滤卡组中记载有「王家的神殿」卡名的怪兽且能加入手牌的条件函数。
function s.thfilter(c)
	-- 检查卡片是否记载有「王家的神殿」卡名、是怪兽卡且能加入手牌。
	return aux.IsCodeListed(c,29762407) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的靶向与发动准备函数。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在符合检索条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡因效果加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
