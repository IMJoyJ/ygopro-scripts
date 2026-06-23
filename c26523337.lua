--ゴーティスの月夜サイクス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「魊影的月夜 赛克斯」以外的1只鱼族怪兽加入手卡。那之后，自己的手卡·场上（表侧表示）1只鱼族怪兽除外。
-- ②：这张卡被除外的场合，从自己的手卡·场上（表侧表示）·墓地把「魊影的月夜 赛克斯」以外的1只鱼族怪兽除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 创建并注册3个效果，分别对应①②效果和召唤·特殊召唤的触发条件
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「魊影的月夜 赛克斯」以外的1只鱼族怪兽加入手卡。那之后，自己的手卡·场上（表侧表示）1只鱼族怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被除外的场合，从自己的手卡·场上（表侧表示）·墓地把「魊影的月夜 赛克斯」以外的1只鱼族怪兽除外才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于检索满足条件的鱼族怪兽（不包括自身）
function s.filter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 过滤函数，用于选择可除外的鱼族怪兽（表侧表示）
function s.rgfilter(c,e,tp)
	return c:IsRace(RACE_FISH) and c:IsAbleToRemove() and c:IsFaceupEx()
end
-- 设置检索和回手的处理信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件（玩家可除外且卡组存在符合条件的鱼族怪兽）
	if chk==0 then return Duel.IsPlayerCanRemove(tp) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡为1张手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理①效果的发动，从卡组检索鱼族怪兽并除外自己场上的鱼族怪兽
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的鱼族怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认卡牌加入手牌后，继续处理除外操作
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 向对方确认已加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择满足条件的鱼族怪兽进行除外
		local rg=Duel.SelectMatchingCard(tp,s.rgfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
		if rg:GetCount()>0 then
			-- 中断当前效果处理，使后续处理错开时点
			Duel.BreakEffect()
			-- 将选中的卡以正面表示形式除外
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于选择作为除外费用的鱼族怪兽（表侧表示，不包括自身）
function s.costfilter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToRemoveAsCost() and c:IsFaceupEx() and not c:IsCode(id)
end
-- 处理②效果的发动，选择除外鱼族怪兽作为费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足除外费用条件（手牌/场上/墓地存在符合条件的鱼族怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的鱼族怪兽作为除外费用
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以正面表示形式除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置②效果的特殊召唤处理信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，指定将要处理的卡为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 处理②效果的发动，将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以正面表示形式特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
