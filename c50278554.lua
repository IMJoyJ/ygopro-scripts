--スクラップ・ツイン・ドラゴン
-- 效果：
-- 名字带有「废铁」的调整＋调整以外的怪兽1只以上
-- 1回合1次，选择自己场上存在的1张卡和对方场上存在的2张卡才能发动。选择的自己的卡破坏，选择的对方的卡回到手卡。这张卡被对方破坏送去墓地时，选择同调怪兽以外的自己墓地存在的1只名字带有「废铁」的怪兽特殊召唤。
function c50278554.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只名字带有「废铁」的调整怪兽加上1只以上调整以外的怪兽作为素材。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x24),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应效果原文：1回合1次，选择自己场上存在的1张卡和对方场上存在的2张卡才能发动。选择的自己的卡破坏，选择的对方的卡回到手卡。
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
	-- 对应效果原文：这张卡被对方破坏送去墓地时，选择同调怪兽以外的自己墓地存在的1只名字带有「废铁」的怪兽特殊召唤。
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
-- 目标选择函数：在连锁处理中不接受外部指定的对象（return false）；在发动时检查是否存在满足条件的对象（chk==0分支）。
function c50278554.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1张卡（任意卡）可以作为破坏对象。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否存在至少2张可以返回手卡的卡，以满足发动条件。
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 提示玩家选择要破坏的自己场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上的1张卡作为效果对象（用于破坏）。
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的破坏对象组的操作信息登记为破坏1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 提示玩家选择对方场上要返回手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上的2张可以返回手卡的卡作为效果对象（用于回手）。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,2,2,nil)
	-- 将选中的回手对象组的操作信息登记为回手2张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,2,0,0)
end
-- 效果处理：若自己选择的卡仍与效果关联且被成功破坏，则将对方选择的卡返回持有者手卡；否则不处理回手。
function c50278554.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出操作信息中登记的破坏对象组g1。
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	-- 取出操作信息中登记的回手对象组g2。
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
	-- 判断要破坏的卡是否仍与效果关联，并执行破坏；若破坏成功（返回数量不为0），继续后续回手处理。
	if g1:GetFirst():IsRelateToEffect(e) and Duel.Destroy(g1,REASON_EFFECT)~=0 then
		local hg=g2:Filter(Card.IsRelateToEffect,nil,e)
		-- 将对方选择的仍与效果关联的卡返回持有者手卡。
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
	end
end
-- 特殊召唤效果的触发条件：这张卡因被对方破坏而送去墓地，且破坏前控制者为自己。
function c50278554.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 特殊召唤对象过滤条件：必须是名字带有「废铁」的怪兽、不是同调怪兽，且能被效果特殊召唤。
function c50278554.spfilter(c,e,tp)
	return c:IsSetCard(0x24) and not c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤目标选择函数：发动时无条件可发动，从自己墓地的符合条件的「废铁」怪兽中选择1只作为对象。
function c50278554.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50278554.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的「废铁」怪兽作为效果对象，并登记为特殊召唤对象。
	local g=Duel.SelectTarget(tp,c50278554.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选中的特殊召唤对象组的操作信息登记为特殊召唤1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤处理：将选择的对象怪兽以表侧表示特殊召唤到自己场上。
function c50278554.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
