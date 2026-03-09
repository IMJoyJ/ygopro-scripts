--ネメシス・アンブレラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「星义伞护兽」以外的除外的1只自己怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
-- ②：以「星义伞护兽」以外的自己墓地1只「星义」怪兽为对象才能发动。那只怪兽加入手卡。
function c46606977.initial_effect(c)
	-- ①：以「星义伞护兽」以外的除外的1只自己怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46606977,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,46606977)
	e1:SetTarget(c46606977.sptg)
	e1:SetOperation(c46606977.spop)
	c:RegisterEffect(e1)
	-- ②：以「星义伞护兽」以外的自己墓地1只「星义」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46606977,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,46606978)
	e2:SetTarget(c46606977.thtg)
	e2:SetOperation(c46606977.thop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的除外怪兽（正面表示、怪兽卡、非星义伞护兽、可送回卡组）
function c46606977.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsCode(46606977) and c:IsAbleToDeck()
end
-- 设置效果处理时的条件判断，检查是否满足特殊召唤和选择目标的条件
function c46606977.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c46606977.tdfilter(chkc) end
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查玩家除外区是否存在符合条件的目标怪兽
		and Duel.IsExistingTarget(c46606977.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择符合条件的除外怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c46606977.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：将目标怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 执行效果处理：将此卡特殊召唤到场上，并将目标怪兽送回卡组
function c46606977.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断此卡和目标怪兽是否仍存在于游戏中并可被处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因送回卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 检索满足条件的墓地怪兽（星义卡组、怪兽卡、非星义伞护兽、可加入手牌）
function c46606977.thfilter(c)
	return c:IsSetCard(0x13d) and c:IsType(TYPE_MONSTER) and not c:IsCode(46606977) and c:IsAbleToHand()
end
-- 设置效果处理时的条件判断，检查是否满足选择目标的条件
function c46606977.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46606977.thfilter(chkc) end
	-- 检查玩家墓地是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c46606977.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择符合条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c46606977.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果处理：将目标怪兽加入手牌
function c46606977.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
