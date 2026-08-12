--月光虎
-- 效果：
-- ←5 【灵摆】 5→
-- ①：1回合1次，以自己墓地1只「月光」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽不能攻击，效果无效化，结束阶段破坏。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：场上的这张卡被战斗·效果破坏的场合，以自己墓地1只「月光」怪兽为对象才能发动。那只怪兽特殊召唤。
function c83190280.initial_effect(c)
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己墓地1只「月光」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽不能攻击，效果无效化，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c83190280.sptg)
	e1:SetOperation(c83190280.spop)
	c:RegisterEffect(e1)
	-- ①：场上的这张卡被战斗·效果破坏的场合，以自己墓地1只「月光」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,83190280)
	e2:SetCondition(c83190280.spcon2)
	e2:SetTarget(c83190280.sptg2)
	e2:SetOperation(c83190280.spop2)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地可以特殊召唤的「月光」怪兽
function c83190280.filter(c,e,tp)
	return c:IsSetCard(0xdf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 灵摆效果的发动条件与对象选择判定
function c83190280.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c83190280.filter(chkc,e,tp) end
	-- 检查自己墓地是否存在至少1只可以特殊召唤的「月光」怪兽
	if chk==0 then return Duel.IsExistingTarget(c83190280.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 并且检查自己的主要怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「月光」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c83190280.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤分类的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 灵摆效果的实际处理（特殊召唤目标怪兽，并施加不能攻击、效果无效化、结束阶段破坏的限制）
function c83190280.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合条件，则将其以表侧表示特殊召唤到场上（分步处理）
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local fid=c:GetFieldID()
		-- 效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 不能攻击
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		tc:RegisterFlagEffect(83190280,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 结束阶段破坏
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetCountLimit(1)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetLabel(fid)
		e4:SetLabelObject(tc)
		e4:SetCondition(c83190280.descon)
		e4:SetOperation(c83190280.desop)
		-- 注册在结束阶段将该怪兽破坏的全局延迟效果
		Duel.RegisterEffect(e4,tp)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 检查结束阶段时被特召的怪兽是否仍在场上且标记匹配，以决定是否触发破坏
function c83190280.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(83190280)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 执行结束阶段破坏该怪兽的操作
function c83190280.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 因效果将目标怪兽破坏
	Duel.Destroy(tc,REASON_EFFECT)
end
-- 检查怪兽效果的发动条件（场上的这张卡被战斗·效果破坏）
function c83190280.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 怪兽效果的发动条件与对象选择判定
function c83190280.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c83190280.filter(chkc,e,tp) end
	-- 检查自己的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在至少1只可以特殊召唤的「月光」怪兽
		and Duel.IsExistingTarget(c83190280.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「月光」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c83190280.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤分类的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 怪兽效果的实际处理（特殊召唤作为对象的怪兽）
function c83190280.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
