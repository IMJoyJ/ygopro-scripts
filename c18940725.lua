--ふわんだりぃず×ろびーな
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次，这些效果发动的回合，自己不能把怪兽特殊召唤。
-- ①：这张卡召唤成功的场合才能发动。从卡组把1只4星以下的鸟兽族怪兽加入手卡。那之后，可以把1只鸟兽族怪兽召唤。
-- ②：表侧表示的这张卡从场上离开的场合除外。
-- ③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
function c18940725.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤成功的场合才能发动。从卡组把1只4星以下的鸟兽族怪兽加入手卡。那之后，可以把1只鸟兽族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18940725,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,18940725)
	e1:SetCost(c18940725.cost)
	e1:SetTarget(c18940725.thtg)
	e1:SetOperation(c18940725.thop)
	c:RegisterEffect(e1)
	-- 将该卡的离场效果重定向为除外，实现“表侧表示的这张卡从场上离开的场合除外”的效果。
	aux.AddBanishRedirect(c)
	-- 效果原文内容：③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18940725,1))  --"这张卡加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,18940726)
	e3:SetCondition(c18940725.thcon2)
	e3:SetCost(c18940725.cost)
	e3:SetTarget(c18940725.thtg2)
	e3:SetOperation(c18940725.thop2)
	c:RegisterEffect(e3)
end
-- 该函数用于设置发动效果时的限制条件，确保在发动效果的回合不能进行特殊召唤。
function c18940725.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在当前回合是否已经进行过特殊召唤，若未进行则允许发动效果。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建一个永续效果，使玩家在该回合不能进行特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将创建的不能特殊召唤效果注册到游戏环境中。
	Duel.RegisterEffect(e1,tp)
end
-- 定义了检索卡牌的过滤条件，即4星以下的鸟兽族怪兽且能加入手牌。
function c18940725.thfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WINDBEAST) and c:IsAbleToHand()
end
-- 设置效果处理时的操作信息，包括从卡组检索卡牌和召唤怪兽。
function c18940725.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在卡组中是否存在满足条件的卡牌。
	if chk==0 then return Duel.IsExistingMatchingCard(c18940725.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息，表示可能进行召唤操作。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,0,0,0)
end
-- 定义了召唤卡牌的过滤条件，即可以通常召唤的鸟兽族怪兽。
function c18940725.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsRace(RACE_WINDBEAST)
end
-- 处理效果的主要操作，包括检索卡牌、确认卡牌、询问是否召唤怪兽。
function c18940725.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡牌。
	local g=Duel.SelectMatchingCard(tp,c18940725.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡牌送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手确认玩家所选的卡牌。
		Duel.ConfirmCards(1-tp,g)
		-- 检查玩家手牌或场上的怪兽中是否存在可召唤的鸟兽族怪兽。
		if Duel.IsExistingMatchingCard(c18940725.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
			-- 询问玩家是否选择召唤鸟兽族怪兽。
			and Duel.SelectYesNo(tp,aux.Stringid(18940725,2)) then  --"是否把鸟兽族怪兽召唤？"
			-- 中断当前效果处理流程，使后续效果处理视为不同时处理。
			Duel.BreakEffect()
			-- 洗切玩家的手牌。
			Duel.ShuffleHand(tp)
			-- 提示玩家选择要召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 选择满足召唤条件的鸟兽族怪兽。
			local sg=Duel.SelectMatchingCard(tp,c18940725.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
			if sg:GetCount()>0 then
				-- 执行召唤操作。
				Duel.Summon(tp,sg:GetFirst(),true,nil)
			end
		end
	end
end
-- 定义效果触发条件，即当玩家场上有鸟兽族怪兽被召唤时触发。
function c18940725.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ec:IsControler(tp) and ec:IsRace(RACE_WINDBEAST)
end
-- 设置效果处理时的操作信息，表示将该卡加入手牌。
function c18940725.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息，表示将该卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 处理效果的主要操作，将该卡加入手牌。
function c18940725.thop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将该卡送入手牌。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
