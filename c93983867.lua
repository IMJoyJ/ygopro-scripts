--トリック・ボックス
-- 效果：
-- ①：自己场上的「娱乐法师」怪兽被战斗·效果破坏送去墓地的场合，以对方场上1只怪兽为对象才能发动。自己直到结束阶段得到那只怪兽的控制权。那之后，选自己墓地1只「娱乐法师」怪兽在对方场上特殊召唤。这个回合的结束阶段，这个效果特殊召唤的怪兽的控制权回归原本持有者。
function c93983867.initial_effect(c)
	-- 开启全局洗脑解除（控制权回归）检查标记
	Duel.EnableGlobalFlag(GLOBALFLAG_BRAINWASHING_CHECK)
	-- ①：自己场上的「娱乐法师」怪兽被战斗·效果破坏送去墓地的场合，以对方场上1只怪兽为对象才能发动。自己直到结束阶段得到那只怪兽的控制权。那之后，选自己墓地1只「娱乐法师」怪兽在对方场上特殊召唤。这个回合的结束阶段，这个效果特殊召唤的怪兽的控制权回归原本持有者。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c93983867.condition)
	e1:SetTarget(c93983867.target)
	e1:SetOperation(c93983867.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「娱乐法师」怪兽被破坏送去墓地
function c93983867.cfilter(c,tp)
	return c:IsSetCard(0xc6) and c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 发动条件：存在满足过滤条件的被破坏送去墓地的怪兽
function c93983867.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c93983867.cfilter,1,nil,tp)
end
-- 过滤条件：墓地中可以特殊召唤的「娱乐法师」怪兽
function c93983867.spfilter(c,e,tp)
	return c:IsSetCard(0xc6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与可行性检查
function c93983867.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 检查对方场上是否存在可以改变控制权的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil)
		-- 并且自己墓地存在可以特殊召唤的「娱乐法师」怪兽
		and Duel.IsExistingMatchingCard(c93983867.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只可以改变控制权的怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：改变该怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 设置当前连锁的操作信息为：从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理的完整逻辑
function c93983867.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的那只对方怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 尝试直到结束阶段得到该怪兽的控制权，若成功则继续处理
	if Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
		-- 中断当前效果，使后续的特殊召唤处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择自己墓地1只「娱乐法师」怪兽
		local g=Duel.SelectMatchingCard(tp,c93983867.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 将选中的怪兽在对方场上表侧表示特殊召唤，并注册相关效果
		if tc and Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)~=0 then
			tc:RegisterFlagEffect(93983867,RESET_EVENT+RESETS_STANDARD,0,1)
			-- 这个回合的结束阶段，这个效果特殊召唤的怪兽的控制权回归原本持有者。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCountLimit(1)
			e1:SetLabelObject(tc)
			e1:SetCondition(c93983867.retcon)
			e1:SetOperation(c93983867.retop)
			-- 注册在结束阶段触发的全局效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 检查特殊召唤的怪兽是否仍带有标记，若无则重置该效果
function c93983867.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(93983867)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 结束阶段时，注册使控制权回归原本持有者的效果，并注册一个调整事件来重置该效果
function c93983867.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 这个回合的结束阶段，这个效果特殊召唤的怪兽的控制权回归原本持有者。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REMOVE_BRAINWASHING)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetLabelObject(tc)
	e1:SetTarget(c93983867.rettg)
	-- 注册解除洗脑（控制权回归）的全局效果
	Duel.RegisterEffect(e1,tp)
	-- 这个回合的结束阶段，这个效果特殊召唤的怪兽的控制权回归原本持有者。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetLabelObject(e1)
	e2:SetOperation(c93983867.reset)
	-- 注册用于在控制权回归后重置相关效果的调整事件
	Duel.RegisterEffect(e2,tp)
end
-- 过滤需要回归控制权的怪兽（即带有特定标记的该怪兽）
function c93983867.rettg(e,c)
	return c==e:GetLabelObject() and c:GetFlagEffect(93983867)~=0
end
-- 清除怪兽的标记并重置控制权回归效果
function c93983867.reset(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	local tc=e1:GetLabelObject()
	tc:ResetFlagEffect(93983867)
	e1:Reset()
	e:Reset()
end
