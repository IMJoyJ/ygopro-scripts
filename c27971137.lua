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
	-- 此外，场上的这张卡被破坏送去墓地的场合，可以从卡组把1只攻击力和守备力是0的1星怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，下次的自己的结束阶段时破坏。
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
-- 攻击宣言时，为自身施加攻击力上升500的效果，该效果持续到标准重置条件（离场、回手牌/卡组等）或效果无效时失效。
function c27971137.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的攻击力在每次这张卡攻击宣言上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 判定触发条件：此卡在场上被破坏并送去墓地，即满足“场上的这张卡被破坏送去墓地的场合”。
function c27971137.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 筛选卡组中满足“1星且攻击力和守备力都是0”并且可以被特殊召唤的怪兽。
function c27971137.filter(c,e,tp)
	return c:IsLevel(1) and c:IsAttack(0) and c:IsDefense(0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时进行合法性检查：自己主要怪兽区有空位，且卡组中存在至少1只符合条件的怪兽。
function c27971137.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件之一：自己主要怪兽区域存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：卡组中存在至少1只满足“1星且攻击力/守备力为0”并可被特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c27971137.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次连锁的特殊召唤操作信息：从卡组特殊召唤1只怪兽，以供后续效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选1只符合条件的怪兽以表侧表示特殊召唤，并对其附加效果无效化及下次自己的结束阶段破坏的持续效果。
function c27971137.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认：若自己主要怪兽区没有可用的空格，则不再进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示选择要特殊召唤的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择出1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c27971137.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(27971137,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 下次的自己的结束阶段时破坏。
		local de=Effect.CreateEffect(e:GetHandler())
		de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		de:SetCode(EVENT_PHASE+PHASE_END)
		de:SetCountLimit(1)
		de:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		de:SetLabelObject(tc)
		de:SetCondition(c27971137.descon)
		de:SetOperation(c27971137.desop)
		-- 如果当前已经处于自己的结束阶段，则需要把破坏时机推迟到下一个自己的结束阶段。
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_END then
			-- 记录当前的回合数，用于区分“下次的结束阶段”而不是当前这一次。
			de:SetLabel(Duel.GetTurnCount())
			de:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			de:SetLabel(0)
			de:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		end
		-- 将“结束阶段破坏”的持续效果注册到决斗中，使其在合适的结束阶段生效。
		Duel.RegisterEffect(de,tp)
	end
end
-- 判定是否满足破坏条件：轮到自己的结束阶段、且不是记录中的那个结束阶段、且被特殊召唤的怪兽仍然存在。
function c27971137.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 具体条件：当前回合玩家是自己、回合数不是记录值、怪兽仍带有本效果标记（未被其他方式无效/离场）。
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(27971137)~=0
end
-- 效果处理：破坏那只被特殊召唤的怪兽。
function c27971137.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因将那只怪兽破坏。
	Duel.Destroy(tc,REASON_EFFECT)
end
