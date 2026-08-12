--死祖の隷竜ウォロー
-- 效果：
-- 6星怪兽×2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的怪兽的攻击力·守备力上升对方墓地的卡数量×100。
-- ②：可以以对方墓地1张卡为对象，把这张卡的超量素材的以下数量取除，那个效果发动。这个效果在对方回合也能发动。
-- ●1个：那张卡回到卡组。
-- ●2个：那张卡是怪兽的场合，在自己场上表侧表示或者里侧守备表示特殊召唤。那以外的场合，在自己场上盖放。
local s,id,o=GetID()
-- 初始化效果，启用复活限制，添加XYZ召唤手续，设置攻击力和守备力上升效果，设置两个效果，分别为1个和2个超量素材的处理效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续，要求6星怪兽2只以上作为素材
	aux.AddXyzProcedure(c,nil,6,2,nil,nil,99)
	-- ①：自己场上的怪兽的攻击力·守备力上升对方墓地的卡数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：可以以对方墓地1张卡为对象，把这张卡的超量素材的以下数量取除，那个效果发动。这个效果在对方回合也能发动。●1个：那张卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"取除1个超量素材"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(s.tdcost)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	-- ●2个：那张卡是怪兽的场合，在自己场上表侧表示或者里侧守备表示特殊召唤。那以外的场合，在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"取除2个超量素材"
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET+CATEGORY_MSET)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCost(s.sptcost)
	e4:SetTarget(s.spttg)
	e4:SetOperation(s.sptop)
	c:RegisterEffect(e4)
end
-- 计算对方墓地卡的数量并乘以100作为攻击力和守备力的上升值
function s.val(e,c)
	-- 对方墓地的卡数量×100
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_GRAVE)*100
end
-- 效果发动时，消耗1个超量素材作为代价
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 返回卡组效果的过滤器，判断卡片是否能返回卡组
function s.tdfilter(c)
	return c:IsAbleToDeck()
end
-- 设置取除1个超量素材效果的目标选择处理
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.tdfilter(chkc) end
	-- 检查是否存在满足条件的目标卡片
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标卡片
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息，确定要返回卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 执行取除1个超量素材效果的处理
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果发动时，消耗2个超量素材作为代价
function s.sptcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) end
	c:RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 返回特殊召唤或盖放效果的过滤器，判断卡片是否可以特殊召唤或盖放
function s.sptfilter(c,e,tp)
	-- 判断卡片是否为怪兽且场上是否有足够的怪兽区域
	local res1=c:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP+POS_FACEDOWN_DEFENSE)
	local res2=not c:IsType(TYPE_MONSTER) and c:IsSSetable(true)
		-- 判断卡片是否为非怪兽且场上是否有足够的魔陷区域或为场地魔法
		and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
	return res1 or res2
end
-- 设置取除2个超量素材效果的目标选择处理
function s.spttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.sptfilter(chkc,e,tp) end
	-- 检查是否存在满足条件的目标卡片
	if chk==0 then return Duel.IsExistingTarget(s.sptfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标卡片
	local g=Duel.SelectTarget(tp,s.sptfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	if g:GetFirst():IsType(TYPE_MONSTER) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
		-- 设置操作信息，确定要特殊召唤的卡
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(CATEGORY_SSET)
		-- 设置操作信息，确定要盖放的卡
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 执行取除2个超量素材效果的处理
function s.sptop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsType(TYPE_MONSTER) then
		-- 特殊召唤目标卡片，若为里侧表示则确认其内容
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP+POS_FACEDOWN_DEFENSE)>0 and tc:IsFacedown() then
			-- 确认对方玩家目标卡片内容
			Duel.ConfirmCards(1-tp,tc)
		end
	else
		-- 将目标卡片盖放在场上
		Duel.SSet(tp,tc)
	end
end
