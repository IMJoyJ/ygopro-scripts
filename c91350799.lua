--マドルチェ・ホーットケーキ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以自己墓地1只怪兽为对象才能发动。那只怪兽除外，从卡组把「魔偶甜点·热香饼猫头鹰」以外的1只「魔偶甜点」怪兽特殊召唤。
-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
function c91350799.initial_effect(c)
	-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91350799,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c91350799.retcon)
	e1:SetTarget(c91350799.rettg)
	e1:SetOperation(c91350799.retop)
	c:RegisterEffect(e1)
	-- ①：以自己墓地1只怪兽为对象才能发动。那只怪兽除外，从卡组把「魔偶甜点·热香饼猫头鹰」以外的1只「魔偶甜点」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91350799,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,91350799)
	e2:SetTarget(c91350799.sptg)
	e2:SetOperation(c91350799.spop)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否被对方破坏并送去墓地，且原本由自己控制
function c91350799.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 2号效果（回到卡组）的发动准备与效果分类设置
function c91350799.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的操作信息为将自身送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 2号效果（回到卡组）的效果处理
function c91350799.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身送回卡组并洗牌
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤自己墓地中可以除外的怪兽卡
function c91350799.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 过滤卡组中除「魔偶甜点·热香饼猫头鹰」以外的「魔偶甜点」怪兽
function c91350799.filter(c,e,tp)
	return c:IsSetCard(0x71) and not c:IsCode(91350799) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 1号效果（特殊召唤）的发动准备与对象选择
function c91350799.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c91350799.rmfilter(chkc) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以作为对象除外的怪兽
		and Duel.IsExistingTarget(c91350799.rmfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查卡组中是否存在可以特殊召唤的「魔偶甜点」怪兽
		and Duel.IsExistingMatchingCard(c91350799.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c91350799.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理的操作信息为除外目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
	-- 设置连锁处理的操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 1号效果（特殊召唤）的效果处理
function c91350799.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果对象怪兽存在且仍适用，则将其表侧表示除外，若除外成功则继续处理
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		-- 检查自己场上是否有可用的怪兽区域，若无则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只符合条件的「魔偶甜点」怪兽
		local g=Duel.SelectMatchingCard(tp,c91350799.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
