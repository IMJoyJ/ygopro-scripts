--森の聖霊 エーコ
-- 效果：
-- 对方的卡的效果让自己受到伤害时才能发动。这张卡从手卡特殊召唤，给与对方基本分和受到的伤害相同的伤害。并且，再让这个回合双方受到的效果伤害变成0。
function c4192696.initial_effect(c)
	-- 对方的卡的效果让自己受到伤害时才能发动。这张卡从手卡特殊召唤，给与对方基本分和受到的伤害相同的伤害。并且，再让这个回合双方受到的效果伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4192696,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(c4192696.spcon)
	e1:SetTarget(c4192696.sptg)
	e1:SetOperation(c4192696.spop)
	c:RegisterEffect(e1)
end
-- 诱发条件判定：本卡持有者（tp）是受到伤害的一方（ep==tp），造成伤害的是对方（rp==1-tp），且该伤害属于效果伤害（REASON_EFFECT），满足“对方的卡的效果让自己受到伤害”才能发动。
function c4192696.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and 1-tp==rp and bit.band(r,REASON_EFFECT)~=0
end
-- 效果发动时的合法检查：自己场上存在可用的主要怪兽区，且手卡中的这张卡能够被特殊召唤（满足召唤条件、苏生限制等）。
function c4192696.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有至少1个可用的主要怪兽区域，用来放置随后特殊召唤的这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的特殊召唤操作信息：要特殊召唤的对象就是这张卡，数量为1，使系统在发动时和后续处理中能识别这一行为。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置本次连锁的伤害操作信息：将对方（1-tp）作为伤害对象（targets为nil表示伤害不是针对卡片，而是对玩家），预定造成数值为ev的效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ev)
end
-- 效果处理流程：先从手卡将这张卡特殊召唤；若特殊召唤成功，则给予对方与之前受到的伤害数值相同的伤害，并在这个回合内让双方受到的效果伤害全部变成0。
function c4192696.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与本次效果保持关联（未被无效或离开合理区域），随后将其以表侧表示特殊召唤到我方场上；只有特殊召唤成功（返回值非0）时才继续处理后续效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 给予对方效果伤害，伤害数值等于本回合自己实际受到的伤害值ev，伤害原因是效果伤害（REASON_EFFECT）。
		Duel.Damage(1-tp,ev,REASON_EFFECT)
		-- 并且，再让这个回合双方受到的效果伤害变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,1)
		e1:SetValue(c4192696.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将改变伤害数值的效果（EFFECT_CHANGE_DAMAGE）注册到场上，使双方受到效果伤害时被damval函数改为0，该效果在结束阶段重置。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果伤害免疫标记（EFFECT_NO_EFFECT_DAMAGE）注册到场上，用于记录双方本回合已处于“效果伤害变成0”的状态，同样在结束阶段重置。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 伤害数值变更函数：若伤害的原因含有效果伤害（REASON_EFFECT），则把伤害数值改为0；否则保持原数值不变。
function c4192696.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end
