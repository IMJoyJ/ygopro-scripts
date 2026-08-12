--パペット・ポーン
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以直接攻击。
-- ②：这张卡给与对方战斗伤害时才能发动。从卡组把1张「升变」加入手卡。
-- ③：把墓地的这张卡除外才能发动。从卡组把「人偶兵卒」以外的1只战士族·地属性怪兽加入手卡。那之后，对方可以从自身卡组把1只怪兽加入手卡。
function c89839552.initial_effect(c)
	-- ①：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ②：这张卡给与对方战斗伤害时才能发动。从卡组把1张「升变」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89839552,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCountLimit(1,89839552)
	e2:SetCondition(c89839552.thcon)
	e2:SetTarget(c89839552.thtg)
	e2:SetOperation(c89839552.thop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。从卡组把「人偶兵卒」以外的1只战士族·地属性怪兽加入手卡。那之后，对方可以从自身卡组把1只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89839552,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,89839553)
	-- 设置效果3的发动代价为：把墓地的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c89839552.thtg2)
	e3:SetOperation(c89839552.thop2)
	c:RegisterEffect(e3)
end
-- 效果2的发动条件：给与对方玩家战斗伤害时。
function c89839552.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤条件：卡名为「升变」且能加入手牌的卡。
function c89839552.thfilter(c)
	return c:IsCode(88617904) and c:IsAbleToHand()
end
-- 效果2的发动准备（检查卡组是否存在「升变」并设置检索的操作信息）。
function c89839552.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身卡组是否存在至少1张满足过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c89839552.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果2的效果处理（从卡组将「升变」加入手牌并给对方确认）。
function c89839552.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动效果的玩家从自身卡组选择1张满足过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,c89839552.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：卡组中「人偶兵卒」以外的战士族·地属性怪兽且能加入手牌。
function c89839552.thfilter2(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsCode(89839552) and c:IsAbleToHand()
end
-- 效果3的发动准备（检查卡组是否存在满足条件的战士族·地属性怪兽并设置检索的操作信息）。
function c89839552.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身卡组是否存在至少1张满足过滤条件2的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c89839552.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：对方卡组中可以加入对方手牌的怪兽卡。
function c89839552.thfilter3(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand(1-tp)
end
-- 效果3的效果处理（自己检索战士族·地属性怪兽，之后对方可选择是否从卡组检索1只怪兽）。
function c89839552.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动效果的玩家从自身卡组选择1张满足过滤条件2的卡。
	local g=Duel.SelectMatchingCard(tp,c89839552.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	-- 如果成功将选择的卡加入手牌。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
		-- 获取对方卡组中所有满足过滤条件3（怪兽卡）的卡片组。
		local og=Duel.GetMatchingGroup(c89839552.thfilter3,tp,0,LOCATION_DECK,nil,tp)
		-- 如果对方卡组有怪兽，询问对方玩家是否选择从卡组把1只怪兽加入手卡。
		if og:GetCount()>0 and Duel.SelectYesNo(1-tp,aux.Stringid(89839552,2)) then  --"是否从卡组把1只怪兽加入手卡？"
			-- 中断当前效果处理，使之后的操作不与前面的操作视为同时处理。
			Duel.BreakEffect()
			-- 给对方玩家发送“请选择要加入手牌的卡”的提示信息。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=og:Select(1-tp,1,1,nil)
			-- 将对方选择的怪兽因效果加入对方手牌。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 给自己确认对方加入手牌的卡。
			Duel.ConfirmCards(tp,sg)
		end
	end
end
