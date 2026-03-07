--暗黒界の龍神王 グラファ
-- 效果：
-- 「暗黑界的龙神 格拉法」＋暗属性怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方把怪兽的效果·通常魔法·通常陷阱卡发动时才能发动。那个效果变成「对方选自身1张手卡丢弃」。
-- ②：融合召唤的这张卡因对方从场上离开的场合才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选1只「暗黑界的龙神 格拉法」特殊召唤。那之后，有手卡的玩家选自身1张手卡丢弃。
function c39552584.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用卡号34230233的怪兽和1个暗属性怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,34230233,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),1,true,true)
	-- ①：对方把怪兽的效果·通常魔法·通常陷阱卡发动时才能发动。那个效果变成「对方选自身1张手卡丢弃」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39552584,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,39552584)
	e1:SetCondition(c39552584.chcon)
	e1:SetTarget(c39552584.chtg)
	e1:SetOperation(c39552584.chop)
	c:RegisterEffect(e1)
	-- ②：融合召唤的这张卡因对方从场上离开的场合才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选1只「暗黑界的龙神 格拉法」特殊召唤。那之后，有手卡的玩家选自身1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39552584,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c39552584.spcon)
	e2:SetTarget(c39552584.sptg)
	e2:SetOperation(c39552584.spop)
	c:RegisterEffect(e2)
end
-- 效果发动时的条件判断：对方发动怪兽效果、通常魔法或通常陷阱卡
function c39552584.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and (re:IsActiveType(TYPE_MONSTER)
		or (re:GetActiveType()==TYPE_SPELL or re:GetActiveType()==TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 效果的发动准备阶段：检查对方是否有可丢弃的手卡
function c39552584.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方是否有可丢弃的手卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,rp,0,LOCATION_HAND,1,nil,REASON_EFFECT) end
end
-- 效果处理阶段：将连锁目标设为空组并替换连锁效果处理函数
function c39552584.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 将连锁的处理对象设为空组
	Duel.ChangeTargetCard(ev,g)
	-- 将连锁的效果处理函数替换为repop函数
	Duel.ChangeChainOperation(ev,c39552584.repop)
end
-- 替换后的连锁效果处理函数：提示对方选择丢弃手卡并执行丢弃
function c39552584.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示对方选择丢弃手卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 对方丢弃1张手卡
	Duel.DiscardHand(1-tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD)
end
-- 特殊召唤的过滤条件：卡号为34230233且可特殊召唤的怪兽，且在墓地或里侧表示
function c39552584.spfilter(c,e,tp)
	return c:IsCode(34230233) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 特殊召唤效果的发动条件：此卡为融合召唤且因对方离场
function c39552584.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 特殊召唤效果的发动准备阶段：检查是否有满足条件的怪兽可特殊召唤
function c39552584.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地或除外区是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(c39552584.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	-- 设置操作信息：双方各丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,1)
end
-- 特殊召唤效果处理阶段：选择并特殊召唤1只怪兽，然后双方各丢弃1张手卡
function c39552584.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位可特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39552584.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 若成功特殊召唤，则中断当前效果并执行丢弃手卡
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 己方丢弃1张手卡
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD,nil)
		-- 对方丢弃1张手卡
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD,nil)
	end
end
