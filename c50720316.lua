--E・HERO シャドー・ミスト
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「变化」速攻魔法卡加入手卡。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把「元素英雄 影雾女郎」以外的1只「英雄」怪兽加入手卡。
function c50720316.initial_effect(c)
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「变化」速攻魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50720316,0))  --"从卡组把1张「变化」速攻魔法卡加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,50720316)
	e1:SetTarget(c50720316.thtg1)
	e1:SetOperation(c50720316.tgop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(50720316,1))  --"从卡组把1只「英雄」怪兽加入手卡"
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(c50720316.thtg2)
	e2:SetOperation(c50720316.tgop2)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡是否为「变化」速攻魔法卡，并且能够加入手卡，用于从卡组检索符合条件的「变化」速攻魔法卡。
function c50720316.thfilter1(c)
	return c:IsSetCard(0xa5) and c:IsType(TYPE_QUICKPLAY) and c:IsAbleToHand()
end
-- ①效果的发动时点判定与发动时处理：若卡组存在符合条件的「变化」速攻魔法卡则可发动；发动后设置本次操作信息为检索加入手卡，并向对方提示已发动该效果。
function c50720316.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中是否存在至少1张满足thfilter1条件的「变化」速攻魔法卡，不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c50720316.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：检索1张卡加入手卡，处理时从己方卡组选择，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 向对方玩家提示己方发动了“从卡组把1张「变化」速攻魔法卡加入手卡”这一效果，使用效果描述文本作为提示内容。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理：玩家从己方卡组选择1张符合条件的「变化」速攻魔法卡加入手卡，并向对方确认所选的卡。
function c50720316.tgop1(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择卡片的提示，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从己方卡组中筛选出1张满足thfilter1条件的卡（「变化」速攻魔法卡且能加入手卡）。
	local g=Duel.SelectMatchingCard(tp,c50720316.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡送去其持有者的手卡，即实际执行加入手卡的处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示所加入手卡的那张卡，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：检查卡是否为「英雄」怪兽、不是「元素英雄 影雾女郎」、并且能够加入手卡，用于②效果的检索。
function c50720316.thfilter2(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and not c:IsCode(50720316) and c:IsAbleToHand()
end
-- ②效果的发动时点判定与发动时处理：若卡组存在符合条件的「英雄」怪兽则可发动；发动后设置本次操作信息为检索加入手卡，并向对方提示已发动该效果。
function c50720316.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中是否存在至少1只满足thfilter2条件的「英雄」怪兽，不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c50720316.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：检索1只怪兽加入手卡，处理时从己方卡组选择，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 向对方玩家提示己方发动了“从卡组把「元素英雄 影雾女郎」以外的1只「英雄」怪兽加入手卡”这一效果，使用效果描述文本作为提示内容。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理：玩家从己方卡组选择1只符合条件的「英雄」怪兽加入手卡，并向对方确认所选的卡。
function c50720316.tgop2(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择卡片的提示，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从己方卡组中筛选出1只满足thfilter2条件的卡（「英雄」怪兽、不是影雾女郎且能加入手卡）。
	local g=Duel.SelectMatchingCard(tp,c50720316.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的那只怪兽送去其持有者的手卡，即实际执行加入手卡的处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示所加入手卡的那张卡，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
