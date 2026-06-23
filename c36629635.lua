--ダンディ・ホワイトライオン
-- 效果：
-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不能从额外卡组把怪兽特殊召唤。
-- ①：这张卡从手卡·场上送去墓地的场合才能发动。在自己场上把3只「白绵毛衍生物」（植物族·风·1星·攻/守0）守备表示特殊召唤。
local s,id,o=GetID()
-- 注册蒲公英白狮的触发效果，该效果为单卡诱发效果，触发条件为卡片被送去墓地，且只能发动一次，同时设置效果描述、分类、处理函数等
function s.initial_effect(c)
	-- ①：这张卡从手卡·场上送去墓地的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在该回合是否已经发动过此卡效果，以实现“这个卡名的效果1回合只能使用1次”的限制
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，用于判断是否为从额外卡组召唤的怪兽，若不是则计数器加1
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA)
end
-- 判断该卡是否从手牌或场上被送去墓地，满足条件才能发动效果
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 设置发动效果的费用，检查是否为该回合第一次发动此卡效果，若不是则不能发动
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查该回合是否已经发动过此卡效果，若已发动则不能再次发动
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建一个影响玩家的永续效果，禁止玩家从额外卡组特殊召唤怪兽，持续到结束阶段
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 将上述创建的禁止特殊召唤效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 设置禁止从额外卡组特殊召唤的过滤函数，判断目标怪兽是否位于额外卡组
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 设置效果的目标函数，检查是否满足特殊召唤衍生物的条件，包括场地空位、是否受青眼精灵龙影响、是否可以特殊召唤衍生物
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的空位来特殊召唤3只衍生物
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=3
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,36629636,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_PLANT,ATTRIBUTE_WIND,POS_FACEUP_DEFENSE) end
	-- 设置操作信息，表示本次效果将特殊召唤3只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	-- 设置操作信息，表示本次效果将特殊召唤3只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
-- 设置效果的处理函数，检查是否满足特殊召唤衍生物的条件，包括场地空位、是否受青眼精灵龙影响
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的空位来特殊召唤3只衍生物
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 再次检查玩家是否可以特殊召唤指定的衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,36629636,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_PLANT,ATTRIBUTE_WIND,POS_FACEUP_DEFENSE) then return end
	for i=1,3 do
		-- 创建一张指定编号的衍生物卡片
		local token=Duel.CreateToken(tp,36629636)
		-- 将创建的衍生物特殊召唤到场上，守备表示
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 完成所有特殊召唤步骤，确保所有衍生物都已正确加入场上
	Duel.SpecialSummonComplete()
end
