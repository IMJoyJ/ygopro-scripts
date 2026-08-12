--団結する剣闘獣
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不用「剑斗兽」怪兽不能攻击宣言。
-- ①：自己·对方的战斗阶段才能发动。从自己的手卡·场上·墓地让「剑斗兽」融合怪兽卡决定的融合素材怪兽回到持有者卡组，把那1只融合怪兽从额外卡组无视召唤条件特殊召唤。
function c66290900.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不用「剑斗兽」怪兽不能攻击宣言。①：自己·对方的战斗阶段才能发动。从自己的手卡·场上·墓地让「剑斗兽」融合怪兽卡决定的融合素材怪兽回到持有者卡组，把那1只融合怪兽从额外卡组无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,66290900+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c66290900.cost)
	e1:SetCondition(c66290900.condition)
	e1:SetTarget(c66290900.target)
	e1:SetOperation(c66290900.activate)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于记录本回合非「剑斗兽」怪兽进行攻击宣言的次数
	Duel.AddCustomActivityCounter(66290900,ACTIVITY_ATTACK,c66290900.counterfilter)
end
-- 计数器过滤函数：判断进行攻击宣言的怪兽是否为「剑斗兽」怪兽
function c66290900.counterfilter(c)
	return c:IsSetCard(0x1019)
end
-- 效果发动的Cost：检查本回合是否未用非「剑斗兽」怪兽进行过攻击宣言，并注册本回合自己不用「剑斗兽」怪兽不能攻击宣言的限制
function c66290900.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合自己是否未用非「剑斗兽」怪兽进行过攻击宣言
	if chk==0 then return Duel.GetCustomActivityCount(66290900,tp,ACTIVITY_ATTACK)==0 end
	-- 这张卡发动的回合，自己不用「剑斗兽」怪兽不能攻击宣言。①：自己·对方的战斗阶段才能发动。从自己的手卡·场上·墓地让「剑斗兽」融合怪兽卡决定的融合素材怪兽回到持有者卡组，把那1只融合怪兽从额外卡组无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c66290900.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册不能用非「剑斗兽」怪兽进行攻击宣言的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 攻击限制效果的目标过滤：非「剑斗兽」怪兽
function c66290900.atktg(e,c)
	return not c:IsSetCard(0x1019)
end
-- 效果发动的条件：自己或对方的战斗阶段
function c66290900.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 融合素材怪兽的过滤条件：可以回到卡组的怪兽，且不受该效果免疫
function c66290900.filter1(c,e)
	return c:IsAbleToDeck() and c:IsType(TYPE_MONSTER) and not c:IsImmuneToEffect(e)
end
-- 融合怪兽的过滤条件：额外卡组的「剑斗兽」融合怪兽，且能无视召唤条件特殊召唤，并能用给定的素材进行融合召唤
function c66290900.filter2(c,e,tp,m,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:CheckFusionMaterial(m,nil,chkf,true)
end
-- 效果发动的Target：检查额外卡组是否存在可特殊召唤的「剑斗兽」融合怪兽，并设置特殊召唤和回到卡组的操作信息
function c66290900.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp|0x200
		-- 获取自己手卡、场上、墓地中满足回到卡组条件的怪兽作为融合素材组
		local mg=Duel.GetMatchingGroup(c66290900.filter1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,nil,e)
		-- 检查额外卡组是否存在至少1只满足特殊召唤条件且能用上述素材进行融合召唤的「剑斗兽」融合怪兽
		return Duel.IsExistingMatchingCard(c66290900.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf)
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：将手卡、场上、墓地的融合素材怪兽回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE)
end
-- 确认卡片的过滤条件：处于手卡或场上里侧表示的卡
function c66290900.cffilter(c)
	return c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_MZONE) and c:IsFacedown())
end
-- 效果处理的Operation：选择并确认融合素材，将其回到卡组，然后从额外卡组无视召唤条件特殊召唤对应的「剑斗兽」融合怪兽
function c66290900.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp|0x200
	-- 获取自己手卡、场上、墓地中满足回到卡组条件且不受王家之谷影响的怪兽作为融合素材组
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c66290900.filter1),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,nil,e)
	-- 获取额外卡组中所有可以特殊召唤的「剑斗兽」融合怪兽
	local sg=Duel.GetMatchingGroup(c66290900.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,chkf)
	if sg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 让玩家选择所选融合怪兽决定的融合素材
		local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf,true)
		local cf=mat:Filter(c66290900.cffilter,nil)
		if cf:GetCount()>0 then
			-- 给对方玩家确认手卡中或场上里侧表示的融合素材
			Duel.ConfirmCards(1-tp,cf)
		end
		-- 将选中的融合素材怪兽回到持有者卡组并洗牌
		Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 中断当前效果，使后续的特殊召唤处理不与回到卡组同时进行
		Duel.BreakEffect()
		-- 将选中的融合怪兽从额外卡组无视召唤条件表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
