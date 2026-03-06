--腐乱犬
-- 效果：
-- 这张卡的攻击力在每次这张卡攻击宣言上升500。此外，场上的这张卡被破坏送去墓地的场合，可以从卡组把1只攻击力和守备力是0的1星怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，下次的自己的结束阶段时破坏。
function c27971137.initial_effect(c)
	-- 这张卡的攻击力在每次这张卡攻击宣言上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetOperation(c27971137.atkop)
	c:RegisterEffect(e1)
	-- 场上的这张卡被破坏送去墓地的场合，可以从卡组把1只攻击力和守备力是0的1星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27971137,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c27971137.spcon)
	e2:SetTarget(c27971137.sptg)
	e2:SetOperation(c27971137.spop)
	c:RegisterEffect(e2)
end
-- 攻击宣言时，使自身攻击力上升500。
function c27971137.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使自身攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 送去墓地时，满足条件则发动。
function c27971137.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤满足等级为1、攻击力为0、守备力为0且可特殊召唤的怪兽。
function c27971137.filter(c,e,tp)
	return c:IsLevel(1) and c:IsAttack(0) and c:IsDefense(0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 准备特殊召唤满足条件的怪兽。
function c27971137.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有特殊召唤空间。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c27971137.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理特殊召唤效果。
function c27971137.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有特殊召唤空间。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c27971137.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(27971137,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 使特殊召唤的怪兽效果无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的怪兽效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 设置下次自己的结束阶段时破坏该怪兽的效果。
		local de=Effect.CreateEffect(e:GetHandler())
		de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		de:SetCode(EVENT_PHASE+PHASE_END)
		de:SetCountLimit(1)
		de:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		de:SetLabelObject(tc)
		de:SetCondition(c27971137.descon)
		de:SetOperation(c27971137.desop)
		-- 判断是否为自己的结束阶段。
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_END then
			-- 记录当前回合数。
			de:SetLabel(Duel.GetTurnCount())
			de:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			de:SetLabel(0)
			de:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		end
		-- 注册破坏效果。
		Duel.RegisterEffect(de,tp)
	end
end
-- 判断是否为自己的结束阶段且未被处理。
function c27971137.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 满足结束阶段且未被处理的条件。
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(27971137)~=0
end
-- 破坏该怪兽。
function c27971137.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将该怪兽破坏。
	Duel.Destroy(tc,REASON_EFFECT)
end
