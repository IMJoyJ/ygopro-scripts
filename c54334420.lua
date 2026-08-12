--ふわんだりぃず×いぐるん
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次，这些效果发动的回合，自己不能把怪兽特殊召唤。
-- ①：这张卡召唤成功的场合才能发动。从卡组把1只7星以上的鸟兽族怪兽加入手卡。那之后，可以把1只鸟兽族怪兽召唤。
-- ②：表侧表示的这张卡从场上离开的场合除外。
-- ③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
function c54334420.initial_effect(c)
	-- ①：这张卡召唤成功的场合才能发动。从卡组把1只7星以上的鸟兽族怪兽加入手卡。那之后，可以把1只鸟兽族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54334420,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,54334420)
	e1:SetCost(c54334420.cost)
	e1:SetTarget(c54334420.thtg)
	e1:SetOperation(c54334420.thop)
	c:RegisterEffect(e1)
	-- 为这张卡注册“表侧表示从场上离开的场合除外”的重定向效果。
	aux.AddBanishRedirect(c)
	-- ③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(54334420,1))  --"这张卡加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,54334421)
	e3:SetCondition(c54334420.thcon2)
	e3:SetCost(c54334420.cost)
	e3:SetTarget(c54334420.thtg2)
	e3:SetOperation(c54334420.thop2)
	c:RegisterEffect(e3)
end
-- 效果发动的Cost：检查本回合是否进行过特殊召唤，并注册“本回合不能特殊召唤怪兽”的誓约效果。
function c54334420.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前回合玩家是否进行过特殊召唤。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①③的效果1回合各能使用1次，这些效果发动的回合，自己不能把怪兽特殊召唤。①：这张卡召唤成功的场合才能发动。从卡组把1只7星以上的鸟兽族怪兽加入手卡。那之后，可以把1只鸟兽族怪兽召唤。③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 在全局注册“不能特殊召唤怪兽”的玩家效果。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：筛选卡组中7星以上的鸟兽族怪兽。
function c54334420.thfilter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_WINDBEAST) and c:IsAbleToHand()
end
-- 效果①的靶向函数：检查卡组中是否存在可检索的怪兽，并设置检索和召唤的操作信息。
function c54334420.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的7星以上鸟兽族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c54334420.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：进行怪兽召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,0,0,0)
end
-- 过滤函数：筛选手卡或场上可以进行通常召唤的鸟兽族怪兽。
function c54334420.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsRace(RACE_WINDBEAST)
end
-- 效果①的运行函数：从卡组检索1只7星以上的鸟兽族怪兽，之后可选择将1只鸟兽族怪兽召唤。
function c54334420.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的鸟兽族怪兽。
	local g=Duel.SelectMatchingCard(tp,c54334420.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
		-- 检查手牌或场上是否存在可以召唤的鸟兽族怪兽。
		if Duel.IsExistingMatchingCard(c54334420.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
			-- 询问玩家是否进行鸟兽族怪兽的召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(54334420,2)) then  --"是否把鸟兽族怪兽召唤？"
			-- 中断当前效果处理，使后续的召唤处理不与检索同时进行（避免错时点）。
			Duel.BreakEffect()
			-- 洗切玩家的手牌。
			Duel.ShuffleHand(tp)
			-- 提示玩家选择要召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 让玩家选择1只手牌或场上可召唤的鸟兽族怪兽。
			local sg=Duel.SelectMatchingCard(tp,c54334420.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
			if sg:GetCount()>0 then
				-- 忽略召唤次数限制，对选择的怪兽进行通常召唤。
				Duel.Summon(tp,sg:GetFirst(),true,nil)
			end
		end
	end
end
-- 效果③的触发条件：自己场上有鸟兽族怪兽召唤成功。
function c54334420.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ec:IsControler(tp) and ec:IsRace(RACE_WINDBEAST)
end
-- 效果③的靶向函数：检查除外状态的这张卡是否能加入手牌，并设置回收的操作信息。
function c54334420.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将这张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果③的运行函数：若这张卡仍存在于除外区，则将其加入手牌。
function c54334420.thop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡加入手牌。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
