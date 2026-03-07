--幻奏の華楽聖ブルーム・ハーモニスト
-- 效果：
-- 天使族怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合，丢弃1张手卡才能发动。从卡组把2只等级不同的「幻奏」怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。这个效果发动的回合，自己不是「幻奏」怪兽不能特殊召唤。
-- ②：这张卡所连接区的「幻奏」怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
function c34974462.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2只满足条件的天使族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_FAIRY),2,2)
	-- ①：这张卡连接召唤成功的场合，丢弃1张手卡才能发动。从卡组把2只等级不同的「幻奏」怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。这个效果发动的回合，自己不是「幻奏」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34974462,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,34974462)
	e1:SetCondition(c34974462.spcon)
	e1:SetCost(c34974462.spcost)
	e1:SetTarget(c34974462.sptg)
	e1:SetOperation(c34974462.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区的「幻奏」怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c34974462.actcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 设置一个计数器，用于记录玩家在该回合中特殊召唤的「幻奏」怪兽数量
	Duel.AddCustomActivityCounter(34974462,ACTIVITY_SPSUMMON,c34974462.counterfilter)
end
-- 计数器过滤函数，判断卡片是否为「幻奏」卡组
function c34974462.counterfilter(c)
	return c:IsSetCard(0x9b)
end
-- 效果发动条件：确认此卡是以连接召唤方式特殊召唤成功
function c34974462.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果发动费用：检查是否为该回合第一次发动此效果且手牌中有可丢弃的卡
function c34974462.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否为该回合第一次发动此效果
	if chk==0 then return Duel.GetCustomActivityCount(34974462,tp,ACTIVITY_SPSUMMON)==0
		-- 检查手牌中是否存在可丢弃的卡
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 创建一个永续效果，使对方在本回合不能特殊召唤非「幻奏」怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c34974462.splimit)
	-- 将上述效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 令玩家丢弃1张手牌作为发动费用
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤限制效果的过滤函数，禁止非「幻奏」怪兽被特殊召唤
function c34974462.splimit(e,c)
	return not c:IsSetCard(0x9b)
end
-- 特殊召唤目标怪兽的过滤函数，筛选满足条件的「幻奏」怪兽
function c34974462.spfilter(c,e,tp,zone)
	return c:IsSetCard(0x9b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
-- 效果发动时的处理函数，用于判断是否满足特殊召唤条件
function c34974462.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	-- 获取玩家在指定区域的可用怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	-- 获取满足条件的「幻奏」怪兽组
	local g=Duel.GetMatchingGroup(c34974462.spfilter,tp,LOCATION_DECK,0,nil,e,tp,zone)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and ft>1 and g:GetClassCount(Card.GetLevel)>=2 end
	-- 设置连锁操作信息，表示将要特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，执行特殊召唤操作
function c34974462.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=bit.band(c:GetLinkedZone(tp),0x1f)
	-- 获取玩家在指定区域的可用怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	-- 获取满足条件的「幻奏」怪兽组
	local g=Duel.GetMatchingGroup(c34974462.spfilter,tp,LOCATION_DECK,0,nil,e,tp,zone)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if c:IsRelateToEffect(e) and not Duel.IsPlayerAffectedByEffect(tp,59822133) and ft>1 and g:GetClassCount(Card.GetLevel)>=2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从满足条件的怪兽组中选择2只等级不同的怪兽
		local sg=g:SelectSubGroup(tp,aux.dlvcheck,false,2,2)
		if sg and sg:GetCount()==2 then
			-- 将选中的怪兽以守备表示特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone)
		end
	end
end
-- 攻击怪兽的过滤函数，判断是否为「幻奏」怪兽且处于表侧表示
function c34974462.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b)
end
-- 效果发动条件：确认攻击怪兽为「幻奏」怪兽且在连接区中
function c34974462.actcon(e)
	-- 获取当前攻击的怪兽
	local a=Duel.GetAttacker()
	return a and c34974462.cfilter(a) and e:GetHandler():GetLinkedGroup():IsContains(a)
end
