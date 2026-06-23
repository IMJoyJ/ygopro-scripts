--ネクロバレーの玉座
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从卡组把1只「守墓」怪兽加入手卡。
-- ●从手卡把1只「守墓」怪兽召唤。
function c37561138.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37561138+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c37561138.target)
	e1:SetOperation(c37561138.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的「守墓」怪兽（怪兽卡且能加入手牌）
function c37561138.thfilter(c)
	return c:IsSetCard(0x2e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索满足条件的「守墓」怪兽（怪兽卡且能通常召唤）
function c37561138.filter(c)
	return c:IsSetCard(0x2e) and c:IsSummonable(true,nil)
end
-- 选择发动效果，从卡组把1只「守墓」怪兽加入手卡或从手卡把1只「守墓」怪兽召唤
function c37561138.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的「守墓」怪兽
	local b1=Duel.IsExistingMatchingCard(c37561138.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查手卡是否存在满足条件的「守墓」怪兽
	local b2=Duel.IsExistingMatchingCard(c37561138.filter,tp,LOCATION_HAND,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 选择从卡组把1只「守墓」怪兽加入手卡
		op=Duel.SelectOption(tp,aux.Stringid(37561138,0),aux.Stringid(37561138,1))  --"从卡组把1只「守墓」怪兽加入手卡/从手卡把1只「守墓」怪兽召唤"
	elseif b1 then
		-- 选择从卡组把1只「守墓」怪兽加入手卡
		op=Duel.SelectOption(tp,aux.Stringid(37561138,0))  --"从卡组把1只「守墓」怪兽加入手卡"
	else
		-- 选择从手卡把1只「守墓」怪兽召唤
		op=Duel.SelectOption(tp,aux.Stringid(37561138,1))+1  --"从手卡把1只「守墓」怪兽召唤"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置连锁操作信息为从卡组检索1只怪兽加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_SUMMON)
		-- 设置连锁操作信息为从手卡特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
	end
end
-- 处理选择的效果，若为0则从卡组检索，否则从手卡特殊召唤
function c37561138.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的1只「守墓」怪兽（从卡组）
		local g=Duel.SelectMatchingCard(tp,c37561138.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方查看加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 提示玩家选择要召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
		-- 选择满足条件的1只「守墓」怪兽（从手卡）
		local g=Duel.SelectMatchingCard(tp,c37561138.filter,tp,LOCATION_HAND,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选择的怪兽通常召唤
			Duel.Summon(tp,tc,true,nil)
		end
	end
end
