--旧神ノーデン
-- 效果：
-- 同调怪兽或超量怪兽＋同调怪兽或超量怪兽
-- ①：这张卡特殊召唤成功时，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽效果无效特殊召唤。这张卡从场上离开时那只怪兽除外。
function c17412721.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用满足ffilter条件的怪兽作为素材。
	aux.AddFusionProcFun2(c,c17412721.ffilter,c17412721.ffilter,true)
	-- ①：这张卡特殊召唤成功时，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽效果无效特殊召唤。这张卡从场上离开时那只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17412721,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,17412721)
	e1:SetCondition(c17412721.spcon)
	e1:SetTarget(c17412721.sptg)
	e1:SetOperation(c17412721.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功时，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽效果无效特殊召唤。这张卡从场上离开时那只怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c17412721.leave)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
c17412721.material_type=TYPE_SYNCHRO
-- 用于判断是否为同调或超量怪兽。
function c17412721.ffilter(c)
	return c:IsFusionType(TYPE_XYZ+TYPE_SYNCHRO)
end
-- 判断触发条件：当这张卡在额外怪兽区被特殊召唤时。
function c17412721.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 筛选墓地中4星以下的怪兽，且可以特殊召唤的怪兽。
function c17412721.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的目标选择条件和数量。
function c17412721.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c17412721.filter(chkc,e,tp) end
	-- 检查当前玩家的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否存在满足条件的卡片作为特殊召唤目标。
		and Duel.IsExistingTarget(c17412721.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，告知需要选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从符合筛选条件的卡片中选择一张作为特殊召唤的目标。
	local g=Duel.SelectTarget(tp,c17412721.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为特殊召唤，并指定目标卡和数量。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①：这张卡特殊召唤成功时，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽效果无效特殊召唤。这张卡从场上离开时那只怪兽除外。
function c17412721.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的第一个目标卡片。
	local tc=Duel.GetFirstTarget()
	-- 如果目标卡片与效果相关，并且成功执行了特殊召唤步骤，则进行后续处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- ①：这张卡特殊召唤成功时，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽效果无效特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- ①：这张卡特殊召唤成功时，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽效果无效特殊召唤。这张卡从场上离开时那只怪兽除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		if c:IsRelateToEffect(e) then
			c:SetCardTarget(tc)
			e:GetLabelObject():SetLabelObject(tc)
			c:CreateRelation(tc,RESET_EVENT+0x5020000)
			tc:CreateRelation(c,RESET_EVENT+0x5fe0000)
		end
	end
	-- 完成特殊召唤流程。
	Duel.SpecialSummonComplete()
end
-- 当这张卡离开场上时，执行相应的效果。
function c17412721.leave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc and c:IsRelateToCard(tc) and tc:IsRelateToCard(c) then
		-- 将目标怪兽以表侧表示形式从场上移除。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
