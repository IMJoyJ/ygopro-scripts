--旧神ノーデン
-- 效果：
-- 同调怪兽或超量怪兽＋同调怪兽或超量怪兽
-- ①：这张卡特殊召唤成功时，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽效果无效特殊召唤。这张卡从场上离开时那只怪兽除外。
function c17412721.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足条件的两个同类型怪兽作为融合素材
	aux.AddFusionProcFun2(c,c17412721.ffilter,c17412721.ffilter,true)
	-- ①：这张卡特殊召唤成功时，以自己墓地1只4星以下的怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17412721,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c17412721.sptg)
	e1:SetOperation(c17412721.spop)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c17412721.leave)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
c17412721.material_type=TYPE_SYNCHRO
-- 过滤器函数，用于筛选超量或同调类型的怪兽作为融合素材
function c17412721.ffilter(c)
	return c:IsFusionType(TYPE_XYZ+TYPE_SYNCHRO)
end
-- 过滤器函数，用于筛选4星以下且可以特殊召唤的怪兽
function c17412721.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，选择墓地符合条件的怪兽作为对象
function c17412721.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c17412721.filter(chkc,e,tp) end
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否在墓地存在符合条件的怪兽
		and Duel.IsExistingTarget(c17412721.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽并设置为效果对象
	local g=Duel.SelectTarget(tp,c17412721.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的执行过程，将目标怪兽特殊召唤并施加效果
function c17412721.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效并执行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 创建效果使目标怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 创建效果使目标怪兽效果在回合结束时无效
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
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 处理卡片离开场上的效果，将目标怪兽除外
function c17412721.leave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc and c:IsRelateToCard(tc) and tc:IsRelateToCard(c) then
		-- 将目标怪兽以效果原因除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
