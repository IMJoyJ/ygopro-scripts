--執愛のウヴァループ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，以自己的场上·墓地1只同调怪兽为对象才能发动。那只怪兽除外，这张卡特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只同调怪兽为对象才能发动。那只怪兽除外，这张卡加入手卡。
function c98806751.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以自己的场上·墓地1只同调怪兽为对象才能发动。那只怪兽除外，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98806751,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,98806751)
	e1:SetTarget(c98806751.sptg)
	e1:SetOperation(c98806751.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只同调怪兽为对象才能发动。那只怪兽除外，这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98806751,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,98806752)
	e2:SetTarget(c98806751.thtg)
	e2:SetOperation(c98806751.thop)
	c:RegisterEffect(e2)
end
-- 过滤满足特殊召唤效果的对象卡片（自己场上或墓地的同调怪兽，且能被除外，且除外后有可用的怪兽区域）
function c98806751.spfilter(c,tp)
	-- 判定卡片是否为同调怪兽、是否可以除外、是否在墓地或场上表侧表示存在，且该卡离开后能空出可用的怪兽区域
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemove() and Duel.GetMZoneCount(tp,c)>0 and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 特殊召唤效果的发动准备与目标选择
function c98806751.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and c98806751.spfilter(chkc,tp) end
	-- 判定自己场上或墓地是否存在可以作为除外对象的同调怪兽，且此卡可以特殊召唤
	if chk==0 then return Duel.IsExistingTarget(c98806751.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上或墓地的一只同调怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c98806751.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置效果处理信息：除外选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置效果处理信息：特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的执行
function c98806751.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的同调怪兽
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍适用效果，将其表侧表示除外，并确认其成功除外且此卡仍在手卡中
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) and c:IsRelateToEffect(e) then
		-- 将此卡表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤满足回收效果的对象卡片（自己场上或墓地的同调怪兽，且能被除外）
function c98806751.thfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemove() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 回收效果的发动准备与目标选择
function c98806751.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and c98806751.thfilter(chkc) end
	-- 判定自己场上或墓地是否存在可以作为除外对象的同调怪兽（排除自身），且此卡可以加入手卡
	if chk==0 then return Duel.IsExistingTarget(c98806751.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c)
		and c:IsAbleToHand() end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上或墓地的一只同调怪兽（排除自身）作为效果的对象
	local g=Duel.SelectTarget(tp,c98806751.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c)
	-- 设置效果处理信息：除外选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置效果处理信息：将此卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 回收效果的执行
function c98806751.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的同调怪兽
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍适用效果，将其表侧表示除外，并确认其成功除外且此卡仍在墓地中
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) and c:IsRelateToEffect(e) then
		-- 将此卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
