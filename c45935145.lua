--死祖の隷竜ウォロー
-- 效果：
-- 6星怪兽×2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的怪兽的攻击力·守备力上升对方墓地的卡数量×100。
-- ②：可以以对方墓地1张卡为对象，把这张卡的超量素材的以下数量取除，那个效果发动。这个效果在对方回合也能发动。
-- ●1个：那张卡回到卡组。
-- ●2个：那张卡是怪兽的场合，在自己场上表侧表示或者里侧守备表示特殊召唤。那以外的场合，在自己场上盖放。
local s,id,o=GetID()
-- 注册召唤限制与XYZ召唤手续，并注册①永续效果（自己场上的怪兽攻守上升对方墓地卡数×100）以及②的两个诱发即时效果（取除1个素材将对象卡回卡组；取除2个素材将对象怪兽特殊召唤或非怪兽盖放）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加XYZ召唤手续：用6星怪兽2只以上（最多99只）叠放，对应素材要求“6星怪兽×2只以上”
	aux.AddXyzProcedure(c,nil,6,2,nil,nil,99)
	-- ①：自己场上的怪兽的攻击力·守备力上升对方墓地的卡数量×100。（本段代码实现攻击力上升部分）
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
	-- ②：自己·对方回合，可以以对方墓地1张卡为对象，把这张卡的超量素材的以下数量取除，那个效果发动。●1个：作为对象的卡回到卡组。（对应取除1个素材的选项）
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
	-- ②：自己·对方回合，可以以对方墓地1张卡为对象，把这张卡的超量素材的以下数量取除，那个效果发动。●2个：作为对象的卡是怪兽的场合，在自己场上表侧表示或里侧守备表示特殊召唤。那以外的场合，在自己场上盖放。（对应取除2个素材的选项）
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
-- ①效果的攻击力/守备力增加值函数：返回对方墓地卡数量×100
function s.val(e,c)
	-- 计算对方墓地卡数量并乘以100，作为场上的怪兽攻击力·守备力的上升数值
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_GRAVE)*100
end
-- e3（回卡组效果）的发动代价：从这张卡取除1个超量素材
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 回卡组效果的过滤函数：判断对象卡是否可以被送回卡组
function s.tdfilter(c)
	return c:IsAbleToDeck()
end
-- e3的取对象处理：从对方墓地选择1张可以被送回卡组的卡作为对象，并设置回卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.tdfilter(chkc) end
	-- 发动时检查对方墓地是否存在至少1张满足回卡组条件的卡
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向对方玩家提示我方选择了该效果（显示e3的效果描述）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 给当前玩家显示“请选择要返回卡组的卡”的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让当前玩家从对方墓地选择1张满足条件的卡作为对象，并登记为效果对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置这次连锁中将把对象卡送回卡组（CATEGORY_TODECK）的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- e3的效果处理：若对象卡仍与效果关联，则将其送回持有者卡组并洗牌
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得e3效果处理时的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回持有者卡组（弹回卡组并洗牌）
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- e4（特殊召唤/盖放效果）的发动代价：从这张卡取除2个超量素材
function s.sptcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) end
	c:RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- e4的目标过滤条件：怪兽须能特殊召唤且我方主要怪兽区有空位；非怪兽须能盖放且（场地魔法或魔陷区有空位）
function s.sptfilter(c,e,tp)
	-- 怪兽分支：目标必须是怪兽，且我方主要怪兽区有空位，并能以表侧表示或里侧守备表示特殊召唤
	local res1=c:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP+POS_FACEDOWN_DEFENSE)
	local res2=not c:IsType(TYPE_MONSTER) and c:IsSSetable(true)
		-- 非怪兽分支：目标不是怪兽，且能够盖放（若是场地魔法则无需魔陷区空位，否则需要魔陷区有空位）
		and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
	return res1 or res2
end
-- e4的取对象处理：从对方墓地选择1张符合条件的卡，并按对象类型动态设置效果分类（怪兽→特殊召唤/盖放怪兽，非怪兽→盖放魔陷）及操作信息
function s.spttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.sptfilter(chkc,e,tp) end
	-- 发动时检查对方墓地是否存在至少1张符合条件的卡（怪兽可特招或非怪兽可盖放）
	if chk==0 then return Duel.IsExistingTarget(s.sptfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向对方玩家提示我方选择了该效果（显示e4的效果描述）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 给当前玩家显示“请选择效果的对象”的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让当前玩家从对方墓地选择1张符合条件的卡作为对象，并登记为效果对象
	local g=Duel.SelectTarget(tp,s.sptfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	if g:GetFirst():IsType(TYPE_MONSTER) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
		-- 设置这次连锁中将把对象怪兽特殊召唤（CATEGORY_SPECIAL_SUMMON）的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(CATEGORY_SSET)
		-- 设置这次连锁中对象卡将离开墓地（CATEGORY_LEAVE_GRAVE）的操作信息（用于非怪兽盖放的情况）
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- e4的效果处理：若对象是怪兽，则将其特殊召唤（表侧表示或里侧守备表示）；若不是怪兽，则将其盖放到我方魔陷区
function s.sptop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得e4效果处理时的对象卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsType(TYPE_MONSTER) then
		-- 将对象怪兽以表侧表示或里侧守备表示特殊召唤；若特殊召唤成功且为里侧守备表示，则需要进行后续确认
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP+POS_FACEDOWN_DEFENSE)>0 and tc:IsFacedown() then
			-- 将里侧守备表示特殊召唤的怪兽向对方玩家确认
			Duel.ConfirmCards(1-tp,tc)
		end
	else
		-- 将非怪兽对象盖放到我方魔陷区（魔法·陷阱卡盖放）
		Duel.SSet(tp,tc)
	end
end
