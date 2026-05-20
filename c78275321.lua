--赤蟻アスカトル
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时，以自己墓地1只5星怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，这个回合的结束阶段送去墓地。
function c78275321.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时，以自己墓地1只5星怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，这个回合的结束阶段送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78275321,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c78275321.spcon)
	e1:SetTarget(c78275321.sptg)
	e1:SetOperation(c78275321.spop)
	c:RegisterEffect(e1)
end
-- 判定是否是被战斗破坏并送去墓地
function c78275321.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件：自己墓地中等级为5且可以特殊召唤的怪兽
function c78275321.filter(c,e,tp)
	return c:IsLevel(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与合法性检测
function c78275321.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c78275321.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的5星怪兽
		and Duel.IsExistingTarget(c78275321.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的5星怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c78275321.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选中的怪兽特殊召唤，并使其效果无效化，在结束阶段送去墓地
function c78275321.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关，则将其以表侧表示特殊召唤（分步处理）
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化，这个回合的结束阶段送去墓地。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(78275321,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 这个回合的结束阶段送去墓地。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(c78275321.descon)
		e3:SetOperation(c78275321.desop)
		e3:SetReset(RESET_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		-- 注册在结束阶段将该怪兽送去墓地的全局效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 检查结束阶段送去墓地效果的触发条件：该怪兽是否仍带有对应的标记
function c78275321.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(78275321)==e:GetLabel()
end
-- 执行结束阶段送去墓地的操作
function c78275321.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将目标怪兽送去墓地
	Duel.SendtoGrave(e:GetLabelObject(),REASON_EFFECT)
end
