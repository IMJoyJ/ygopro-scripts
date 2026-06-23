--A BF－五月雨のソハヤ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
-- ②：这张卡同调召唤成功时，以自己墓地1只「强袭黑羽」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ③：这张卡被送去墓地的回合的自己主要阶段，从自己墓地把这张卡以外的1只「强袭黑羽-五月雨之骚速刀鸟」除外才能发动。这张卡特殊召唤。
function c53389254.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c53389254.tncon)
	e1:SetOperation(c53389254.tnop)
	c:RegisterEffect(e1)
	-- ②：这张卡同调召唤成功时，以自己墓地1只「强袭黑羽」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c53389254.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的回合的自己主要阶段，从自己墓地把这张卡以外的1只「强袭黑羽-五月雨之骚速刀鸟」除外才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53389254,0))  --"墓地怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,53389254)
	e3:SetCondition(c53389254.spcon1)
	e3:SetTarget(c53389254.sptg1)
	e3:SetOperation(c53389254.spop1)
	c:RegisterEffect(e3)
	-- 当同调召唤成功时，若使用了黑羽怪兽作为素材，则将此卡视为调整
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(53389254,1))  --"这张卡特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,53389255)
	e4:SetCondition(c53389254.spcon2)
	e4:SetCost(c53389254.spcost)
	e4:SetTarget(c53389254.sptg2)
	e4:SetOperation(c53389254.spop2)
	c:RegisterEffect(e4)
end
c53389254.treat_itself_tuner=true
-- 检查同调召唤所用的素材中是否包含黑羽怪兽，若有则标记为1，否则为0
function c53389254.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x33) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断是否为同调召唤且标记为1（即使用了黑羽怪兽作为素材）
function c53389254.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
-- 将此卡添加调整属性
function c53389254.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将此卡添加调整属性
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 判断是否为同调召唤
function c53389254.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的「强袭黑羽」怪兽，用于特殊召唤
function c53389254.spfilter(c,e,tp)
	return c:IsSetCard(0x1033) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标为己方墓地满足条件的怪兽
function c53389254.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c53389254.spfilter(chkc,e,tp) end
	-- 检查己方场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方墓地中是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c53389254.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c53389254.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c53389254.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为本回合被送去墓地且不是因返回场上的原因
function c53389254.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为本回合被送去墓地且不是因返回场上的原因
	return e:GetHandler():GetTurnID()==Duel.GetTurnCount() and not e:GetHandler():IsReason(REASON_RETURN)
end
-- 过滤满足条件的「强袭黑羽-五月雨之骚速刀鸟」怪兽，用于除外作为费用
function c53389254.costfilter(c)
	return c:IsCode(53389254) and c:IsAbleToRemoveAsCost()
end
-- 设置发动效果的费用为除外1只「强袭黑羽-五月雨之骚速刀鸟」
function c53389254.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方墓地中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c53389254.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标怪兽进行除外
	local g=Duel.SelectMatchingCard(tp,c53389254.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将目标怪兽除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果目标为特殊召唤自身
function c53389254.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c53389254.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
