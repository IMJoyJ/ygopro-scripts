--ゴーティスの月夜サイクス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「魊影的月夜 赛克斯」以外的1只鱼族怪兽加入手卡。那之后，自己的手卡·场上（表侧表示）1只鱼族怪兽除外。
-- ②：这张卡被除外的场合，从自己的手卡·场上（表侧表示）·墓地把「魊影的月夜 赛克斯」以外的1只鱼族怪兽除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 在initial_effect中创建并注册本卡的全部效果：e1/e2分别处理①在通常召唤/特殊召唤成功时的检索并除外鱼族的效果，e3处理②被除外时以除外鱼族为代价自身特殊召唤的效果。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「魊影的月夜 赛克斯」以外的1只鱼族怪兽加入手卡。那之后，自己的手卡·场上（表侧表示）1只鱼族怪兽除外。（此处e1先注册通常召唤成功时点，e2克隆后补上特殊召唤时点）
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
-- 定义检索过滤函数：从卡组中选出种族为鱼族、能够加入手卡、且卡名不是本卡的怪兽。
function s.filter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 定义①效果处理时的除外过滤函数：从自己手牌·场上表侧表示选出种族为鱼族、能够被除外且表侧表示的怪兽。
function s.rgfilter(c,e,tp)
	return c:IsRace(RACE_FISH) and c:IsAbleToRemove() and c:IsFaceupEx()
end
-- ①效果的发动条件与操作信息设置：确认自己可以除外且卡组存在符合条件的鱼族怪兽；若可以发动，则登记本次连锁将进行从卡组加入手卡的操作。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：当前玩家可以进行除外，且卡组中存在至少1张满足s.filter的鱼族怪兽。
	if chk==0 then return Duel.IsPlayerCanRemove(tp) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果将把卡组中1张卡加入手卡，供其他卡发动条件（如星尘龙、王家长眠之谷等）检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1张鱼族怪兽加入手卡并给对方确认；那之后从自己手牌·场上表侧表示选择1只鱼族怪兽除外；用BreakEffect使两步处理不同时进行。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张满足s.filter的鱼族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 如果选到了卡且成功加入手卡，则继续执行后续除外处理。
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 弹出“请选择要除外的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从自己手牌·场上表侧表示选择1张满足s.rgfilter的鱼族怪兽。
		local rg=Duel.SelectMatchingCard(tp,s.rgfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
		if rg:GetCount()>0 then
			-- 中断当前效果，使后续的除外处理与前面的检索处理错开时点，避免被当作同一组效果同时处理。
			Duel.BreakEffect()
			-- 将选择的鱼族怪兽以表侧表示除外，这是①效果“那之后”的除外处理。
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 定义②效果cost的过滤函数：从手牌·场上表侧·墓地中选出种族为鱼族、可作为cost除外、且卡名不是本卡的怪兽。
function s.costfilter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToRemoveAsCost() and c:IsFaceupEx() and not c:IsCode(id)
end
-- ②效果的cost处理：确认存在符合条件的鱼族怪兽后，选择其中1张以表侧表示除外作为发动cost。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost满足条件判定：自己手牌·场上表侧·墓地中是否存在至少1张满足s.costfilter的鱼族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 弹出“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己手牌·场上表侧·墓地选择1张满足s.costfilter的鱼族怪兽作为cost。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的鱼族怪兽以表侧表示除外，作为②效果的发动cost。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标判定：若自身可以被特殊召唤，则登记本次处理将特殊召唤自身。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次连锁将把本卡自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：若本卡仍与效果有联系（未离场或未失效），则将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将本卡以表侧表示特殊召唤到持有者场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
