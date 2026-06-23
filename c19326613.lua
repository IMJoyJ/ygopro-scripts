--妖精伝姫のはじまりはじまり
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地·除外状态各把最多1只光属性「妖精传姬」怪兽特殊召唤（同名卡最多1张）。这个回合，自己不是魔法师族怪兽不能特殊召唤。
-- ②：这张卡被除外的场合或者从场上以外送去墓地的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡在自己场上没有「妖精传姬」怪兽存在的场合不能发动。
local s,id,o=GetID()
-- 初始化卡片效果，注册①②两个效果，①为自由连锁发动的特殊召唤效果，②为除外或送去墓地时的盖放效果
function s.initial_effect(c)
	-- ①：从自己的手卡·墓地·除外状态各把最多1只光属性「妖精传姬」怪兽特殊召唤（同名卡最多1张）。这个回合，自己不是魔法师族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合或者从场上以外送去墓地的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡在自己场上没有「妖精传姬」怪兽存在的场合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.setcon)
	c:RegisterEffect(e3)
end
-- 特殊召唤过滤函数，用于筛选满足条件的光属性「妖精传姬」怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1db) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的检查函数，判断是否满足特殊召唤条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌·墓地·除外区是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置效果发动时的操作信息，提示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 选择满足条件的怪兽数量的检查函数，确保同名卡不超过1张且每种状态的怪兽不超过1只
function s.gcheck(g)
	if #g==1 then return true end
	-- 检查所选怪兽是否满足卡名各不相同的条件
	return aux.dncheck(g)
		and g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)<2
		and g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<2
		and g:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)<2
end
-- 效果发动处理函数，执行特殊召唤操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的怪兽组，包括手牌、墓地、除外区的光属性「妖精传姬」怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 and #g>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroup(tp,s.gcheck,false,1,math.min(3,ft))
		if sg then
			-- 执行特殊召唤操作，将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置永续效果，禁止在本回合特殊召唤非魔法师族怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册禁止特殊召唤的效果到玩家场上
	Duel.RegisterEffect(e1,tp)
end
-- 禁止特殊召唤效果的过滤函数，限制非魔法师族怪兽特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_SPELLCASTER)
end
-- 盖放效果的发动条件，判断该卡是否不是从场上除外或送去墓地
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 盖放效果的发动时检查函数，判断该卡是否可以盖放
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	if c:IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息，提示将要盖放该卡
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- 盖放效果的处理函数，执行盖放操作并注册触发效果
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否可以盖放，包括是否在连锁中相关、是否受王家长眠之谷影响、是否成功盖放
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SSet(tp,c)~=0 then
		-- 盖放后注册的效果，使该卡无法发动效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"「妖精传姬开始啦开始啦」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCondition(s.actcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 用于检查场上是否存在「妖精传姬」怪兽的过滤函数
function s.actfilter(c)
	return c:IsSetCard(0x1db) and c:IsFaceup()
end
-- 盖放效果触发条件函数，判断是否满足盖放后效果发动的条件
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	return not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
		-- 判断场上是否不存在「妖精传姬」怪兽
		and not Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_MZONE,0,1,nil)
end
