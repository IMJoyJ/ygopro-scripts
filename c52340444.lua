--閃刀機－ホーネットビット
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合才能发动。在自己场上把1只「闪刀姬衍生物」（战士族·暗·1星·攻/守0）守备表示特殊召唤。这衍生物不能解放。自己墓地有魔法卡3张以上存在的场合，那衍生物的攻击力·守备力变成1500。
function c52340444.initial_effect(c)
	-- 效果原文内容：①：自己的主要怪兽区域没有怪兽存在的场合才能发动。在自己场上把1只「闪刀姬衍生物」（战士族·暗·1星·攻/守0）守备表示特殊召唤。这衍生物不能解放。自己墓地有魔法卡3张以上存在的场合，那衍生物的攻击力·守备力变成1500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c52340444.condition)
	e1:SetTarget(c52340444.target)
	e1:SetOperation(c52340444.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查场上是否存在怪兽（序列号小于5表示主要怪兽区）
function c52340444.cfilter(c)
	return c:GetSequence()<5
end
-- 判断条件：自己的主要怪兽区域没有怪兽存在
function c52340444.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断自己场上是否没有怪兽
	return not Duel.IsExistingMatchingCard(c52340444.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：设置发动时的处理目标，包括特殊召唤衍生物和衍生物token
function c52340444.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=0
	-- 效果作用：检查自己墓地魔法卡数量是否大于等于3张
	if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
		atk=1500
	end
	-- 效果作用：检查自己场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断玩家是否可以特殊召唤指定编号的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,52340445,0,TYPES_TOKEN_MONSTER,atk,atk,1,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：衍生物token将被特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：衍生物将被特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果作用：执行发动效果时的具体处理流程
function c52340444.activate(e,tp,eg,ep,ev,re,r,rp)
	local atk=0
	-- 效果作用：检查自己墓地魔法卡数量是否大于等于3张
	if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
		atk=1500
	end
	-- 效果作用：检查场上是否有足够的空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 效果作用：判断是否可以特殊召唤衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,52340445,0,TYPES_TOKEN_MONSTER,atk,atk,1,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) then return end
	-- 创建一个编号为52340445的衍生物token
	local token=Duel.CreateToken(tp,52340445)
	-- 尝试将token特殊召唤到场上，若成功则继续设置其效果
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 效果原文内容：这衍生物不能解放。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		token:RegisterEffect(e2)
		-- 效果作用：检查自己墓地魔法卡数量是否大于等于3张
		if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
			-- 效果原文内容：自己墓地有魔法卡3张以上存在的场合，那衍生物的攻击力·守备力变成1500。
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_ATTACK)
			e3:SetValue(1500)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e3)
			local e4=e3:Clone()
			e4:SetCode(EFFECT_SET_DEFENSE)
			token:RegisterEffect(e4)
		end
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
