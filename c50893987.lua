--剣闘獣ティゲル
-- 效果：
-- 这张卡不能作为融合素材怪兽使用。这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时，可以从手卡把1张名字带有「剑斗兽」的卡丢弃，从自己卡组把1只名字带有「剑斗兽」的怪兽加入手卡。
function c50893987.initial_effect(c)
	-- 创建一个诱发选发效果，用于检索满足条件的卡片
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50893987,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 该效果仅在使用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时才能发动
	e1:SetCondition(aux.gbspcon)
	e1:SetCost(c50893987.sccost)
	e1:SetTarget(c50893987.sctg)
	e1:SetOperation(c50893987.scop)
	c:RegisterEffect(e1)
	-- 这张卡不能作为融合素材怪兽使用
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在名字带有「剑斗兽」且可丢弃的卡片
function c50893987.costfilter(c)
	return c:IsSetCard(0x1019) and c:IsDiscardable()
end
-- 效果处理时，检查玩家手卡是否存在满足条件的卡片并进行丢弃操作
function c50893987.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手卡中是否存在至少1张满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c50893987.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从玩家手卡中丢弃1张满足条件的卡片，作为效果的代价
	Duel.DiscardHand(tp,c50893987.costfilter,1,1,REASON_DISCARD+REASON_COST,nil)
end
-- 过滤函数，用于检索卡组中名字带有「剑斗兽」且为怪兽的卡片
function c50893987.scfilter(c)
	return c:IsSetCard(0x1019) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理时，检查玩家卡组是否存在满足条件的卡片并设置连锁信息
function c50893987.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组中是否存在至少1张满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c50893987.scfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索1张名字带有「剑斗兽」的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，选择并把满足条件的卡从卡组加入手牌，并向对方确认这些卡
function c50893987.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从玩家卡组中选择1张满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,c50893987.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认被送入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
