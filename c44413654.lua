--D・インパクトリターン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以对方场上最多2张魔法·陷阱卡为对象才能发动。从手卡让1只「变形斗士」怪兽回到卡组，作为对象的卡回到持有者卡组。
-- ②：把墓地的这张卡除外，从自己墓地的怪兽以及除外的自己怪兽之中以1只「变形斗士」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c44413654.initial_effect(c)
	-- ①：以对方场上最多2张魔法·陷阱卡为对象才能发动。从手卡让1只「变形斗士」怪兽回到卡组，作为对象的卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,44413654)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetTarget(c44413654.target)
	e1:SetOperation(c44413654.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，从自己墓地的怪兽以及除外的自己怪兽之中以1只「变形斗士」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,44413654)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44413654.sptg)
	e2:SetOperation(c44413654.spop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可返回卡组的「变形斗士」怪兽
function c44413654.dfilter(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 过滤场上可返回卡组的魔法·陷阱卡
function c44413654.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 设置效果目标为对方场上的魔法·陷阱卡
function c44413654.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c44413654.filter(chkc) end
	-- 检查对方场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c44413654.filter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查手卡中是否存在「变形斗士」怪兽
		and Duel.IsExistingMatchingCard(c44413654.dfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上的1~2张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c44413654.filter,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 设置效果处理信息为将对象卡和手卡的「变形斗士」怪兽返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g+1,tp,LOCATION_ONFIELD+LOCATION_HAND)
end
-- 处理效果发动，选择手卡的「变形斗士」怪兽返回卡组并确认其位置
function c44413654.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手卡选择1只「变形斗士」怪兽返回卡组
	local sc=Duel.SelectMatchingCard(tp,c44413654.dfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	if not sc then return end
	-- 确认对方查看所选的「变形斗士」怪兽
	Duel.ConfirmCards(1-tp,sc)
	-- 将所选的「变形斗士」怪兽返回卡组并检查是否成功
	if Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_DECK) then
		-- 获取连锁中被选择的对象卡组并筛选出与效果相关的卡
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		-- 将对象卡组中的卡返回卡组
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤墓地或除外区中可特殊召唤的「变形斗士」怪兽
function c44413654.spfilter(c,e,tp)
	return c:IsSetCard(0x26) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果目标为己方墓地或除外区的「变形斗士」怪兽
function c44413654.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c44413654.spfilter(chkc,e,tp) end
	-- 检查己方场上是否存在召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方墓地或除外区是否存在「变形斗士」怪兽
		and Duel.IsExistingTarget(c44413654.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择己方墓地或除外区的1只「变形斗士」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c44413654.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息为将对象怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果发动，将对象怪兽以守备表示特殊召唤
function c44413654.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以守备表示特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
