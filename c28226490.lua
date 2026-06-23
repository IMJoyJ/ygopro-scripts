--ティアラメンツ・カレイドハート
-- 效果：
-- 「珠泪哀歌族·雷诺哈特」＋水族怪兽×2
-- 这张卡不能作为融合素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合或者这张卡在场上存在的状态有水族怪兽被效果送去自己墓地的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者卡组。
-- ②：这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤，从卡组把1张「珠泪哀歌族」卡送去墓地。
function c28226490.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号73956664的怪兽和2只水族怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,73956664,aux.FilterBoolFunction(Card.IsRace,RACE_AQUA),2,true,true)
	-- 这张卡不能作为融合素材
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- ①：这张卡特殊召唤成功的场合或者这张卡在场上存在的状态有水族怪兽被效果送去自己墓地的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者卡组
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28226490,0))  --"对方卡回到持有者卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,28226490)
	e1:SetTarget(c28226490.tdtg)
	e1:SetOperation(c28226490.tdop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c28226490.tdcon)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤，从卡组把1张「珠泪哀歌族」卡送去墓地
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28226490,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,28226491)
	e3:SetCondition(c28226490.spcond)
	e3:SetTarget(c28226490.sptg)
	e3:SetOperation(c28226490.spop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的卡：被效果送入墓地且控制者为玩家tp且种族为水族
function c28226490.cfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsControler(tp) and c:IsRace(RACE_AQUA)
end
-- 判断是否有满足条件的卡被送入墓地
function c28226490.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28226490.cfilter,1,nil,tp)
end
-- 设置效果目标，选择对方场上1张可返回卡组的卡
function c28226490.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() and chkc:IsControler(1-tp) end
	-- 检查是否有对方场上的卡可以作为效果目标
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上1张可返回卡组的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，指定将1张卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 执行效果操作，将目标卡返回卡组
function c28226490.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡返回卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 判断此卡是否因效果送入墓地
function c28226490.spcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤满足条件的卡：属于珠泪哀歌族且可送去墓地
function c28226490.tgfilter(c)
	return c:IsSetCard(0x181) and c:IsAbleToGrave()
end
-- 设置效果目标，检查是否可以特殊召唤并从卡组送1张珠泪哀歌族卡入墓地
function c28226490.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查玩家卡组中是否有满足条件的珠泪哀歌族卡
		and Duel.IsExistingMatchingCard(c28226490.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果操作信息，指定将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置效果操作信息，指定将1张珠泪哀歌族卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行效果操作，将此卡特殊召唤并从卡组送1张珠泪哀歌族卡入墓地
function c28226490.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否能参与特殊召唤并执行特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择1张珠泪哀歌族卡送去墓地
		local g=Duel.SelectMatchingCard(tp,c28226490.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 将选中的卡送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
