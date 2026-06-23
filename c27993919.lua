--ラドレミコード・エンジェリア
-- 效果：
-- ←3 【灵摆】 3→
-- ①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。自己场上1只「七音服」灵摆怪兽解放，比那只怪兽灵摆刻度高2或者低2的「拉之七音服·安琪莉娅」以外的1只「七音服」灵摆怪兽从卡组特殊召唤。
-- ②：自己的灵摆区域有奇数的灵摆刻度存在，自己的「七音服」灵摆怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡的效果不能发动。
function c27993919.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c27993919.actcon1)
	e1:SetOperation(c27993919.actop1)
	c:RegisterEffect(e1)
	-- ②：自己的灵摆区域有奇数的灵摆刻度存在，自己的「七音服」灵摆怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetOperation(c27993919.subop)
	c:RegisterEffect(e2)
	-- ①：自己主要阶段才能发动。自己场上1只「七音服」灵摆怪兽解放，比那只怪兽灵摆刻度高2或者低2的「拉之七音服·安琪莉娅」以外的1只「七音服」灵摆怪兽从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27993919,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,27993919)
	e3:SetTarget(c27993919.sptg)
	e3:SetOperation(c27993919.spop)
	c:RegisterEffect(e3)
	-- 这个卡名的①的怪兽效果1回合只能使用1次。
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
-- 过滤函数，用于判断是否为己方场上满足条件的灵摆怪兽（灵摆召唤成功）
function c27993919.actfilter1(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 判断是否有己方灵摆怪兽成功灵摆召唤
function c27993919.actcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27993919.actfilter1,1,nil,tp)
end
-- 当有己方灵摆怪兽成功灵摆召唤时，设置连锁限制条件
function c27993919.actop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果当前连锁为0，则设置连锁限制
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁限制，防止对方在连锁中发动魔法或陷阱卡
		Duel.SetChainLimitTillChainEnd(c27993919.chlimit)
	-- 如果当前连锁为1，则注册连锁重置效果
	elseif Duel.GetCurrentChain()==1 then
		c:RegisterFlagEffect(27993919,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 注册EVENT_CHAINING事件效果，用于在连锁中重置flag
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c27993919.resetop)
		-- 将效果e1注册给玩家tp
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 将效果e2注册给玩家tp
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置flag效果并清除效果e
function c27993919.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:ResetFlagEffect(27993919)
	e:Reset()
end
-- 当连锁结束时，如果flag存在则设置连锁限制
function c27993919.subop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(27993919)~=0 then
		-- 设置连锁限制，防止对方在连锁中发动魔法或陷阱卡
		Duel.SetChainLimitTillChainEnd(c27993919.chlimit)
	end
end
-- 连锁限制函数，用于判断是否允许发动魔法或陷阱卡
function c27993919.chlimit(e,ep,tp)
	return ep==tp or e:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 过滤函数，用于判断是否可以解放的「七音服」灵摆怪兽
function c27993919.cfilter(c,e,tp)
	-- 判断该灵摆怪兽是否满足解放条件（在己方场上或表侧表示）
	return (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
		and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM)
		-- 判断是否在卡组中存在满足条件的「七音服」灵摆怪兽可特殊召唤
		and Duel.IsExistingMatchingCard(c27993919.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCurrentScale())
end
-- 过滤函数，用于判断是否为满足条件的「七音服」灵摆怪兽
function c27993919.spfilter(c,e,tp,sc)
	return c:IsSetCard(0x162) and c:IsType(TYPE_MONSTER) and not c:IsCode(27993919)
		and math.abs(c:GetCurrentScale()-sc)==2 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标和信息
function c27993919.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的条件
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c27993919.cfilter,1,REASON_EFFECT,false,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作
function c27993919.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的灵摆怪兽进行解放
	local g=Duel.SelectReleaseGroupEx(tp,c27993919.cfilter,1,1,REASON_EFFECT,false,nil,e,tp)
	-- 判断是否成功解放
	if Duel.Release(g,REASON_EFFECT)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的灵摆怪兽进行特殊召唤
		local sg=Duel.SelectMatchingCard(tp,c27993919.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,g:GetFirst():GetCurrentScale())
		if sg:GetCount()>0 then
			-- 将选中的灵摆怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤函数，用于判断灵摆刻度是否为奇数
function c27993919.pfilter(c)
	return c:GetCurrentScale()%2~=0
end
-- 判断是否满足发动②效果的条件
function c27993919.actcon2(e)
	-- 获取当前攻击的怪兽
	local a=Duel.GetAttacker()
	local tp=e:GetHandlerPlayer()
	return a and a:IsControler(tp) and a:IsSetCard(0x162)
		-- 判断己方灵摆区域是否存在奇数刻度
		and Duel.IsExistingMatchingCard(c27993919.pfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- 限制对方发动魔法或陷阱卡的效果函数
function c27993919.actlimit2(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
