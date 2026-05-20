--ドラゴンダウザー
-- 效果：
-- 「小龙探物摆」的效果1回合只能使用1次。
-- ①：场上的这张卡被战斗或者对方的效果破坏送去墓地时才能发动。从卡组把1只地属性灵摆怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c76066541.initial_effect(c)
	-- ①：场上的这张卡被战斗或者对方的效果破坏送去墓地时才能发动。从卡组把1只地属性灵摆怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76066541,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,76066541)
	e1:SetCondition(c76066541.condition)
	e1:SetTarget(c76066541.target)
	e1:SetOperation(c76066541.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：此卡在场上被战斗破坏，或者因对方的效果破坏并送去墓地。
function c76066541.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE)
		or rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp))
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中可以守备表示特殊召唤的地属性灵摆怪兽。
function c76066541.filter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 检查怪兽区域是否有空位，以及卡组中是否存在符合条件的地属性灵摆怪兽，并设置特殊召唤的操作信息。
function c76066541.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只符合条件的地属性灵摆怪兽。
		and Duel.IsExistingMatchingCard(c76066541.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为“从卡组特殊召唤1只怪兽”。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只地属性灵摆怪兽守备表示特殊召唤，并注册在结束阶段将其破坏的效果。
function c76066541.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只符合条件的地属性灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c76066541.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功将选中的怪兽以表侧守备表示特殊召唤，则为其注册结束阶段破坏的效果。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(76066541,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c76066541.descon)
		e1:SetOperation(c76066541.desop)
		-- 注册全局延迟效果，用于在结束阶段破坏该特殊召唤的怪兽。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查被特殊召唤的怪兽是否仍在场上且标记未失效，若失效则重置该破坏效果。
function c76066541.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(76066541)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行破坏操作，将该特殊召唤的怪兽破坏。
function c76066541.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏该特殊召唤的怪兽。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
