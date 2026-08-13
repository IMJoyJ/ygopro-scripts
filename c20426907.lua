--機殻の再星
-- 效果：
-- ①：怪兽召唤·反转召唤时，那只怪兽是4星以下的场合把这个效果发动。那只怪兽的效果直到回合结束时无效。
-- ②：怪兽特殊召唤时，那怪兽是5星以上的场合把这个效果发动。那怪兽的效果直到回合结束时无效。那怪兽从场上离开的场合除外。
-- ③：场上没有「机壳的再星」以外的「机壳」卡存在的场合这张卡送去墓地。
function c20426907.initial_effect(c)
	-- 启用全局标记GLOBALFLAG_SELF_TOGRAVE，使本卡效果中不入连锁的自我送墓（③）能够被系统检测与处理。
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对应①效果原文：①：怪兽召唤·反转召唤时，那只怪兽是4星以下的场合把这个效果发动。那只怪兽的效果直到回合结束时无效。（此段代码实现通常召唤成功时的效果注册与处理）
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c20426907.distg1)
	e2:SetOperation(c20426907.disop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 对应②效果原文：②：怪兽特殊召唤时，那怪兽是5星以上的场合把这个效果发动。那怪兽的效果直到回合结束时无效。那怪兽从场上离开的场合除外。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(c20426907.distg2)
	e4:SetOperation(c20426907.disop2)
	c:RegisterEffect(e4)
	-- 对应③效果原文：③：场上没有「机壳的再星」以外的「机壳」卡存在的场合这张卡送去墓地。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_SELF_TOGRAVE)
	e5:SetCondition(c20426907.sdcon)
	c:RegisterEffect(e5)
end
-- ①效果的发动条件判定与取对象：怪兽通常召唤成功时，若该怪兽为4星以下（且本卡效果未启用时还要求不是通常怪兽），则将该怪兽设为效果对象，并登记无效效果的操作信息。
function c20426907.distg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local tc=eg:GetFirst()
		if e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then
			return tc:IsLevelBelow(4)
		else
			return tc:IsLevelBelow(4) and not tc:IsType(TYPE_NORMAL)
		end
	end
	-- 把召唤成功的怪兽组设为当前连锁的对象，使后续无效效果能锁定并作用于该怪兽。
	Duel.SetTargetCard(eg)
	-- 设置操作信息，声明本连锁将要执行CATEGORY_DISABLE（无效）操作，对象为eg，数量为1，供时点检测和连锁处理使用。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ①效果处理：取对象怪兽，若其表侧表示、仍与效果关联且可被无效，则将其关联的连锁无效化，并给它附加EFFECT_DISABLE和EFFECT_DISABLE_EFFECT，使那只怪兽的效果直到回合结束时无效。
function c20426907.disop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的第一张对象卡，即之前被设为对象的召唤成功怪兽，用于后续无效。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与该对象怪兽相关的已发动连锁全部无效化，并以变里侧表示（RESET_TURN_SET）作为该无效状态的解除重置条件。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 对应效果原文：那只怪兽的效果直到回合结束时无效。（通过EFFECT_DISABLE使怪兽效果无效）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 对应效果原文：那只怪兽的效果直到回合结束时无效。（通过EFFECT_DISABLE_EFFECT使其已经发动的效果无效化）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- ②效果的怪兽筛选条件：表侧表示且5星以上；若本卡效果适用中（activated为true）则不排除通常怪兽，否则还要排除通常怪兽（普通怪兽没有效果，无需无效）。
function c20426907.filter(c,activated)
	return c:IsFaceup() and c:IsLevelAbove(5) and (activated or not c:IsType(TYPE_NORMAL))
end
-- ②效果的发动条件判定与取对象：怪兽特殊召唤成功时，若存在符合filter的怪兽（表侧且5星以上等），则将全部符合条件的怪兽设为对象，并登记无效效果的操作信息。
function c20426907.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local activated=e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
	if chk==0 then return eg:IsExists(c20426907.filter,1,nil,activated) end
	local g=eg:Filter(c20426907.filter,nil,activated)
	-- 将筛选出的符合条件的特殊召唤怪兽组设为当前连锁的对象，使这些怪兽成为②效果的适用对象。
	Duel.SetTargetCard(g)
	-- 设置操作信息，声明本连锁将要执行CATEGORY_DISABLE（无效）操作，对象为g，数量为g中卡的数量，供时点检测和连锁处理使用。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- ②效果处理时的对象过滤：只保留表侧表示且仍与当前效果关联的怪兽，对已经离场或联系被重置的对象不再处理。
function c20426907.disfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- ②效果处理：从连锁对象中过滤出仍有效关联的怪兽，逐只进行：能无效的则无效其效果（EFFECT_DISABLE/EFFECT_DISABLE_EFFECT）直到回合结束，并给每只怪兽附加离场时除外（EFFECT_LEAVE_FIELD_REDIRECT）的效果。
function c20426907.disop2(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中取出之前登记的对象怪兽组，并用disfilter过滤出仍然表侧表示且与效果相关的怪兽，作为实际处理对象。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c20426907.disfilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		if tc:IsCanBeDisabledByEffect(e) then
			-- 将该对象怪兽已发动的相关连锁全部无效化，并以变里侧表示作为无效状态的解除重置条件。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 对应效果原文：那怪兽的效果直到回合结束时无效。（通过EFFECT_DISABLE使怪兽效果无效）
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 对应效果原文：那怪兽的效果直到回合结束时无效。（通过EFFECT_DISABLE_EFFECT使其已经发动的效果无效化）
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
		-- 对应效果原文：那怪兽从场上离开的场合除外。（通过EFFECT_LEAVE_FIELD_REDIRECT将离场去向改为除外）
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e3)
		tc=g:GetNext()
	end
end
-- ③效果的过滤器：检查场上是否存在表侧表示、属于「机壳」字段（0xaa）且不是本卡自身的卡；用于判断本卡是否应自我送墓。
function c20426907.sdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaa) and not c:IsCode(20426907)
end
-- ③效果的自毁条件：自己场上不存在其他表侧表示的「机壳」卡时，本卡因EFFECT_SELF_TOGRAVE效果送去墓地。
function c20426907.sdcon(e)
	-- 返回是否不存在其他表侧表示的「机壳」卡（即没有满足sdfilter的卡片）；为true时自我送墓条件成立。
	return not Duel.IsExistingMatchingCard(c20426907.sdfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
