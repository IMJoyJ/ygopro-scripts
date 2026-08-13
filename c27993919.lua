--ラドレミコード・エンジェリア
-- 效果：
-- ←3 【灵摆】 3→
-- ①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。自己场上1只「七音服」灵摆怪兽解放，比那只怪兽灵摆刻度高2或者低2的「拉之七音服·安琪莉娅」以外的1只「七音服」灵摆怪兽从卡组特殊召唤。
-- ②：自己的灵摆区域有奇数的灵摆刻度存在，自己的「七音服」灵摆怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡的效果不能发动。
function c27993919.initial_effect(c)
	-- 为这张卡附加灵摆怪兽的基本属性（灵摆刻度、灵摆召唤、可放置灵摆区域等），使其作为灵摆怪兽在规则上成立。
	aux.EnablePendulumAttribute(c)
	-- ←3 【灵摆】 3→①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c27993919.actcon1)
	e1:SetOperation(c27993919.actop1)
	c:RegisterEffect(e1)
	-- ←3 【灵摆】 3→①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetOperation(c27993919.subop)
	c:RegisterEffect(e2)
	-- 【怪兽效果】这个卡名的①的怪兽效果1回合只能使用1次。①：自己主要阶段才能发动。自己场上1只「七音服」灵摆怪兽解放，比那只怪兽灵摆刻度高2或者低2的「拉之七音服·安琪莉娅」以外的1只「七音服」灵摆怪兽从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27993919,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,27993919)
	e3:SetTarget(c27993919.sptg)
	e3:SetOperation(c27993919.spop)
	c:RegisterEffect(e3)
	-- ②：自己的灵摆区域有奇数的灵摆刻度存在，自己的「七音服」灵摆怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡的效果不能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetCondition(c27993919.actcon2)
	e4:SetValue(c27993919.actlimit2)
	c:RegisterEffect(e4)
end
-- 筛选出“自己场上表侧表示的、隶属「七音服」系列的、以灵摆召唤方式特殊召唤成功的灵摆怪兽”。
function c27993919.actfilter1(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 当特殊召唤成功的怪兽组中存在至少1只满足 actfilter1 的怪兽时，判定“自己的「七音服」灵摆怪兽灵摆召唤成功”的条件成立。
function c27993919.actcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27993919.actfilter1,1,nil,tp)
end
-- 处理灵摆效果①：在满足召唤成功条件后，根据当前连锁状态设置“对方不能发动怪兽效果·魔法·陷阱卡”的连锁限制。
function c27993919.actop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前连锁编号是否为0，即灵摆召唤成功没有处于连锁处理中。
	if Duel.GetCurrentChain()==0 then
		-- 设置直到连锁结束为止的连锁限制，限制对方不能发动怪兽效果·魔法·陷阱卡。
		Duel.SetChainLimitTillChainEnd(c27993919.chlimit)
	-- 若当前连锁编号为1，说明灵摆召唤成功处于连锁串中，需要先记录标记，在后续连锁处理中维持限制。
	elseif Duel.GetCurrentChain()==1 then
		c:RegisterFlagEffect(27993919,RESET_EVENT+RESETS_STANDARD,0,1)
		-- ←3 【灵摆】 3→①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。【怪兽效果】这个卡名的①的怪兽效果1回合只能使用1次。①：自己主要阶段才能发动。自己场上1只「七音服」灵摆怪兽解放，比那只怪兽灵摆刻度高2或者低2的「拉之七音服·安琪莉娅」以外的1只「七音服」灵摆怪兽从卡组特殊召唤。②：自己的灵摆区域有奇数的灵摆刻度存在，自己的「七音服」灵摆怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡的效果不能发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c27993919.resetop)
		-- 注册一个监听 EVENT_CHAINING 的临时效果，在下一个效果发动时执行 resetop，用于清除之前的标记。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册一个监听 EVENT_BREAK_EFFECT 且连锁结束时重置的临时效果，同样用于在效果处理中断时清除标记。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 清除该卡记录的 27993919 标记，并重置这个临时效果自身。
function c27993919.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:ResetFlagEffect(27993919)
	e:Reset()
end
-- 在连锁结束时，若该卡仍带有 27993919 标记，则补设直到连锁结束为止的连锁限制。
function c27993919.subop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(27993919)~=0 then
		-- 补设“对方不能发动怪兽效果·魔法·陷阱卡”的连锁限制直到连锁结束。
		Duel.SetChainLimitTillChainEnd(c27993919.chlimit)
	end
end
-- 连锁限制判定：己方发动的效果允许；对方发动的魔法·陷阱卡效果（不包括魔陷卡的卡的发动）被禁止，其他情况允许。
function c27993919.chlimit(e,ep,tp)
	return ep==tp or e:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 解放候选过滤：必须是「七音服」灵摆怪兽，且解放后自己场上仍有可用怪兽区，并且卡组中存在刻度差2的可特殊召唤目标。
function c27993919.cfilter(c,e,tp)
	-- 要求该候选卡是己方控制或表侧表示的卡，并确认将其解放后自己场上仍有可用的怪兽区。
	return (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
		and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM)
		-- 确认卡组中存在至少1只满足 spfilter 条件的「七音服」灵摆怪兽可被特殊召唤。
		and Duel.IsExistingMatchingCard(c27993919.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCurrentScale())
end
-- 特殊召唤目标过滤：必须是「七音服」灵摆怪兽，不能是卡名「拉之七音服·安琪莉娅」自身，且灵摆刻度与解放怪兽相差2，并满足特殊召唤条件。
function c27993919.spfilter(c,e,tp,sc)
	return c:IsSetCard(0x162) and c:IsType(TYPE_MONSTER) and not c:IsCode(27993919)
		and math.abs(c:GetCurrentScale()-sc)==2 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果①的发动与目标设定：检查能否解放1只符合条件的「七音服」灵摆怪兽，并设置从卡组特殊召唤1只怪兽的操作信息。
function c27993919.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查是否存在1只可解放的「七音服」灵摆怪兽作为发动代价。
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c27993919.cfilter,1,REASON_EFFECT,false,nil,e,tp) end
	-- 向系统声明本次效果处理将进行1只卡组怪兽的特殊召唤，用于连锁判定等。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理特殊召唤：先选择并解放1只「七音服」灵摆怪兽，再从卡组选择1只刻度差2的「七音服」灵摆怪兽特殊召唤。
function c27993919.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要解放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从符合条件的「七音服」灵摆怪兽中选择1只作为解放 cost。
	local g=Duel.SelectReleaseGroupEx(tp,c27993919.cfilter,1,1,REASON_EFFECT,false,nil,e,tp)
	-- 以效果原因解放选择的怪兽；若成功解放则继续特殊召唤处理。
	if Duel.Release(g,REASON_EFFECT)>0 then
		-- 弹出“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从卡组选择1只满足 spfilter 条件的「七音服」灵摆怪兽作为特殊召唤对象。
		local sg=Duel.SelectMatchingCard(tp,c27993919.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,g:GetFirst():GetCurrentScale())
		if sg:GetCount()>0 then
			-- 将选择的「七音服」灵摆怪兽以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 判断卡片的灵摆刻度是否为奇数，用于怪兽效果②的条件。
function c27993919.pfilter(c)
	return c:GetCurrentScale()%2~=0
end
-- 满足“自己的「七音服」灵摆怪兽攻击宣言”且“自己的灵摆区域存在奇数灵摆刻度”时，限制效果适用。
function c27993919.actcon2(e)
	-- 取得当前进行攻击宣言的怪兽。
	local a=Duel.GetAttacker()
	local tp=e:GetHandlerPlayer()
	return a and a:IsControler(tp) and a:IsSetCard(0x162)
		-- 检查己方灵摆区域是否存在至少1张灵摆刻度为奇数的灵摆卡。
		and Duel.IsExistingMatchingCard(c27993919.pfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- 限制对方不能发动魔法·陷阱卡的效果（即作为不能发动的对象类型为魔法·陷阱卡）。
function c27993919.actlimit2(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
