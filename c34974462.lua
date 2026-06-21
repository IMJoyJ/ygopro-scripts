--幻奏の華楽聖ブルーム・ハーモニスト
-- 效果：
-- 天使族怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合，丢弃1张手卡才能发动。从卡组把2只等级不同的「幻奏」怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。这个效果发动的回合，自己不是「幻奏」怪兽不能特殊召唤。
-- ②：这张卡所连接区的「幻奏」怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
function c34974462.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：天使族怪兽2只
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
	-- 添加自定义活动计数器，用于检测本回合玩家进行特殊召唤的情况
	Duel.AddCustomActivityCounter(34974462,ACTIVITY_SPSUMMON,c34974462.counterfilter)
end
-- 活动计数器的过滤函数：检查特殊召唤的怪兽是否为表侧表示的「幻奏」怪兽
function c34974462.counterfilter(c)
	return c:IsSetCard(0x9b) and c:IsFaceup()
end
-- 效果①的发动条件：此卡是连接召唤成功
function c34974462.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的Cost判定：检查本回合是否未特殊召唤过非「幻奏」怪兽，且手牌中是否存在至少1张可以丢弃的卡
function c34974462.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定本回合是否没有进行过「幻奏」怪兽以外的特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(34974462,tp,ACTIVITY_SPSUMMON)==0
		-- 以及手牌中是否存在至少1张可以丢弃的卡
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- ①：这张卡连接召唤成功的场合，丢弃1张手卡才能发动。从卡组把2只等级不同的「幻奏」怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。这个效果发动的回合，自己不是「幻奏」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c34974462.splimit)
	-- 注册誓约限制：本回合自己不能特殊召唤「幻奏」以外的怪兽
	Duel.RegisterEffect(e1,tp)
	-- 丢弃1张手牌作为发动Cost
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤限制：不能特殊召唤「幻奏」以外的怪兽
function c34974462.splimit(e,c)
	return not c:IsSetCard(0x9b)
end
-- 过滤卡组中可用于特殊召唤到连接区且防守表示的「幻奏」怪兽
function c34974462.spfilter(c,e,tp,zone)
	return c:IsSetCard(0x9b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
-- 效果①的Target判定：检查是否不受青眼精灵龙效果限制，且自己连接区有2个以上的空位，且卡组中存在至少2只等级不同的「幻奏」怪兽
function c34974462.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	-- 获取这张卡所连接区的可用怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	-- 获取卡组中满足特殊召唤过滤条件的「幻奏」怪兽组
	local g=Duel.GetMatchingGroup(c34974462.spfilter,tp,LOCATION_DECK,0,nil,e,tp,zone)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and ft>1 and g:GetClassCount(Card.GetLevel)>=2 end
	-- 设置效果处理信息：从卡组特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择2只等级不同的「幻奏」怪兽，特殊召唤到此卡连接区的自己场上守备表示
function c34974462.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=bit.band(c:GetLinkedZone(tp),0x1f)
	-- 获取这张卡所连接区的可用怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	-- 获取卡组中满足特殊召唤过滤条件的「幻奏」怪兽组
	local g=Duel.GetMatchingGroup(c34974462.spfilter,tp,LOCATION_DECK,0,nil,e,tp,zone)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if c:IsRelateToEffect(e) and not Duel.IsPlayerAffectedByEffect(tp,59822133) and ft>1 and g:GetClassCount(Card.GetLevel)>=2 then
		-- 向玩家发送提示信息：选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从可特殊召唤的卡片中选出2只等级不同的怪兽
		local sg=g:SelectSubGroup(tp,aux.dlvcheck,false,2,2)
		if sg and sg:GetCount()==2 then
			-- 将选出的2只怪兽以守备表示特殊召唤到此卡的连接区
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone)
		end
	end
end
-- 过滤条件：表侧表示的「幻奏」怪兽
function c34974462.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b)
end
-- 效果②的生效条件：进行攻击的怪兽是此卡连接区的表侧表示「幻奏」怪兽
function c34974462.actcon(e)
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	return a and c34974462.cfilter(a) and e:GetHandler():GetLinkedGroup():IsContains(a)
end
