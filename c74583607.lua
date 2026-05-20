--DDD烈火王テムジン
-- 效果：
-- 「DD」怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在怪兽区域存在的状态，自己场上有「DD」怪兽特殊召唤的场合，以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡被战斗或者对方的效果破坏的场合，以自己墓地1张「契约书」卡为对象才能发动。那张卡加入手卡。
function c74583607.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，需要2只「DD」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xaf),2,true)
	-- ①：这张卡在怪兽区域存在的状态，自己场上有「DD」怪兽特殊召唤的场合，以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,74583607)
	e1:SetCondition(c74583607.spcon)
	e1:SetTarget(c74583607.sptg)
	e1:SetOperation(c74583607.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗或者对方的效果破坏的场合，以自己墓地1张「契约书」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCondition(c74583607.thcon)
	e2:SetTarget(c74583607.thtg)
	e2:SetOperation(c74583607.thop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「DD」怪兽的条件函数
function c74583607.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsControler(tp)
end
-- 判定自己场上是否有「DD」怪兽特殊召唤（且不包含这张卡自身）的发动条件函数
function c74583607.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c74583607.cfilter,1,nil,tp)
end
-- 过滤墓地中可以特殊召唤的「DD」怪兽的条件函数
function c74583607.spfilter(c,e,tp)
	return c:IsSetCard(0xaf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与对象选择函数
function c74583607.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74583607.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「DD」怪兽
		and Duel.IsExistingTarget(c74583607.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「DD」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c74583607.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理函数（将作为对象的怪兽特殊召唤）
function c74583607.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判定这张卡是否被战斗或对方效果破坏的发动条件函数
function c74583607.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- 过滤墓地中可以加入手牌的「契约书」卡片的条件函数
function c74583607.thfilter(c)
	return c:IsSetCard(0xae) and c:IsAbleToHand()
end
-- 效果②的发动准备与对象选择函数
function c74583607.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74583607.thfilter(chkc) end
	-- 检查自己墓地是否存在可以加入手牌的「契约书」卡片
	if chk==0 then return Duel.IsExistingTarget(c74583607.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张「契约书」卡片作为效果对象
	local g=Duel.SelectTarget(tp,c74583607.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将选中的卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理函数（将作为对象的卡片加入手牌）
function c74583607.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
