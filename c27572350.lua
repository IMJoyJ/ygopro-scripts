--深淵の神獣ディス・パテル
-- 效果：
-- 调整＋调整以外的龙族怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己或对方的除外状态的1只光·暗属性怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
-- ②：对方把怪兽的效果发动时，以自己或对方的除外状态的1张卡为对象才能发动。那张卡回到卡组。并且，作为对象的卡的持有者是自己的场合，再把那只怪兽破坏。是对方的场合，再把那个发动的效果无效。
function c27572350.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整（无额外限制）＋调整以外的龙族怪兽1只以上，作为同调素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_DRAGON),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己或对方的除外状态的1只光·暗属性怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,27572350)
	e1:SetTarget(c27572350.sptg)
	e1:SetOperation(c27572350.spop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果发动时，以自己或对方的除外状态的1张卡为对象才能发动。那张卡回到卡组。并且，作为对象的卡的持有者是对方的场合，再把那个发动的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27572350,0))  --"以对方除外的卡为对象发动"
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_TODECK)
	e2:SetCode(EVENT_CHAINING)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,27572351)
	e2:SetCondition(c27572350.discon)
	e2:SetTarget(c27572350.distg)
	e2:SetOperation(c27572350.disop)
	c:RegisterEffect(e2)
	-- ②：对方把怪兽的效果发动时，以自己或对方的除外状态的1张卡为对象才能发动。那张卡回到卡组。并且，作为对象的卡的持有者是自己的场合，再把那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27572350,1))  --"以自己除外的卡为对象发动"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,27572351)
	e3:SetCondition(c27572350.descon)
	e3:SetTarget(c27572350.destg)
	e3:SetOperation(c27572350.desop)
	c:RegisterEffect(e3)
end
-- ①效果的特殊召唤候选过滤：对象必须为光属性或暗属性的表侧除外怪兽，并且能够被该效果以表侧表示特殊召唤。
function c27572350.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 效果①的发动判定：若已有指定对象则验证其是否为合法对象（己方除外区且满足召唤条件）；若为发动确认则检查己方主怪兽区有空位且双方除外区存在符合条件的对象。
function c27572350.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c27572350.spfilter(chkc,e,tp) end
	-- 发动条件之一：己方主要怪兽区须有空位，确保后续特殊召唤的场地。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：双方除外区中须存在至少1只满足光/暗属性及特招条件的怪兽。
		and Duel.IsExistingTarget(c27572350.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	-- 发起选卡提示，让玩家选择要特殊召唤的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从双方除外区选择1只符合条件的怪兽，并设置为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c27572350.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	-- 登记连锁操作：本次效果将进行1只怪兽的特殊召唤，供其他卡响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①结算：取得对象，若对象仍与效果关联，则将其表侧表示特殊召唤到己方场上。
function c27572350.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②（对方除外区分支）的发动条件：本卡未被战斗破坏，且对方发动了可被无效的怪兽效果。
function c27572350.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件明细：本卡不处于战斗破坏确定状态；连锁发动者为对方；发动效果为怪兽效果；该连锁可被无效。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 效果②（对方除外区分支）的选对象流程：选择对方除外区1张可返回卡组的卡；登记回卡组与无效对方效果的操作信息。
function c27572350.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsAbleToDeck() end
	-- 发动合法性检查：对方除外区存在至少1张可返回卡组的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_REMOVED,1,nil) end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从对方除外区选择1张可返回卡组的卡作为对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_REMOVED,1,1,nil)
	-- 登记本次连锁将把1张卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 登记本次连锁将使对方发动的怪兽效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果②（对方除外区分支）结算：对象卡若仍关联且成功送回卡组，则无效对方发动的怪兽效果。
function c27572350.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象卡。
	local tc=Duel.GetFirstTarget()
	local rc=re:GetHandler()
	-- 判断对象卡仍与效果关联，并确实通过效果返回了卡组（洗牌再放置）。
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 使当前连锁的对方怪兽效果无效。
		Duel.NegateEffect(ev)
	end
end
-- 效果②（自己除外区分支）的发动条件：本卡未被战斗破坏，且对方发动了怪兽效果。
function c27572350.descon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 效果②（自己除外区分支）的选对象流程：选择自己除外区1张可返回卡组的卡；登记回卡组与破坏那只怪兽的操作信息。
function c27572350.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsAbleToDeck() end
	-- 发动合法性检查：自己除外区存在至少1张可返回卡组的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己除外区选择1张可返回卡组的卡作为对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 登记本次连锁将把1张卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 登记本次连锁将破坏对方发动效果的那只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 效果②（自己除外区分支）结算：对象卡成功返回卡组，且对方怪兽仍与发动效果关联时，将其破坏。
function c27572350.desop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 获取效果②选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡仍与效果关联且实际返回卡组，同时对方发动效果的怪兽仍在该连锁中。
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and rc:IsRelateToEffect(re) then
		-- 以效果破坏对方发动效果的那只怪兽。
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
