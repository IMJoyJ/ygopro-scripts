--閃刀機－ホーネットビット
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合才能发动。在自己场上把1只「闪刀姬衍生物」（战士族·暗·1星·攻/守0）守备表示特殊召唤。这衍生物不能解放。自己墓地有魔法卡3张以上存在的场合，那衍生物的攻击力·守备力变成1500。
function c52340444.initial_effect(c)
	-- ①：自己的主要怪兽区域没有怪兽存在的场合才能发动。在自己场上把1只「闪刀姬衍生物」（战士族·暗·1星·攻/守0）守备表示特殊召唤。这衍生物不能解放。自己墓地有魔法卡3张以上存在的场合，那衍生物的攻击力·守备力变成1500。
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
-- 过滤函数，用于判断卡是否位于主要怪兽区域：怪兽区域中主要怪兽区域（1-5号区域）的编号小于5，返回true。
function c52340444.cfilter(c)
	return c:GetSequence()<5
end
-- 发动条件：自己的主要怪兽区域不存在任何怪兽（即没有满足cfilter条件的卡）。
function c52340444.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区域是否存在满足cfilter条件的怪兽，若不存在则返回true，满足发动条件。
	return not Duel.IsExistingMatchingCard(c52340444.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的目标处理和合法性检查：计算衍生物攻击力/守备力（墓地魔法卡≥3则为1500），确认主要怪兽区域有空位且玩家可以特殊召唤该衍生物，并设置效果操作信息。
function c52340444.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=0
	-- 统计自己墓地的魔法卡数量，若达到3张或以上，则将本次衍生物的攻击力/守备力参数设为1500。
	if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
		atk=1500
	end
	-- 发动合法性判定：当前主要怪兽区域是否有空余格子可供特殊召唤衍生物。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且玩家能否以表侧守备表示、1星、战士族、暗属性、攻/守为atk的衍生物参数进行特殊召唤（即满足衍生物生成条件）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,52340445,0,TYPES_TOKEN_MONSTER,atk,atk,1,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：本次效果将生成1只衍生物（CATEGORY_TOKEN），用于连锁处理后确认衍生物的生成。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次效果包含特殊召唤（CATEGORY_SPECIAL_SUMMON），将特殊召唤1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理时的实际操作：再次确认条件后，生成「闪刀姬衍生物」并特殊召唤，同时根据墓地魔法卡数量决定是否赋予其1500攻击力/守备力，以及赋予不能解放的效果。
function c52340444.activate(e,tp,eg,ep,ev,re,r,rp)
	local atk=0
	-- 效果处理时再次统计自己墓地的魔法卡数量，若≥3则本次衍生物的攻击力/守备力参数为1500。
	if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
		atk=1500
	end
	-- 若自己主要怪兽区域没有空余格子（空位≤0），则无法特殊召唤衍生物，效果处理中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 若玩家此时无法特殊召唤该衍生物（不满足特殊召唤条件），则效果处理中止。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,52340445,0,TYPES_TOKEN_MONSTER,atk,atk,1,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) then return end
	-- 创建1只「闪刀姬衍生物」（code=52340445），用于接下来的特殊召唤步骤。
	local token=Duel.CreateToken(tp,52340445)
	-- 将衍生物以表侧守备表示加入特殊召唤流程（Duel.SpecialSummonStep），如果成功则继续为它赋予其他效果。
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这衍生物不能解放。（此处设置衍生物不能作为上级召唤的祭品）
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
		-- 效果处理中再次确认墓地魔法卡数量是否≥3，用于决定是否改变衍生物的攻击力和守备力。
		if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
			-- 那衍生物的攻击力·守备力变成1500。（此处先设置攻击力为1500）
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
	-- 完成所有特殊召唤步骤，正式将衍生物特殊召唤到场上，并处理特殊召唤成功的相关时点。
	Duel.SpecialSummonComplete()
end
