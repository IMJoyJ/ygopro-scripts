--竜魔導の守護者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这张卡的效果发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ①：这张卡召唤·特殊召唤的场合，丢弃1张手卡才能发动。从卡组把1张「融合」通常魔法卡加入手卡。
-- ②：把额外卡组1只融合怪兽给对方观看才能发动。那只怪兽有卡名记述的1只融合素材怪兽从自己墓地里侧守备表示特殊召唤。
function c48048590.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，丢弃1张手卡才能发动。从卡组把1张「融合」通常魔法卡加入手卡。
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
	-- ②：把额外卡组1只融合怪兽给对方观看才能发动。那只怪兽有卡名记述的1只融合素材怪兽从自己墓地里侧守备表示特殊召唤。
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
	-- 注册自定义活动计数器，用于检测玩家在回合内从额外卡组特殊召唤融合怪兽以外的怪兽的行为
	Duel.AddCustomActivityCounter(48048590,ACTIVITY_SPSUMMON,c48048590.counterfilter)
end
-- 过滤函数：仅允许不是从额外卡组召唤的怪兽或者表侧表示的融合怪兽通过
function c48048590.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION) and c:IsFaceup()
end
-- 效果发动的誓约限制：检查本回合是否进行过非融合额外卡组怪兽的特殊召唤，并注册本回合不能特殊召唤非融合额外卡组怪兽的限制
function c48048590.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合内自己是否未进行过非融合怪兽的额外卡组特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(48048590,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡的效果发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c48048590.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制自己从额外卡组特殊召唤非融合怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤：不能从额外卡组特殊召唤融合怪兽以外的怪兽
function c48048590.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果①的发动代价（cost）：检查手卡中是否存在可以丢弃的卡，并检查是否满足本回合特殊召唤限制的誓约条件
function c48048590.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动条件检查时，确认自己手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
		and c48048590.cost(e,tp,eg,ep,ev,re,r,rp,0) end
	-- 丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	c48048590.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 过滤卡组中属于「融合」字段的通常魔法卡
function c48048590.thfilter(c)
	return c:GetType()==TYPE_SPELL and c:IsSetCard(0x46) and c:IsAbleToHand()
end
-- 效果①的发动目标：确认卡组中是否存在可以加入手牌的「融合」通常魔法卡，并设置将卡组的1张卡加入手卡的操作信息
function c48048590.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认卡组中是否存在可以加入手牌的「融合」通常魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c48048590.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组的1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：从卡组选择1张「融合」通常魔法卡加入手牌并给对方确认
function c48048590.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合检索条件的卡
	local g=Duel.SelectMatchingCard(tp,c48048590.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤额外卡组中的融合怪兽，要求其记述的素材中有1只存在于自己墓地且可以特殊召唤
function c48048590.filter1(c,e,tp)
	-- 判断是否为融合怪兽，且其有记述卡名的融合素材怪兽在自己墓地满足特殊召唤条件
	return c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(c48048590.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
-- 墓地融合素材特殊召唤的过滤条件：可里侧守备表示特殊召唤，且为展示的融合怪兽记述了卡名的素材怪兽
function c48048590.filter2(c,e,tp,fc)
	-- 判断怪兽是否可以里侧守备表示特殊召唤，且其卡名记述在作为参数传入的融合怪兽的素材列表中
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and aux.IsMaterialListCode(fc,c:GetCode())
end
-- 效果②的发动代价与条件检查：满足本回合特殊召唤誓约，并且额外卡组有符合条件的融合怪兽可以展示
function c48048590.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c48048590.cost(e,tp,eg,ep,ev,re,r,rp,0)
		-- 确认额外卡组中是否存在可以给对方展示的融合怪兽
		and Duel.IsExistingMatchingCard(c48048590.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 提示玩家选择要向对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从额外卡组选择1只符合条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c48048590.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	-- 向对方展示所选的融合怪兽
	Duel.ConfirmCards(1-tp,g)
	e:SetLabelObject(g:GetFirst())
	c48048590.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 效果②的发动目标：确认自己场上有可用的怪兽区域，并设置将墓地的卡特殊召唤的操作信息
function c48048590.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空置的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置将墓地怪兽特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的处理：在自己场上存在可用怪兽区域的前提下，选择墓地中记述于展示融合怪兽素材中的怪兽，以里侧守备表示特殊召唤
function c48048590.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果场上已无可用怪兽区域，则结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local fc=e:GetLabelObject()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择1只不受王家长眠之谷影响的、卡名记述在展示融合怪兽上的素材怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c48048590.filter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,fc)
	if g:GetCount()>0 then
		-- 将选中的怪兽在自己场上里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方玩家确认特殊召唤的里侧表示怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
