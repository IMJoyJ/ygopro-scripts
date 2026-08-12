--デューテリオン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段把这张卡从手卡丢弃才能发动。从卡组把1张「结合术」魔法·陷阱卡加入手卡。
-- ②：这张卡召唤·特殊召唤成功的场合，以自己墓地的「氢素龙」「氧素龙」「氘素龙」的其中1只为对象才能发动。那只怪兽特殊召唤。
function c43017476.initial_effect(c)
	-- 注册该卡牌同时具有氘素龙、氢素龙、氧素龙的卡名代码
	aux.AddCodeList(c,43017476,22587018,58071123)
	-- ①：自己主要阶段把这张卡从手卡丢弃才能发动。从卡组把1张「结合术」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43017476,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,43017476)
	e1:SetCost(c43017476.cost)
	e1:SetTarget(c43017476.target)
	e1:SetOperation(c43017476.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，以自己墓地的「氢素龙」「氧素龙」「氘素龙」的其中1只为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43017476,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,43017477)
	e2:SetTarget(c43017476.sptg)
	e2:SetOperation(c43017476.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 支付效果代价：将此卡从手牌丢入墓地
function c43017476.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡从手牌丢入墓地作为发动效果的代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：筛选卡组中属于结合术系列的魔法或陷阱卡
function c43017476.filter(c)
	return c:IsSetCard(0x100) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果处理信息：准备从卡组检索一张「结合术」魔法或陷阱卡加入手牌
function c43017476.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：卡组中是否存在至少一张「结合术」魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c43017476.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：指定效果将从卡组检索一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：选择并检索一张「结合术」魔法或陷阱卡加入手牌
function c43017476.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的「结合术」魔法或陷阱卡
	local g=Duel.SelectMatchingCard(tp,c43017476.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：筛选墓地中属于氢素龙、氧素龙或氘素龙的怪兽
function c43017476.spfilter(c,e,tp)
	return c:IsCode(22587018,58071123,43017476) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择函数
function c43017476.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c43017476.spfilter(chkc,e,tp) end
	-- 检查是否满足条件：玩家场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足条件：墓地中是否存在至少一张可特殊召唤的氢素龙/氧素龙/氘素龙
		and Duel.IsExistingTarget(c43017476.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择一张满足条件的怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c43017476.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：指定效果将特殊召唤一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将选中的怪兽特殊召唤
function c43017476.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
