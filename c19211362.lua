--ネメシス・フラッグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「星义旗舰兽」以外的除外的1只自己怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
-- ②：自己主要阶段才能发动。从卡组把「星义旗舰兽」以外的1只「星义」怪兽加入手卡。
function c19211362.initial_effect(c)
	-- ①：以「星义旗舰兽」以外的除外的1只自己怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19211362,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,19211362)
	e1:SetTarget(c19211362.sptg)
	e1:SetOperation(c19211362.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把「星义旗舰兽」以外的1只「星义」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19211362,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,19211363)
	e2:SetTarget(c19211362.srtg)
	e2:SetOperation(c19211362.srop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断除外区的怪兽是否满足返回卡组的条件
function c19211362.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsCode(19211362) and c:IsAbleToDeck()
end
-- 效果处理时的条件判断，检查是否满足特殊召唤和取对象的条件
function c19211362.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c19211362.tdfilter(chkc) end
	-- 判断玩家场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断玩家除外区是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c19211362.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的除外区怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c19211362.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果操作信息，将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置效果操作信息，将对象怪兽返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理函数，执行特殊召唤和将对象怪兽返回卡组的操作
function c19211362.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断此卡和对象怪兽是否仍存在于场上或手牌中
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果原因送入卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤函数，用于判断卡组中是否满足条件的「星义」怪兽
function c19211362.srfilter(c)
	return c:IsSetCard(0x13d) and c:IsType(TYPE_MONSTER) and not c:IsCode(19211362) and c:IsAbleToHand()
end
-- 效果处理时的条件判断，检查是否满足检索卡组中「星义」怪兽的条件
function c19211362.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家卡组中是否存在满足条件的「星义」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c19211362.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果操作信息，将检索的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行从卡组检索并加入手牌的操作
function c19211362.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的「星义」怪兽
	local g=Duel.SelectMatchingCard(tp,c19211362.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选怪兽的卡面
		Duel.ConfirmCards(1-tp,g)
	end
end
