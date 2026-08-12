--機殻の再星
-- 效果：
-- ①：怪兽召唤·反转召唤时，那只怪兽是4星以下的场合把这个效果发动。那只怪兽的效果直到回合结束时无效。
-- ②：怪兽特殊召唤时，那怪兽是5星以上的场合把这个效果发动。那怪兽的效果直到回合结束时无效。那怪兽从场上离开的场合除外。
-- ③：场上没有「机壳的再星」以外的「机壳」卡存在的场合这张卡送去墓地。
function c20426907.initial_effect(c)
	-- 设置全局标记，用于检测自我送墓事件
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：怪兽召唤·反转召唤时，那只怪兽是4星以下的场合把这个效果发动。那只怪兽的效果直到回合结束时无效。
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
	-- ②：怪兽特殊召唤时，那怪兽是5星以上的场合把这个效果发动。那怪兽的效果直到回合结束时无效。那怪兽从场上离开的场合除外。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(c20426907.distg2)
	e4:SetOperation(c20426907.disop2)
	c:RegisterEffect(e4)
	-- ③：场上没有「机壳的再星」以外的「机壳」卡存在的场合这张卡送去墓地。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_SELF_TOGRAVE)
	e5:SetCondition(c20426907.sdcon)
	c:RegisterEffect(e5)
end
-- 判断触发效果的怪兽是否为4星或以下，若已激活则不考虑通常怪兽
function c20426907.distg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local tc=eg:GetFirst()
		if e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then
			return tc:IsLevelBelow(4)
		else
			return tc:IsLevelBelow(4) and not tc:IsType(TYPE_NORMAL)
		end
	end
	-- 设置连锁对象为触发召唤的怪兽
	Duel.SetTargetCard(eg)
	-- 设置操作信息为使怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 处理效果发动，使目标怪兽效果无效
function c20426907.disop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁对象中的第一个怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标怪兽相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 过滤函数，判断怪兽是否为5星或以上且满足条件
function c20426907.filter(c,activated)
	return c:IsFaceup() and c:IsLevelAbove(5) and (activated or not c:IsType(TYPE_NORMAL))
end
-- 判断触发效果的怪兽是否为5星或以上，若已激活则不考虑通常怪兽
function c20426907.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local activated=e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
	if chk==0 then return eg:IsExists(c20426907.filter,1,nil,activated) end
	local g=eg:Filter(c20426907.filter,nil,activated)
	-- 设置连锁对象为满足条件的怪兽组
	Duel.SetTargetCard(g)
	-- 设置操作信息为使怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 过滤函数，判断怪兽是否为表侧表示且与效果相关
function c20426907.disfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 处理效果发动，使目标怪兽效果无效并除外
function c20426907.disop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c20426907.disfilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		if tc:IsCanBeDisabledByEffect(e) then
			-- 使目标怪兽相关的连锁无效
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使目标怪兽效果无效
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使目标怪兽效果无效
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
		-- 使目标怪兽从场上离开时除外
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
-- 过滤函数，判断是否为「机壳」卡且不是本卡
function c20426907.sdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaa) and not c:IsCode(20426907)
end
-- 判断场上是否存在其他「机壳」卡
function c20426907.sdcon(e)
	-- 判断场上是否存在其他「机壳」卡
	return not Duel.IsExistingMatchingCard(c20426907.sdfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
