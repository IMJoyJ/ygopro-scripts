--六花絢爛
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡也能把自己场上1只植物族怪兽解放来发动。
-- ①：从卡组把1只「六花」怪兽加入手卡。把怪兽解放来把这张卡发动的场合，再把和加入手卡的怪兽是卡名不同并是原本等级相同的1只植物族怪兽从卡组加入手卡。
function c69164989.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只「六花」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69164989,0))  --"不解放怪兽发动"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,69164989+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c69164989.target)
	e1:SetOperation(c69164989.activate)
	c:RegisterEffect(e1)
	-- 这张卡也能把自己场上1只植物族怪兽解放来发动。①：从卡组把1只「六花」怪兽加入手卡。把怪兽解放来把这张卡发动的场合，再把和加入手卡的怪兽是卡名不同并是原本等级相同的1只植物族怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69164989,1))  --"解放怪兽发动"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,69164989+EFFECT_COUNT_CODE_OATH)
	e2:SetCost(c69164989.cost)
	e2:SetTarget(c69164989.target2)
	e2:SetOperation(c69164989.activate2)
	c:RegisterEffect(e2)
end
-- 过滤卡组中满足检索条件的「六花」怪兽。如果check为false，则还需检查卡组中是否存在另一只与该卡卡名不同且原本等级相同的植物族怪兽。
function c69164989.thfilter(c,tp,check)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x141) and c:IsAbleToHand()
		-- 检查卡组中是否存在与该卡卡名不同且原本等级相同的植物族怪兽（用于解放怪兽发动时的过滤）。
		and (check or Duel.IsExistingMatchingCard(c69164989.thfilter2,tp,LOCATION_DECK,0,1,c,c:GetCode(),c:GetOriginalLevel()))
end
-- 过滤卡组中与第一张加入手牌的怪兽卡名不同、原本等级相同且可以加入手牌的植物族怪兽。
function c69164989.thfilter2(c,code,lv)
	return c:IsRace(RACE_PLANT) and not c:IsCode(code) and c:GetOriginalLevel()==lv and c:IsAbleToHand()
end
-- 不解放怪兽发动的效果（e1）的发动准备与合法性检查。
function c69164989.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「六花」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c69164989.thfilter,tp,LOCATION_DECK,0,1,nil,tp,true) end
	-- 设置操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 不解放怪兽发动的效果（e1）的效果处理。
function c69164989.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的「六花」怪兽。
	local g=Duel.SelectMatchingCard(tp,c69164989.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp,true)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 过滤自己场上可解放的植物族怪兽（或受特定卡片效果影响可以解放的对方场上怪兽）。
function c69164989.costfilter(c,tp)
	return (c:IsControler(tp) or c:IsFaceup())
		and (c:IsRace(RACE_PLANT) or c:IsHasEffect(76869711,tp) and c:IsControler(1-tp))
end
-- 解放怪兽发动的效果（e2）的代价处理函数。
function c69164989.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只可解放的植物族怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c69164989.costfilter,1,nil,tp) end
	-- 提示玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1只用于解放的怪兽。
	local g=Duel.SelectReleaseGroup(tp,c69164989.costfilter,1,1,nil,tp)
	-- 将选择的怪兽解放。
	Duel.Release(g,REASON_COST)
end
-- 解放怪兽发动的效果（e2）的发动准备与合法性检查。
function c69164989.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 检查卡组中是否存在满足追加检索条件的「六花」怪兽（即卡组中还必须存在另一张同等级不同名的植物族怪兽）。
		and Duel.IsExistingMatchingCard(c69164989.thfilter,tp,LOCATION_DECK,0,1,nil,tp)
	end
	-- 设置操作信息：从卡组将2张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 解放怪兽发动的效果（e2）的效果处理。
function c69164989.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足追加检索条件的「六花」怪兽。
	local g=Duel.SelectMatchingCard(tp,c69164989.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()==0 then
		-- 如果由于连锁等原因导致无法进行追加检索，则退化为只检索1只「六花」怪兽。
		g=Duel.SelectMatchingCard(tp,c69164989.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp,true)
	end
	local tc=g:GetFirst()
	-- 如果成功将第一张怪兽加入手牌。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		-- 给对方玩家确认第一张加入手牌的卡。
		Duel.ConfirmCards(1-tp,tc)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and tc:IsLocation(LOCATION_HAND)
			-- 检查卡组中是否存在与第一张卡卡名不同且原本等级相同的植物族怪兽。
			and Duel.IsExistingMatchingCard(c69164989.thfilter2,tp,LOCATION_DECK,0,1,nil,tc:GetCode(),tc:GetOriginalLevel()) then
			-- 中断当前效果处理，使后续的检索处理与前一次检索不视为同时处理。
			Duel.BreakEffect()
			-- 提示玩家选择第二张要加入手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 让玩家从卡组选择1只与第一张卡卡名不同且原本等级相同的植物族怪兽。
			local tg=Duel.SelectMatchingCard(tp,c69164989.thfilter2,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode(),tc:GetOriginalLevel())
			-- 将第二张怪兽加入手牌。
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 给对方玩家确认第二张加入手牌的卡。
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
