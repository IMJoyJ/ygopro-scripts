--サイレンス・シーネットル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有水属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果发动的回合，自己不是水属性怪兽不能特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地最多3只水属性怪兽为对象才能发动。那些怪兽回到卡组。
function c31059809.initial_effect(c)
	-- ①：自己场上有水属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果发动的回合，自己不是水属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31059809,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31059809)
	e1:SetCondition(c31059809.spcon)
	e1:SetCost(c31059809.spcost)
	e1:SetTarget(c31059809.sptg)
	e1:SetOperation(c31059809.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地最多3只水属性怪兽为对象才能发动。那些怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31059809,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,31059810)
	-- 将此卡从墓地除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c31059809.tdtg)
	e2:SetOperation(c31059809.tdop)
	c:RegisterEffect(e2)
	-- 设置一个计数器，用于限制每回合此卡的效果使用次数
	Duel.AddCustomActivityCounter(31059809,ACTIVITY_SPSUMMON,c31059809.counterfilter)
end
-- 计数器的过滤函数，仅统计水属性怪兽
function c31059809.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
-- 用于判断场上是否存在水属性的表侧表示怪兽
function c31059809.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果发动的条件：自己场上有水属性怪兽存在
function c31059809.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在水属性的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c31059809.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果的cost：检查是否为本回合第一次使用此卡的效果
function c31059809.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否为本回合第一次使用此卡的效果
	if chk==0 then return Duel.GetCustomActivityCount(31059809,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建一个影响全场的永续效果，禁止非水属性怪兽的特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTarget(c31059809.splimit)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 该效果的限制函数，禁止非水属性怪兽的特殊召唤
function c31059809.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 设置特殊召唤的处理目标
function c31059809.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤的处理函数
function c31059809.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 用于筛选墓地中的水属性怪兽
function c31059809.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToDeck()
end
-- 设置返回卡组的效果处理目标
function c31059809.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31059809.tdfilter(chkc) end
	-- 检查是否有满足条件的墓地水属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c31059809.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标墓地水属性怪兽
	local g=Duel.SelectTarget(tp,c31059809.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设置返回卡组的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 返回卡组的处理函数
function c31059809.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选定的目标卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将目标卡送回卡组
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
