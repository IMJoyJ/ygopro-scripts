--竜魔導の守護者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这张卡的效果发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ①：这张卡召唤·特殊召唤的场合，丢弃1张手卡才能发动。从卡组把1张「融合」通常魔法卡加入手卡。
-- ②：把额外卡组1只融合怪兽给对方观看才能发动。那只怪兽有卡名记述的1只融合素材怪兽从自己墓地里侧守备表示特殊召唤。
function c48048590.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤·特殊召唤的场合，丢弃1张手卡才能发动。从卡组把1张「融合」通常魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48048590,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,48048590)
	e1:SetCost(c48048590.thcost)
	e1:SetTarget(c48048590.thtg)
	e1:SetOperation(c48048590.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：把额外卡组1只融合怪兽给对方观看才能发动。那只怪兽有卡名记述的1只融合素材怪兽从自己墓地里侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48048590,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,48048591)
	e3:SetCost(c48048590.spcost)
	e3:SetTarget(c48048590.sptg)
	e3:SetOperation(c48048590.spop)
	c:RegisterEffect(e3)
	-- 规则层面操作：设置一个计数器，用于限制该卡在回合内特殊召唤次数
	Duel.AddCustomActivityCounter(48048590,ACTIVITY_SPSUMMON,c48048590.counterfilter)
end
-- 规则层面操作：计数器过滤函数，排除从额外卡组特殊召唤且为融合怪兽的卡片
function c48048590.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
-- 规则层面操作：创建并注册一个场地方效果，使玩家在本回合不能特殊召唤非融合怪兽到额外卡组
function c48048590.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查该玩家是否已使用过此效果（通过计数器判断）
	if chk==0 then return Duel.GetCustomActivityCount(48048590,tp,ACTIVITY_SPSUMMON)==0 end
	-- 规则层面操作：注册一个场地方效果，使玩家在本回合不能特殊召唤非融合怪兽到额外卡组
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c48048590.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面操作：将创建的效果注册给指定玩家
	Duel.RegisterEffect(e1,tp)
end
-- 规则层面操作：限制效果的目标为非融合怪兽且位于额外卡组的卡片
function c48048590.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 规则层面操作：检查是否满足丢弃手牌的条件
function c48048590.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否有可丢弃的手牌
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
		and c48048590.cost(e,tp,eg,ep,ev,re,r,rp,0) end
	-- 规则层面操作：执行丢弃手牌的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	c48048590.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 规则层面操作：检索满足条件的魔法卡过滤函数
function c48048590.thfilter(c)
	return c:GetType()==TYPE_SPELL and c:IsSetCard(0x46) and c:IsAbleToHand()
end
-- 规则层面操作：设置效果处理信息，表示将从卡组检索一张魔法卡加入手牌
function c48048590.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否有满足条件的魔法卡存在于卡组中
	if chk==0 then return Duel.IsExistingMatchingCard(c48048590.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面操作：设置效果处理信息，表示将从卡组检索一张魔法卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：执行检索并加入手牌的操作
function c48048590.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面操作：选择满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c48048590.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面操作：向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 规则层面操作：筛选额外卡组中融合怪兽的过滤函数
function c48048590.filter1(c,e,tp)
	-- 规则层面操作：检查是否存在满足条件的融合怪兽
	return c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(c48048590.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
-- 规则层面操作：筛选墓地中可特殊召唤的融合素材怪兽的过滤函数
function c48048590.filter2(c,e,tp,fc)
	-- 规则层面操作：检查是否满足特殊召唤条件并为融合素材
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and aux.IsMaterialListCode(fc,c:GetCode())
end
-- 规则层面操作：检查是否满足特殊召唤的费用条件
function c48048590.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c48048590.cost(e,tp,eg,ep,ev,re,r,rp,0)
		-- 规则层面操作：检查是否存在满足条件的额外卡组融合怪兽
		and Duel.IsExistingMatchingCard(c48048590.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 规则层面操作：提示玩家选择要给对方确认的融合怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 规则层面操作：选择满足条件的额外卡组融合怪兽
	local g=Duel.SelectMatchingCard(tp,c48048590.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	-- 规则层面操作：向对方确认所选的融合怪兽
	Duel.ConfirmCards(1-tp,g)
	e:SetLabelObject(g:GetFirst())
	c48048590.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 规则层面操作：设置效果处理信息，表示将从墓地特殊召唤一只怪兽
function c48048590.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否有足够的场地空位进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 规则层面操作：设置效果处理信息，表示将从墓地特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 规则层面操作：执行特殊召唤的操作
function c48048590.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：检查是否有足够的场地空位进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local fc=e:GetLabelObject()
	-- 规则层面操作：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：选择满足条件的墓地怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c48048590.filter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,fc)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的卡以里侧守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 规则层面操作：向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
