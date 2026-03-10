--E・HERO シャドー・ミスト
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「变化」速攻魔法卡加入手卡。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把「元素英雄 影雾女郎」以外的1只「英雄」怪兽加入手卡。
function c50720316.initial_effect(c)
	-- 创建效果e1，用于处理特殊召唤成功时的效果发动
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
-- 过滤函数：检索满足条件的「变化」速攻魔法卡
function c50720316.thfilter1(c)
	return c:IsSetCard(0xa5) and c:IsType(TYPE_QUICKPLAY) and c:IsAbleToHand()
end
-- 效果1的目标设置函数：检查是否能从卡组检索一张「变化」速攻魔法卡
function c50720316.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果1的发动条件：是否存在至少1张符合条件的「变化」速攻魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c50720316.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 提示对方玩家已选择效果1
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果1的处理函数：选择并把符合条件的卡加入手牌
function c50720316.tgop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c50720316.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：检索满足条件的「英雄」怪兽（排除影雾女郎）
function c50720316.thfilter2(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and not c:IsCode(50720316) and c:IsAbleToHand()
end
-- 效果2的目标设置函数：检查是否能从卡组检索一只「英雄」怪兽
function c50720316.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果2的发动条件：是否存在至少1张符合条件的「英雄」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c50720316.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 提示对方玩家已选择效果2
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果2的处理函数：选择并把符合条件的卡加入手牌
function c50720316.tgop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c50720316.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
