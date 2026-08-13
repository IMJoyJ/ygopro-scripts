--スピリチューアル・ウィスパー
-- 效果：
-- ①：这张卡1回合只有1次不会被战斗破坏。
-- ②：这张卡灵摆召唤成功时才能发动。从卡组把1只仪式怪兽或者1张仪式魔法卡加入手卡。
function c50155385.initial_effect(c)
	-- ①：这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c50155385.valcon)
	c:RegisterEffect(e1)
	-- ②：这张卡灵摆召唤成功时才能发动。从卡组把1只仪式怪兽或者1张仪式魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50155385,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c50155385.thcon)
	e2:SetTarget(c50155385.thtg)
	e2:SetOperation(c50155385.thop)
	c:RegisterEffect(e2)
end
-- 判断破坏原因是否为战斗破坏，若是则适用该效果。
function c50155385.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 判断这张卡是否是通过灵摆召唤成功而触发效果。
function c50155385.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 筛选卡组中满足条件的卡：仪式怪兽或仪式魔法，且能够加入手卡。
function c50155385.filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
-- 设置效果的发动条件和目标：若卡组存在符合条件的卡则发动，并预埋加入手卡的操作信息。
function c50155385.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：卡组中是否存在至少1张符合条件的仪式怪兽或仪式魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c50155385.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，预告本效果将把1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，从卡组挑选1张符合条件的仪式怪兽或仪式魔法加入手卡，并让对手确认。
function c50155385.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动者选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选出1张符合条件的仪式怪兽或仪式魔法卡。
	local g=Duel.SelectMatchingCard(tp,c50155385.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片以效果原因加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对手确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
