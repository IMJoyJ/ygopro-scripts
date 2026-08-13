--ヴァレット・シンクロン
-- 效果：
-- ①：这张卡召唤时，以自己墓地1只5星以上的龙族·暗属性怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。
function c48355999.initial_effect(c)
	-- ①：这张卡召唤时，以自己墓地1只5星以上的龙族·暗属性怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48355999,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c48355999.sptg)
	e1:SetOperation(c48355999.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选自己墓地中等级5以上、暗属性、龙族且可以被表侧守备表示特殊召唤的怪兽。
function c48355999.spfilter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 取对象效果的发动条件判定：若为连锁处理中的对象确认，则检查对象是否是自己墓地符合条件的卡；若为发动条件确认，则检查自己场上是否有空位且墓地存在符合条件的对象。
function c48355999.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c48355999.spfilter(chkc,e,tp) end
	-- 发动条件之一：自己主要怪兽区有空余位置可用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：墓地存在1张满足spfilter过滤条件且能成为本效果对象的怪兽。
		and Duel.IsExistingTarget(c48355999.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，提示玩家从符合条件的墓地怪兽中选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只符合条件的怪兽，并设为效果对象（连锁处理时取得该对象）。
	local g=Duel.SelectTarget(tp,c48355999.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁将特殊召唤1只怪兽，用于给其他卡检测此效果类型（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取出对象怪兽，确认关联后以表侧守备表示进行特殊召唤；若成功，则为该怪兽附加效果无效化和结束阶段破坏的标记/效果，并将其登记到结束阶段的破坏处理中；最后完成特殊召唤，并给自己附加回合结束前不能从额外卡组特殊召唤非暗属性怪兽的自肃。
function c48355999.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本效果发动时选择的对象卡（目标）。这里只有一个目标，因此直接获取。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与本效果关联（未被重置），并以表侧守备表示将其特殊召唤（通过SpecialSummonStep分步处理，尚未实际落地）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		local fid=c:GetFieldID()
		-- 这个效果特殊召唤的怪兽的效果无效化（EFFECT_DISABLE：使该怪兽效果无效）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化（EFFECT_DISABLE_EFFECT：使其已适用的效果也被无效，离场后仍保留无效状态）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(48355999,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 结束阶段破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(c48355999.descon)
		e3:SetOperation(c48355999.desop)
		-- 将结束阶段破坏效果注册到场上，使已特殊召唤的怪兽在结束阶段由该效果破坏（并通过descon条件判定只处理本效果特殊召唤的怪兽）。
		Duel.RegisterEffect(e3,tp)
	end
	-- 完成分步特殊召唤的收尾处理，将之前SpecialSummonStep的怪兽真正特殊召唤到场上；若此前有步骤失败则整合结果。
	Duel.SpecialSummonComplete()
	-- 这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c48355999.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上（仅影响自己），直到回合结束阶段重置。
	Duel.RegisterEffect(e1,tp)
end
-- 破坏条件判定：仅当当前结束时登记的怪兽仍是本次特殊召唤的那只（通过FieldID标记确认）才执行破坏；若因标记不符说明该怪兽不再是本效果处理对象，则重置该结束阶段效果。
function c48355999.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(48355999)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 结束阶段对登记的怪兽执行破坏的处理函数。
function c48355999.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因将该怪兽破坏（实际执行结束阶段的破坏）。
	Duel.Destroy(tc,REASON_EFFECT)
end
-- 自肃过滤函数：当怪兽不是暗属性且位于额外卡组时，不允许从额外卡组特殊召唤。
function c48355999.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK) and c:IsLocation(LOCATION_EXTRA)
end
