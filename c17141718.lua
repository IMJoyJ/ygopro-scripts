--花札衛－芒－
-- 效果：
-- ①：自己场上有7星以下的「花札卫」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。手卡的「花札卫」怪兽任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量。
function c17141718.initial_effect(c)
	-- ①：自己场上有7星以下的「花札卫」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c17141718.spcon)
	e1:SetTarget(c17141718.sptg)
	e1:SetOperation(c17141718.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。手卡的「花札卫」怪兽任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c17141718.target)
	e2:SetOperation(c17141718.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查场上是否存在7星以下的「花札卫」怪兽
function c17141718.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe6) and c:IsLevelBelow(7)
end
-- 效果发动条件，检查自己场上是否存在7星以下的「花札卫」怪兽
function c17141718.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在7星以下的「花札卫」怪兽
	return Duel.IsExistingMatchingCard(c17141718.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置特殊召唤的处理条件，检查是否有足够的召唤位置并确认该卡可以被特殊召唤
function c17141718.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的效果信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理特殊召唤效果，将该卡特殊召唤到场上，并设置不能召唤/特殊召唤非花札卫怪兽的效果
function c17141718.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 创建并注册一个在回合结束时失效的不能特殊召唤花札卫以外怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c17141718.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 将不能召唤的效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 限制非花札卫怪兽的召唤/特殊召唤
function c17141718.splimit(e,c)
	return not c:IsSetCard(0xe6)
end
-- 过滤函数，检查手牌中是否含有可返回卡组的花札卫怪兽
function c17141718.filter(c)
	return c:IsSetCard(0xe6) and c:IsAbleToDeck() and not c:IsPublic()
end
-- 设置效果处理条件，检查玩家是否可以抽卡并是否存在可返回卡组的花札卫怪兽
function c17141718.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查手牌中是否存在可返回卡组的花札卫怪兽
		and Duel.IsExistingMatchingCard(c17141718.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理信息，指定将手牌中的花札卫怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 处理效果，选择手牌中的花札卫怪兽送回卡组，洗切卡组后抽卡
function c17141718.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 提示玩家选择要返回卡组的花札卫怪兽
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择手牌中满足条件的花札卫怪兽
	local g=Duel.SelectMatchingCard(p,c17141718.filter,p,LOCATION_HAND,0,1,99,nil)
	if g:GetCount()>0 then
		-- 确认对方查看所选的花札卫怪兽
		Duel.ConfirmCards(1-p,g)
		-- 将所选花札卫怪兽送回卡组并洗切
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(p)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 让玩家抽与送回卡组数量相同的卡
		Duel.Draw(p,ct,REASON_EFFECT)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(p)
	end
end
