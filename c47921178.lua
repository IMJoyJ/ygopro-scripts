--BK チーフセコンド
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方怪兽的攻击宣言时，若自己场上有战士族怪兽或炎属性怪兽存在则能发动。这张卡从手卡特殊召唤，那次攻击无效。那之后，场上1只怪兽直到结束阶段除外。
-- ②：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「燃烧拳击手」怪兽召唤。
function c47921178.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：对方怪兽的攻击宣言时，若自己场上有战士族怪兽或炎属性怪兽存在则能发动。这张卡从手卡特殊召唤，那次攻击无效。那之后，场上1只怪兽直到结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47921178,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,47921178)
	e1:SetCondition(c47921178.spcon)
	e1:SetTarget(c47921178.sptg)
	e1:SetOperation(c47921178.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「燃烧拳击手」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47921178,1))  --"使用「燃烧拳击手 第一助手」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 设置该效果的目标为持有「燃烧拳击手」（0x1084）字段的怪兽，使这些怪兽在通常召唤之外可额外获得1次召唤机会。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1084))
	c:RegisterEffect(e2)
end
-- 效果①的发动条件检测：判断攻击宣言的怪兽是否由对手控制，以此满足“对方怪兽的攻击宣言时”。
function c47921178.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击怪兽的控制者不是自己，即对方怪兽进行的攻击宣言。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 定义辅助过滤器：用于检测自己场上是否存在表侧表示的战士族或炎属性怪兽，以判断“若自己场上有战士族怪兽或炎属性怪兽存在”。
function c47921178.cfilter(c)
	return c:IsFaceup() and (c:IsRace(RACE_WARRIOR) or c:IsAttribute(ATTRIBUTE_FIRE))
end
-- 效果①的目标检查：确认自己场上存在符合条件的怪兽、有可用怪兽区、本卡可特殊召唤、且场上存在可除外的怪兽，从而决定效果能否发动。
function c47921178.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有至少1张满足过滤条件的表侧表示怪兽（战士族/炎属性），对应发动条件“若自己场上有战士族怪兽或炎属性怪兽存在”。
	if chk==0 then return Duel.IsExistingMatchingCard(c47921178.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否有空余的主要怪兽区，确保可以从手卡特殊召唤这张卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查双方怪兽区域中是否有至少1只可以被除外的怪兽，使“场上1只怪兽直到结束阶段除外”拥有可能的对象。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 登记本效果包含特殊召唤操作，对象为本卡，数量为1；系统用此信息处理与特殊召唤相关的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 取得双方场上所有可除外的怪兽作为候选集合，供后续登记除外操作的可能对象。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 登记本效果包含除外操作，候选对象为上一步得到的所有可除外怪兽，数量为1（实际处理时选1只）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①实际处理：先确认本卡仍在连锁中并成功特殊召唤，若成功则无效那次攻击；随后让玩家选择场上1只怪兽暂时除外，并登记其在结束阶段返回。
function c47921178.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认本卡与当前连锁的关联有效，并将其从手牌以表侧表示特殊召唤到自己的怪兽区；特殊召唤成功是后续处理的前提。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 无效正在进行的攻击，只有特殊召唤成功后才执行；若攻击已被无效则返回false，不进行后续除外处理。
		and Duel.NegateAttack() then
		-- 弹出选择提示，告知玩家需要选择一张要除外的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 玩家从双方怪兽区域选择1只可以除外的怪兽，作为“场上1只怪兽”的处理对象（效果处理时选择，不取对象）。
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 中断当前效果处理，使后续操作被视为另一段处理，以准确处理时点和连锁顺序。
			Duel.BreakEffect()
			-- 以动画效果高亮显示被选中的卡，并将其标记为本效果的处理对象。
			Duel.HintSelection(g)
			-- 将选择的怪兽以效果原因暂时除外，若除外成功（返回值非0）则为它设置结束阶段返回的后续处理。
			if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
				tc:RegisterFlagEffect(47921178,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
				-- 那之后，场上1只怪兽直到结束阶段除外。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetLabelObject(tc)
				e1:SetCountLimit(1)
				e1:SetCondition(c47921178.retcon)
				e1:SetOperation(c47921178.retop)
				-- 将返回效果注册到系统，使被暂时除外的怪兽在结束阶段自动返回场上。
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
-- 返回效果的发动条件：检查被记录的那只怪兽仍持有除外标记，确保尚未被其他效果提前返回。
function c47921178.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(47921178)~=0
end
-- 返回效果的处理：把记录的被暂时除外的怪兽返回场上。
function c47921178.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂除的怪兽返回到其离场前的位置，实现“直到结束阶段除外”后的回归。
	Duel.ReturnToField(e:GetLabelObject())
end
