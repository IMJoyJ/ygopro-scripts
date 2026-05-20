--エーリアンモナイト
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只4星以下的「外星」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c652362.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只4星以下的「外星」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(652362,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c652362.sptg)
	e1:SetOperation(c652362.spop)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中等级4以下且可以特殊召唤的「外星」怪兽
function c652362.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0xc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与目标选择判定
function c652362.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c652362.filter(chkc,e,tp) end
	-- 判定自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在满足条件的「外星」怪兽
		and Duel.IsExistingTarget(c652362.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「外星」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c652362.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表示该效果包含特殊召唤该目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理（特殊召唤目标怪兽，并注册结束阶段破坏的延迟效果）
function c652362.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍符合效果条件，则将其在自己场上表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(652362,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c652362.descon)
		e1:SetOperation(c652362.desop)
		-- 注册该全局延迟效果，用于在结束阶段执行破坏
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判定特殊召唤的怪兽是否仍在场且标记未失效，若失效则重置该效果
function c652362.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(652362)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏该怪兽的具体操作
function c652362.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏该特殊召唤的怪兽
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
