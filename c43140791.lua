--ワーム・ベイト
-- 效果：
-- 这张卡发动的回合，自己不能把3·4星的怪兽召唤·特殊召唤。
-- ①：自己场上有昆虫族怪兽存在的场合才能发动。在自己场上把2只「虫衍生物」（昆虫族·地·1星·攻/守0）特殊召唤。
function c43140791.initial_effect(c)
	-- ①：自己场上有昆虫族怪兽存在的场合才能发动。在自己场上把2只「虫衍生物」（昆虫族·地·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c43140791.condition)
	e1:SetCost(c43140791.cost)
	e1:SetTarget(c43140791.target)
	e1:SetOperation(c43140791.activate)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在该回合是否进行过召唤或特殊召唤操作，以限制3·4星怪兽的召唤·特殊召唤。
	Duel.AddCustomActivityCounter(43140791,ACTIVITY_SUMMON,c43140791.counterfilter)
	-- 设置一个计数器，用于记录玩家在该回合是否进行过特殊召唤操作，以限制3·4星怪兽的召唤·特殊召唤。
	Duel.AddCustomActivityCounter(43140791,ACTIVITY_SPSUMMON,c43140791.counterfilter)
end
-- 计数器过滤函数，用于判断卡片是否不是3星或4星怪兽。
function c43140791.counterfilter(c)
	return not c:IsLevel(3,4)
end
-- 过滤函数，用于判断场上是否有正面表示的昆虫族怪兽。
function c43140791.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 效果条件函数，判断自己场上有昆虫族怪兽存在。
function c43140791.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上有昆虫族怪兽存在。
	return Duel.IsExistingMatchingCard(c43140791.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果费用函数，检查该回合是否未进行过召唤或特殊召唤。
function c43140791.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查该回合是否未进行过召唤操作。
	if chk==0 then return Duel.GetCustomActivityCount(43140791,tp,ACTIVITY_SUMMON)==0
		-- 检查该回合是否未进行过特殊召唤操作。
		and Duel.GetCustomActivityCount(43140791,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册一个禁止特殊召唤3·4星怪兽的效果，同时复制一个禁止召唤3·4星怪兽的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c43140791.sumlimit)
	-- 将禁止特殊召唤3·4星怪兽的效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 将禁止召唤3·4星怪兽的效果注册给玩家。
	Duel.RegisterEffect(e2,tp)
end
-- 限制召唤或特殊召唤的怪兽等级为3或4星的函数。
function c43140791.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLevel(3,4)
end
-- 效果目标函数，检查是否满足发动条件，包括未受青眼精灵龙影响、场上空位足够、可以特殊召唤衍生物。
function c43140791.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有足够的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否可以特殊召唤衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,43140792,0x3e,TYPES_TOKEN_MONSTER,0,0,1,RACE_INSECT,ATTRIBUTE_EARTH) end
	-- 设置操作信息，表示将特殊召唤2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息，表示将特殊召唤2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果发动函数，检查是否满足发动条件并执行特殊召唤。
function c43140791.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上是否有足够的空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否可以特殊召唤衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,43140792,0x3e,TYPES_TOKEN_MONSTER,0,0,1,RACE_INSECT,ATTRIBUTE_EARTH) then
		for i=1,2 do
			-- 创建一只虫衍生物。
			local token=Duel.CreateToken(tp,43140792)
			-- 将虫衍生物特殊召唤到场上。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 完成特殊召唤流程。
		Duel.SpecialSummonComplete()
	end
end
