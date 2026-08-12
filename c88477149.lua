--極寒の氷柱
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：在自己场上把2只「冰柱衍生物」（水族·水·4星·攻1900/守1200）守备表示特殊召唤。这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。进行1只水属性怪兽的召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（特招衍生物及额外特招限制）和②效果（墓地除外进行水属性召唤）
function s.initial_effect(c)
	-- ①：在自己场上把2只「冰柱衍生物」（水族·水·4星·攻1900/守1200）守备表示特殊召唤。这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。进行1只水属性怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"进行召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置效果②的发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
end
-- 效果①的发动检测与目标确认，检查是否能特殊召唤2只衍生物
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否能以守备表示特殊召唤特定属性、种族、攻守和等级的衍生物怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,1900,1200,4,RACE_AQUA,ATTRIBUTE_WATER,POS_FACEUP_DEFENSE) end
	-- 设置连锁处理的操作信息，表示该效果包含产生2只衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置连锁处理的操作信息，表示该效果包含特殊召唤2只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果①的实际处理函数，在自己场上特殊召唤2只「冰柱衍生物」，并适用不能从额外卡组特殊召唤的限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 在效果处理时，再次检查自己场上的主要怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 在效果处理时，再次检查玩家是否能特殊召唤该衍生物怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,1900,1200,4,RACE_AQUA,ATTRIBUTE_WATER,POS_FACEUP_DEFENSE) then
		for i=1,2 do
			-- 在虚拟空间中创建「冰柱衍生物」的卡片数据
			local token=Duel.CreateToken(tp,id+o)
			-- 将创建的衍生物以表侧守备表示放入特殊召唤的准备步骤
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
		-- 完成所有放入准备步骤的怪兽的特殊召唤处理
		Duel.SpecialSummonComplete()
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 向玩家注册该限制效果，使其在当前回合内生效
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制效果的过滤函数，指定不能特殊召唤的怪兽范围为额外卡组
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数，筛选手卡或场上可以进行通常召唤的水属性怪兽
function s.sumfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsSummonable(true,nil)
end
-- 效果②的发动检测与目标确认，检查是否存在可召唤的水属性怪兽并设置操作信息
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或自己场上是否存在至少1只满足召唤条件的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果包含进行1次召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果②的实际处理函数，让玩家选择1只水属性怪兽进行召唤
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端向玩家显示“请选择要召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手卡或自己场上选择1只满足召唤条件的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 让玩家无视每回合通常召唤次数限制，对选择的怪兽进行通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end
