--アトミック・スクラップ・ドラゴン
-- 效果：
-- 名字带有「废铁」的调整＋调整以外的怪兽2只以上
-- 1回合1次，选择自己场上存在的1张卡和对方墓地存在的最多3张卡才能发动。选择的自己的卡破坏，选择的对方的卡回到卡组。这张卡被对方破坏送去墓地时，选择同调怪兽以外的自己墓地存在的1只名字带有「废铁」的怪兽特殊召唤。
function c92361635.initial_effect(c)
	-- 添加同调召唤手续：名字带有「废铁」的调整＋调整以外的怪兽2只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x24),aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	-- 1回合1次，选择自己场上存在的1张卡和对方墓地存在的最多3张卡才能发动。选择的自己的卡破坏，选择的对方的卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92361635,0))  --"破坏和返回卡组"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c92361635.destg)
	e1:SetOperation(c92361635.desop)
	c:RegisterEffect(e1)
	-- 这张卡被对方破坏送去墓地时，选择同调怪兽以外的自己墓地存在的1只名字带有「废铁」的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92361635,1))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c92361635.spcon)
	e2:SetTarget(c92361635.sptg)
	e2:SetOperation(c92361635.spop)
	c:RegisterEffect(e2)
end
-- 效果1（破坏并回卡组）的靶向与发动条件判定函数
function c92361635.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定自己场上是否存在至少1张卡可以作为效果对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
		-- 并且判定对方墓地是否存在至少1张可以回到卡组的卡
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上的1张卡作为效果对象
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置连锁操作信息，表示该效果包含破坏所选卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方墓地1到3张可以回到卡组的卡作为效果对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,3,nil)
	-- 设置连锁操作信息，表示该效果包含将所选卡片送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,g2:GetCount(),0,0)
end
-- 效果1（破坏并回卡组）的效果处理函数
function c92361635.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中预设的破坏操作信息及对应的卡片组
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	-- 获取当前连锁中预设的返回卡组操作信息及对应的卡片组
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	-- 判定选择的自己的卡是否仍与效果相关，若是则将其破坏，并判定是否破坏成功
	if g1:GetFirst():IsRelateToEffect(e) and Duel.Destroy(g1,REASON_EFFECT)~=0 then
		local hg=g2:Filter(Card.IsRelateToEffect,nil,e)
		-- 将仍与效果相关的对方墓地的卡送回卡组并洗牌
		Duel.SendtoDeck(hg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 判定特殊召唤效果的发动条件：此卡被对方破坏并送去自己墓地
function c92361635.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 过滤自己墓地中同调怪兽以外的名字带有「废铁」且可以特殊召唤的怪兽
function c92361635.spfilter(c,e,tp)
	return c:IsSetCard(0x24) and not c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2（特殊召唤）的靶向与发动条件判定函数
function c92361635.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c92361635.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「废铁」怪兽作为特殊召唤的对象
	local g=Duel.SelectTarget(tp,c92361635.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，表示该效果包含特殊召唤所选怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果2（特殊召唤）的效果处理函数
function c92361635.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的特殊召唤对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
