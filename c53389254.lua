--A BF－五月雨のソハヤ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
-- ②：这张卡同调召唤成功时，以自己墓地1只「强袭黑羽」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ③：这张卡被送去墓地的回合的自己主要阶段，从自己墓地把这张卡以外的1只「强袭黑羽-五月雨之骚速刀鸟」除外才能发动。这张卡特殊召唤。
function c53389254.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整怪兽加1只以上调整以外的怪兽作为素材。
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
	-- 「黑羽」怪兽为素材作同调召唤（用于判定①效果的素材条件）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c53389254.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：这张卡同调召唤成功时，以自己墓地1只「强袭黑羽」怪兽为对象才能发动。那只怪兽特殊召唤。
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
	-- ③：这张卡被送去墓地的回合的自己主要阶段，从自己墓地把这张卡以外的1只「强袭黑羽-五月雨之骚速刀鸟」除外才能发动。这张卡特殊召唤。
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
-- 检查同调召唤素材中是否存在「黑羽」怪兽，将判定结果（1或0）写入标签对象（e1）的Label，供①效果触发条件使用。
function c53389254.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x33) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- ①效果的触发条件：这张卡同调召唤成功，且素材中含有「黑羽」怪兽（Label为1）。
function c53389254.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
-- ①效果处理：给这张卡注册一个不可无效的永续效果，使其追加“调整”类型，并在离场等标准重置触发时失效。
function c53389254.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。（对应“当作调整使用”的追加调整类型处理）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- ②效果的发动条件：这张卡同调召唤成功时。
function c53389254.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 筛选可作为②效果对象的卡：必须是「强袭黑羽」（0x1033）字段的怪兽，且能够被当前效果特殊召唤。
function c53389254.spfilter(c,e,tp)
	return c:IsSetCard(0x1033) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标：确认自己墓地存在1张满足条件的「强袭黑羽」怪兽可作为对象，且自己场上有空位；chkc分支用于对象合法性检查。
function c53389254.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c53389254.spfilter(chkc,e,tp) end
	-- 检查己方主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1张满足spfilter的「强袭黑羽」怪兽可作为效果对象。
		and Duel.IsExistingTarget(c53389254.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地选择1张满足条件的「强袭黑羽」怪兽作为效果对象，并自动登记为当前连锁对象。
	local g=Duel.SelectTarget(tp,c53389254.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本连锁将进行特殊召唤，处理对象为刚才选中的那张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取得对象卡，若对象卡仍与效果有联系，则将其特殊召唤。
function c53389254.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第1张对象卡（本效果只选择1张）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到控制者的场上，不检查召唤条件和苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的发动条件：这张卡是本回合被送去墓地，且送墓原因不是“回到墓地”（REASON_RETURN）。
function c53389254.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认这张卡的送墓回合等于当前回合数，且送墓原因不是REASON_RETURN。
	return e:GetHandler():GetTurnID()==Duel.GetTurnCount() and not e:GetHandler():IsReason(REASON_RETURN)
end
-- 代价筛选条件：卡名必须为「强袭黑羽-五月雨之骚速刀鸟」（53389254），且可以被除外作为代价。
function c53389254.costfilter(c)
	return c:IsCode(53389254) and c:IsAbleToRemoveAsCost()
end
-- ③效果发动代价：确认墓地存在可除外的同名卡（排除自身），让玩家选择1张并将其表侧表示除外。
function c53389254.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在至少1张满足costfilter的同名卡（且调用时排除e:GetHandler()自身）可以作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c53389254.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地选择1张同名卡（排除自身）作为除外的代价。
	local g=Duel.SelectMatchingCard(tp,c53389254.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选择的卡从墓地以表侧表示除外，作为③效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ③效果发动目标：确认自己怪兽区有空位，且这张卡自身能够被当前效果特殊召唤。
function c53389254.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本连锁将把这张卡自身作为对象进行特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果处理：若这张卡仍与效果有联系，则将其特殊召唤。
function c53389254.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
