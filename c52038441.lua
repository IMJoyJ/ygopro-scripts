--朔夜しぐれ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：对方把怪兽表侧表示特殊召唤的场合，把这张卡从手卡丢弃，以那些表侧表示怪兽之内的1只为对象才能发动。那只怪兽的效果直到回合结束时无效化，这个回合中作为对象的表侧表示怪兽从场上离开时那个控制者受到作为对象的怪兽的原本攻击力数值的伤害。
function c52038441.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：对方把怪兽表侧表示特殊召唤的场合，把这张卡从手卡丢弃，以那些表侧表示怪兽之内的1只为对象才能发动。那只怪兽的效果直到回合结束时无效化，这个回合中作为对象的表侧表示怪兽从场上离开时那个控制者受到作为对象的怪兽的原本攻击力数值的伤害。
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
	-- 为这张卡注册一个合并延迟事件，将对方表侧表示特殊召唤怪兽成功的事件转换为自定义事件，并在同一连锁中合并同类触发，避免多次特殊召唤导致本卡效果被重复诱发；之后通过该自定义事件在合适时点统一发动本卡效果。
	aux.RegisterMergedDelayedEvent(c,52038441,EVENT_SPSUMMON_SUCCESS)
end
-- 条件筛选函数：判断这次特殊召唤的怪兽中，哪些是对方玩家表侧表示特殊召唤且可以作为本卡效果对象的怪兽。要求表侧表示、召唤玩家为对方，并且是未被无效的效果怪兽（或原本是效果怪兽）或攻击力大于0。
function c52038441.cfilter(c,tp)
	-- 具体判定：该怪兽表侧表示、由对方玩家特殊召唤，并且（属于可被无效效果的效果怪兽或攻击力大于0）时才纳入可选集合。
	return c:IsFaceup() and c:IsSummonPlayer(1-tp) and (aux.NegateMonsterFilter(c) or c:GetAttack()>0)
end
-- 发动条件判断：检查特殊召唤成功的怪兽组中是否存在至少1只满足条件的对方表侧表示特殊召唤怪兽；存在时才满足『对方把怪兽表侧表示特殊召唤的场合』的诱发条件。
function c52038441.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c52038441.cfilter,1,nil,tp)
end
-- 代价判断/执行：效果发动前必须把手卡中的这张卡丢弃；chk==0时确认这张卡可以丢弃，实际发动时将其作为代价送去墓地。
function c52038441.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 把这张卡从手卡送去墓地作为发动代价，同时标记为丢弃（REASON_DISCARD）和代价（REASON_COST）。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 对象筛选器：判断候选卡c是否属于本次特殊召唤成功且符合条件的那组怪兽g，用于限定只能选择这些怪兽中的1只作为对象。
function c52038441.disfilter(c,g)
	return g:IsContains(c)
end
-- 效果发动时的取对象处理：先取出本次符合条件的表侧表示特殊召唤怪兽集合g；若只有1只则直接将其设为对象，若有多只则提示玩家从中选择1只；同时完成取对象的合法性检查。
function c52038441.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c52038441.cfilter,nil,tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c52038441.disfilter(chkc,g) end
	-- 在效果发动的合法性检查阶段，确认场上存在至少1只可以从本次符合条件的特殊召唤怪兽集合g中选择为对象的怪兽；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c52038441.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g) end
	if g:GetCount()==1 then
		-- 当本次符合条件的怪兽只剩1只时，直接把那只怪兽设为本连锁的对象，无需玩家选择。
		Duel.SetTargetCard(g)
	else
		-- 向发动玩家显示『请选择效果的对象』的目标选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 让发动玩家从符合条件的怪兽集合g中选择1只表侧表示怪兽作为对象，并将它登记为当前连锁的对象卡。
		Duel.SelectTarget(tp,c52038441.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
end
-- 效果处理：取得对象怪兽并确认其仍与效果关联且表侧表示后，先将该对象怪兽相关连锁无效化，再给它赋予怪兽效果无效与效果无效化状态，并标记『朔夜时雨』适用中；然后注册一个持续效果，监听对象怪兽本回合内离开场上，以便触发伤害。
function c52038441.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽（通常只有1只）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将对象怪兽相关的连锁及其效果无效化，并指定在对象怪兽变里侧表示时重置该无效化状态，防止无效状态异常残留。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 『那只怪兽的效果直到回合结束时无效化。』（以EFFECT_DISABLE使对象怪兽的效果无效）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 『那只怪兽的效果直到回合结束时无效化。』（以EFFECT_DISABLE_EFFECT使对象怪兽已经适用的效果也被无效）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(52038441,RESET_EVENT+RESET_TURN_SET+RESET_OVERLAY+RESET_MSCHANGE+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(52038441,1))  --"「朔夜时雨」效果适用中"
		-- 『这个回合中作为对象的表侧表示怪兽从场上离开时那个控制者受到作为对象的怪兽的原本攻击力数值的伤害。』（注册离场监听，在对象怪兽离开场上时造成伤害）
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_LEAVE_FIELD)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetReset(RESET_PHASE+PHASE_END)
		e3:SetOperation(c52038441.damop)
		-- 把上述离场监听效果注册到场上，持续到结束阶段，用于在对象怪兽本回合离场时触发后续伤害。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 离场伤害处理函数：先从监听效果中取出对象怪兽；若本次离场怪兽不是该对象则忽略；若对象身上的朔夜时雨标记与本次标记不一致，说明已不是本效果适用对象，则重置监听；否则向对象怪兽离场前的控制者造成原本攻击力数值的伤害，清除标记并结束监听。
function c52038441.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not eg:IsContains(tc) then return end
	if tc:GetFlagEffectLabel(52038441)~=e:GetLabel() then
		e:Reset()
		return
	end
	-- 向双方展示『朔夜时雨』的卡片动画，宣告这是朔夜时雨造成的伤害效果。
	Duel.Hint(HINT_CARD,0,52038441)
	-- 对对象怪兽离场前的控制者造成该怪兽原本攻击力数值的效果伤害（伤害原因为效果）。
	Duel.Damage(tc:GetPreviousControler(),tc:GetBaseAttack(),REASON_EFFECT)
	tc:ResetFlagEffect(52038441)
	e:Reset()
end
