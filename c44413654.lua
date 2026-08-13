--D・インパクトリターン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以对方场上最多2张魔法·陷阱卡为对象才能发动。从手卡让1只「变形斗士」怪兽回到卡组，作为对象的卡回到持有者卡组。
-- ②：把墓地的这张卡除外，从自己墓地的怪兽以及除外的自己怪兽之中以1只「变形斗士」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c44413654.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：以对方场上最多2张魔法·陷阱卡为对象才能发动。从手卡让1只「变形斗士」怪兽回到卡组，作为对象的卡回到持有者卡组。
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
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：把墓地的这张卡除外，从自己墓地的怪兽以及除外的自己怪兽之中以1只「变形斗士」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,44413654)
	-- 设置②效果的发动费用为将墓地的这张卡除外（aux.bfgcost实现了除外自身作为cost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44413654.sptg)
	e2:SetOperation(c44413654.spop)
	c:RegisterEffect(e2)
end
-- 定义①效果中从手卡返回卡组的「变形斗士」怪兽的筛选条件：具有「变形斗士」字段、是怪兽且可以返回卡组。
function c44413654.dfilter(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 定义①效果的对象的筛选条件：对方场上的魔法·陷阱卡且可以返回卡组。
function c44413654.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- ①效果的发动条件检查与对象选择：确认对方场上有可作为对象的魔法·陷阱卡，且自己手卡有可返回卡组的「变形斗士」怪兽；若指定对象则验证其位于对方场上且满足filter条件。
function c44413654.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c44413654.filter(chkc) end
	-- 检查对方场上是否存在至少1张满足filter（魔法·陷阱且能回卡组）的卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c44413654.filter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 同时检查自己手卡是否存在至少1只满足dfilter（「变形斗士」怪兽且能回卡组）的卡，作为从手卡送回卡组的代价。
		and Duel.IsExistingMatchingCard(c44413654.dfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 显示“请选择要返回卡组的卡”的选择提示，引导玩家选择要送回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上1～2张满足filter的魔法·陷阱卡作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c44413654.filter,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 登记本连锁的操作信息为“返回卡组”：预计处理的卡牌数量为已选对象数＋1（手卡1只），涉及对方场上和自己手卡的卡片。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g+1,tp,LOCATION_ONFIELD+LOCATION_HAND)
end
-- ①效果处理时的操作：从手卡选择1只「变形斗士」怪兽返回卡组洗牌；若成功且该卡在卡组，则再将之前选择的对象卡也送回持有者卡组洗牌。
function c44413654.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己手卡选择1只满足dfilter的「变形斗士」怪兽，作为要返回卡组的卡。
	local sc=Duel.SelectMatchingCard(tp,c44413654.dfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	if not sc then return end
	-- 向对方玩家展示选择要返回卡组的手卡怪兽，确认这张卡。
	Duel.ConfirmCards(1-tp,sc)
	-- 将选择的手卡怪兽返回持有者卡组并洗牌；如果返回成功（返回值>0）且该卡确实位于卡组，则继续处理对象卡。
	if Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_DECK) then
		-- 取得当前连锁的对象卡组，并过滤出仍与该效果相关的卡（没有失去联系的卡）。
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		-- 将过滤后的对象卡（对方场上魔法·陷阱卡）送回持有者卡组并洗牌。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 定义②效果可特殊召唤的怪兽的筛选条件：具有「变形斗士」字段、位于自己墓地或表侧表示除外的自己怪兽，且可以被表侧守备表示特殊召唤。
function c44413654.spfilter(c,e,tp)
	return c:IsSetCard(0x26) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动条件检查与对象选择：确认自己主要怪兽区有空位，且自己墓地或除外区存在符合条件的「变形斗士」怪兽；若指定对象则验证其属于自己且位置在墓地或除外区并满足spfilter。
function c44413654.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c44413654.spfilter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否存在可用空格，以确定能否进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查自己墓地或除外区是否存在至少1只满足spfilter的「变形斗士」怪兽可作为对象。
		and Duel.IsExistingTarget(c44413654.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地或除外区选择1只满足spfilter的「变形斗士」怪兽作为对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c44413654.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 登记本连锁的操作信息为“特殊召唤”：预定将1只对象怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理时的操作：取得对象怪兽，若其仍与该效果相关，则将其表侧守备表示特殊召唤到自己场上。
function c44413654.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（1只「变形斗士」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上（不检查召唤条件和苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
