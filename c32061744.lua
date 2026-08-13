--エレキーパー
-- 效果：
-- 选择自己墓地存在的1只4星以下的名字带有「电气」的怪兽发动。选择的怪兽从墓地特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段时破坏。
function c32061744.initial_effect(c)
	-- 选择自己墓地存在的1只4星以下的名字带有「电气」的怪兽发动。选择的怪兽从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c32061744.target)
	e1:SetOperation(c32061744.activate)
	c:RegisterEffect(e1)
end
-- 定义可选择怪兽的筛选条件：等级4以下、名字带有「电气」字段、且能被当前效果特殊召唤的怪兽。
function c32061744.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0xe) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择处理：先校验指定对象是否满足条件，再检查自己场上是否有可用怪兽区以及墓地是否存在符合条件的对象。
function c32061744.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32061744.filter(chkc,e,tp) end
	-- 效果发动时判定自己场上是否至少有一个可用怪兽区域，以确保可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时判定墓地是否存在满足筛选条件且能成为效果对象的怪兽（至少1张）。
		and Duel.IsExistingTarget(c32061744.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示消息，引导选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的怪兽作为效果对象，并将其登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c32061744.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次连锁的操作信息设为特殊召唤分类，对象为已选择的怪兽组，数量为1，供后续时点检测和效果处理使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时的操作：若场上区域允许，则取得选择的目标怪兽；若目标仍与效果关联，则将其正面表示特殊召唤，成功后在怪兽身上留下本次特殊召唤的标识，并注册一个在结束阶段将该怪兽破坏的持续效果。
function c32061744.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己场上没有可用的怪兽区域，则直接终止处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽仍与效果有联系（未被移离等），然后以正面表示特殊召唤到自己的怪兽区域；若特殊召唤成功则继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(32061744,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 这个效果特殊召唤的怪兽在这个回合的结束阶段时破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c32061744.descon)
		e1:SetOperation(c32061744.desop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		-- 将结束阶段破坏怪兽的持续效果注册给当前玩家，使其在该回合的结束阶段生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断结束阶段是否要执行破坏：检查目标怪兽身上的特殊召唤标识是否与本次效果记录的标识一致，只有本次特殊召唤的怪兽才被破坏。
function c32061744.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(32061744)==e:GetLabel()
end
-- 结束阶段时，将记录的目标怪兽破坏的处理函数。
function c32061744.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将目标怪兽破坏。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
