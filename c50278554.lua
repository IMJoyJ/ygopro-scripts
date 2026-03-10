--スクラップ・ツイン・ドラゴン
-- 效果：
-- 名字带有「废铁」的调整＋调整以外的怪兽1只以上
-- 1回合1次，选择自己场上存在的1张卡和对方场上存在的2张卡才能发动。选择的自己的卡破坏，选择的对方的卡回到手卡。这张卡被对方破坏送去墓地时，选择同调怪兽以外的自己墓地存在的1只名字带有「废铁」的怪兽特殊召唤。
function c50278554.initial_effect(c)
	-- 添加同调召唤手续，要求1只名字带有「废铁」的调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x24),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，选择自己场上存在的1张卡和对方场上存在的2张卡才能发动。选择的自己的卡破坏，选择的对方的卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50278554,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c50278554.destg)
	e1:SetOperation(c50278554.desop)
	c:RegisterEffect(e1)
	-- 这张卡被对方破坏送去墓地时，选择同调怪兽以外的自己墓地存在的1只名字带有「废铁」的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50278554,1))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c50278554.spcon)
	e2:SetTarget(c50278554.sptg)
	e2:SetOperation(c50278554.spop)
	c:RegisterEffect(e2)
end
-- 判断是否满足发动条件：自己场上存在至少1张卡，对方场上存在至少2张卡
function c50278554.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足发动条件：自己场上存在至少1张卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
		-- 判断是否满足发动条件：对方场上存在至少2张卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上存在的1张卡作为破坏对象
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息，记录将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上存在的2张卡作为返回手牌的对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,2,2,nil)
	-- 设置操作信息，记录将要返回手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,2,0,0)
end
-- 执行效果处理：若选择的破坏对象存在且成功破坏，则将选择的返回手牌对象送回手牌
function c50278554.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中要破坏的卡组
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	-- 获取当前连锁中要返回手牌的卡组
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
	-- 判断破坏对象是否有效并执行破坏操作
	if g1:GetFirst():IsRelateToEffect(e) and Duel.Destroy(g1,REASON_EFFECT)~=0 then
		local hg=g2:Filter(Card.IsRelateToEffect,nil,e)
		-- 将符合条件的返回手牌对象送回手牌
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
	end
end
-- 判断该卡被对方破坏送去墓地时是否满足特殊召唤条件
function c50278554.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 过滤满足条件的怪兽：名字带有「废铁」且不是同调怪兽，可以被特殊召唤
function c50278554.spfilter(c,e,tp)
	return c:IsSetCard(0x24) and not c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择函数，筛选自己墓地符合条件的怪兽
function c50278554.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50278554.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中满足条件的1只怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c50278554.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，记录将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果处理：若目标怪兽有效，则将其特殊召唤到场上
function c50278554.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中特殊召唤的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以指定方式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
