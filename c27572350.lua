--深淵の神獣ディス・パテル
-- 效果：
-- 调整＋调整以外的龙族怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己或对方的除外状态的1只光·暗属性怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
-- ②：对方把怪兽的效果发动时，以自己或对方的除外状态的1张卡为对象才能发动。那张卡回到卡组。并且，作为对象的卡的持有者是自己的场合，再把那只怪兽破坏。是对方的场合，再把那个发动的效果无效。
function c27572350.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只龙族调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_DRAGON),1)
	c:EnableReviveLimit()
	-- ①：以自己或对方的除外状态的1只光·暗属性怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,27572350)
	e1:SetTarget(c27572350.sptg)
	e1:SetOperation(c27572350.spop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果发动时，以自己或对方的除外状态的1张卡为对象才能发动。那张卡回到卡组。并且，作为对象的卡的持有者是自己的场合，再把那只怪兽破坏。是对方的场合，再把那个发动的效果无效。
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
	-- ②：对方把怪兽的效果发动时，以自己或对方的除外状态的1张卡为对象才能发动。那张卡回到卡组。并且，作为对象的卡的持有者是自己的场合，再把那只怪兽破坏。是对方的场合，再把那个发动的效果无效。
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
-- 特殊召唤的过滤条件：光属性或暗属性且正面表示的怪兽
function c27572350.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 判断是否满足特殊召唤的条件：场上是否有空位且除外区是否有满足条件的怪兽
function c27572350.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c27572350.spfilter(chkc,e,tp) end
	-- 判断是否满足特殊召唤的条件：场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足特殊召唤的条件：除外区是否有满足条件的怪兽
		and Duel.IsExistingTarget(c27572350.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的除外怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c27572350.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c27572350.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 无效效果发动的条件：未被战斗破坏且对方发动怪兽效果且该效果可被无效
function c27572350.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 无效效果发动的条件：未被战斗破坏且对方发动怪兽效果且该效果可被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 设置无效效果的处理目标：除外区的卡
function c27572350.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsAbleToDeck() end
	-- 判断是否满足无效效果的条件：除外区是否有可返回卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_REMOVED,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的除外卡作为返回卡组对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_REMOVED,1,1,nil)
	-- 设置返回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置无效效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 执行无效效果操作
function c27572350.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	local rc=re:GetHandler()
	-- 判断目标卡是否有效且成功送回卡组
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 使效果无效
		Duel.NegateEffect(ev)
	end
end
-- 破坏效果发动的条件：未被战斗破坏且对方发动怪兽效果
function c27572350.descon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 设置破坏效果的处理目标：除外区的卡
function c27572350.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsAbleToDeck() end
	-- 判断是否满足破坏效果的条件：除外区是否有可返回卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的除外卡作为返回卡组对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置返回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 执行破坏效果操作
function c27572350.desop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且成功送回卡组且发动效果的怪兽有效
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and rc:IsRelateToEffect(re) then
		-- 破坏发动效果的怪兽
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
