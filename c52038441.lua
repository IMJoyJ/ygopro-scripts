--朔夜しぐれ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：对方把怪兽表侧表示特殊召唤的场合，把这张卡从手卡丢弃，以那些表侧表示怪兽之内的1只为对象才能发动。那只怪兽的效果直到回合结束时无效化，这个回合中作为对象的表侧表示怪兽从场上离开时那个控制者受到作为对象的怪兽的原本攻击力数值的伤害。
function c52038441.initial_effect(c)
	-- ①：对方把怪兽表侧表示特殊召唤的场合，把这张卡从手卡丢弃，以那些表侧表示怪兽之内的1只为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52038441,0))  --"特殊召唤的怪兽效果无效"
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+52038441)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,52038441)
	e1:SetCondition(c52038441.discon)
	e1:SetCost(c52038441.discost)
	e1:SetTarget(c52038441.distg)
	e1:SetOperation(c52038441.disop)
	c:RegisterEffect(e1)
	-- 注册一个合并延迟事件处理器，用于监听对方怪兽特殊召唤成功时的事件并触发自定义效果。
	aux.RegisterMergedDelayedEvent(c,52038441,EVENT_SPSUMMON_SUCCESS)
end
-- 筛选符合条件的对方表侧表示怪兽（必须是对方特殊召唤的、且能被无效化的怪兽或攻击力大于0的怪兽）。
function c52038441.cfilter(c,tp)
	-- 判断一个怪兽是否为对方特殊召唤的表侧表示怪兽，并且可以被该效果无效化或具有攻击力。
	return c:IsFaceup() and c:IsSummonPlayer(1-tp) and (aux.NegateMonsterFilter(c) or c:GetAttack()>0)
end
-- 当有符合条件的对方怪兽被特殊召唤时，满足此效果发动条件。
function c52038441.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c52038441.cfilter,1,nil,tp)
end
-- 支付将此卡从手牌丢弃作为发动代价。
function c52038441.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡从手牌送去墓地以支付发动代价。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 用于判断目标怪兽是否在可选对象集合中。
function c52038441.disfilter(c,g)
	return g:IsContains(c)
end
-- 选择一个符合条件的对方表侧表示怪兽作为效果对象。
function c52038441.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c52038441.cfilter,nil,tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c52038441.disfilter(chkc,g) end
	-- 检查是否存在符合条件的目标怪兽。
	if chk==0 then return Duel.IsExistingTarget(c52038441.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g) end
	if g:GetCount()==1 then
		-- 若只存在一个符合条件的怪兽，则直接设定为目标。
		Duel.SetTargetCard(g)
	else
		-- 提示玩家选择效果的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 从场上选择一个符合条件的对方表侧表示怪兽作为效果对象。
		Duel.SelectTarget(tp,c52038441.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
end
-- 处理效果发动后的操作，包括使目标怪兽效果无效和注册伤害触发条件。
function c52038441.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中设定的效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使与该怪兽相关的连锁效果无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果直到回合结束时无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果直到回合结束时无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(52038441,RESET_EVENT+RESET_TURN_SET+RESET_OVERLAY+RESET_MSCHANGE+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(52038441,1))  --"「朔夜时雨」效果适用中"
		-- 注册一个持续到回合结束的伤害触发效果，当目标怪兽离开场上的时候触发。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_LEAVE_FIELD)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetReset(RESET_PHASE+PHASE_END)
		e3:SetOperation(c52038441.damop)
		-- 将伤害触发效果注册到场上。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 处理目标怪兽离开场上时造成的伤害效果。
function c52038441.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not eg:IsContains(tc) then return end
	if tc:GetFlagEffectLabel(52038441)~=e:GetLabel() then
		e:Reset()
		return
	end
	-- 向所有玩家显示此卡发动的动画提示。
	Duel.Hint(HINT_CARD,0,52038441)
	-- 对目标怪兽的控制者造成其原本攻击力数值的伤害。
	Duel.Damage(tc:GetPreviousControler(),tc:GetBaseAttack(),REASON_EFFECT)
	tc:ResetFlagEffect(52038441)
	e:Reset()
end
