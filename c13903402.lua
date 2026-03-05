--光の王 マルデル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「光界王战 玛多尔女王」在自己场上只能有1只表侧表示存在。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。「光界王战 玛多尔女王」以外的，1张「王战」卡或者1只植物族怪兽从卡组加入手卡。
function c13903402.initial_effect(c)
	c:SetUniqueOnField(1,0,13903402)
	-- 效果原文内容：②：这张卡召唤·特殊召唤成功的场合才能发动。「光界王战 玛多尔女王」以外的，1张「王战」卡或者1只植物族怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13903402,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,13903402)
	e1:SetTarget(c13903402.thtg)
	e1:SetOperation(c13903402.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的卡片：「王战」卡或植物族怪兽且不是玛多尔女王本体且可以加入手牌
function c13903402.thfilter(c)
	return (c:IsSetCard(0x134) or c:IsRace(RACE_PLANT)) and not c:IsCode(13903402) and c:IsAbleToHand()
end
-- 设置效果的发动时点和处理函数，用于处理检索手牌的效果
function c13903402.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：检查自己卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c13903402.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：准备将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 设置效果的处理函数，用于执行检索手牌的操作
function c13903402.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c13903402.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
