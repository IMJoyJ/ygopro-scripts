--帝王の烈旋
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能从额外卡组把怪兽特殊召唤。
-- ①：这个回合，自己把怪兽上级召唤的场合只有1次，可以作为自己场上1只怪兽的代替而把对方场上1只怪兽解放。
function c79844764.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能从额外卡组把怪兽特殊召唤。①：这个回合，自己把怪兽上级召唤的场合只有1次，可以作为自己场上1只怪兽的代替而把对方场上1只怪兽解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,79844764+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCost(c79844764.cost)
	e1:SetOperation(c79844764.activate)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于检测玩家是否从额外卡组特殊召唤过怪兽
	Duel.AddCustomActivityCounter(79844764,ACTIVITY_SPSUMMON,c79844764.counterfilter)
end
-- 过滤函数，当特殊召唤的怪兽不是来自额外卡组时返回true，用于计数器排除非额外卡组的特召
function c79844764.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA)
end
-- 发动代价函数，检查本回合是否未从额外卡组特殊召唤怪兽，并注册本回合不能从额外卡组特殊召唤怪兽的誓约效果
function c79844764.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查玩家在本回合内是否未曾从额外卡组特殊召唤过怪兽
	if chk==0 then return Duel.GetCustomActivityCount(79844764,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c79844764.splimit)
	-- 给玩家注册不能从额外卡组特殊召唤怪兽的誓约限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，指定不能特殊召唤的范围为额外卡组的怪兽
function c79844764.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 效果处理函数，注册允许用对方场上怪兽代替自己场上怪兽作为上级召唤解放的效果
function c79844764.activate(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这个回合，自己把怪兽上级召唤的场合只有1次，可以作为自己场上1只怪兽的代替而把对方场上1只怪兽解放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_RELEASE_SUM)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册允许用对方场上怪兽代替自己场上怪兽作为上级召唤解放的全局效果
	Duel.RegisterEffect(e1,tp)
end
