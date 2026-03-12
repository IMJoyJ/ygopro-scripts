--交差する魂
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段才能发动。把1只幻神兽族怪兽上级召唤。那个时候，也能作为自己场上的怪兽的代替而把对方场上的怪兽解放。把对方场上的怪兽解放作上级召唤的场合，以下效果适用。
-- ●这张卡的发动后，直到下个回合的结束时自己1回合只能有1次把幻神兽族怪兽以外的魔法·陷阱·怪兽的效果发动。
function c5253985.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5253985,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,5253985+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c5253985.sumcon)
	e1:SetTarget(c5253985.sumtg)
	e1:SetOperation(c5253985.sumop)
	c:RegisterEffect(e1)
end
-- 效果作用：检查当前是否为自己的主要阶段1或主要阶段2
function c5253985.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 效果作用：过滤满足条件的幻神兽族怪兽并判断其能否被召唤
function c5253985.sumfilter(c,ec)
	if not c:IsRace(RACE_DIVINE) then return false end
	-- 效果原文内容：把1只幻神兽族怪兽上级召唤。那个时候，也能作为自己场上的怪兽的代替而把对方场上的怪兽解放。
	local e1=Effect.CreateEffect(ec)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local res=c:IsSummonable(true,nil,1)
	e1:Reset()
	return res
end
-- 效果作用：检查手牌中是否存在满足条件的幻神兽族怪兽
function c5253985.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检测是否手牌中有满足条件的幻神兽族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5253985.sumfilter,tp,LOCATION_HAND,0,1,nil,e:GetHandler()) end
	-- 效果作用：设置连锁操作信息为召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果作用：选择并召唤幻神兽族怪兽
function c5253985.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 效果作用：从手牌中选择满足条件的幻神兽族怪兽
	local tc=Duel.SelectMatchingCard(tp,c5253985.sumfilter,tp,LOCATION_HAND,0,1,1,nil,c):GetFirst()
	if tc then
		-- 效果原文内容：把对方场上的怪兽解放作上级召唤的场合，以下效果适用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
		e1:SetRange(LOCATION_HAND)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetValue(POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果原文内容：●这张卡的发动后，直到下个回合的结束时自己1回合只能有1次把幻神兽族怪兽以外的魔法·陷阱·怪兽的效果发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetReset(RESET_PHASE+PHASE_MAIN1)
		e1:SetOperation(c5253985.limitop)
		-- 效果作用：注册EVENT_SUMMON_SUCCESS事件监听器
		Duel.RegisterEffect(e1,tp)
		-- 效果作用：注册EVENT_SUMMON_NEGATED事件监听器
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SUMMON_NEGATED)
		e2:SetOperation(c5253985.rstop)
		e2:SetLabelObject(e1)
		e2:SetReset(RESET_PHASE+PHASE_MAIN1)
		-- 效果作用：注册EVENT_SUMMON_NEGATED事件监听器
		Duel.RegisterEffect(e2,tp)
		-- 效果作用：执行幻神兽族怪兽的通常召唤
		Duel.Summon(tp,tc,true,nil,1)
	end
end
-- 效果作用：判断目标怪兽是否为对方控制的怪兽
function c5253985.cfilter(c,tp)
	return c:IsPreviousControler(1-tp)
end
-- 效果作用：当幻神兽族怪兽成功召唤时，设置限制发动效果的条件
function c5253985.limitop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	local g=tc:GetMaterial()
	if g and g:IsExists(c5253985.cfilter,1,nil,tp) then
		-- 效果作用：增加自定义活动计数器（用于记录发动次数）
		Duel.AddCustomActivityCounter(5253985,ACTIVITY_CHAIN,c5253985.chainfilter)
		-- 效果原文内容：●这张卡的发动后，直到下个回合的结束时自己1回合只能有1次把幻神兽族怪兽以外的魔法·陷阱·怪兽的效果发动。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_ACTIVATE)
		e3:SetTargetRange(1,0)
		e3:SetCondition(c5253985.actcon)
		e3:SetValue(c5253985.aclimit)
		e3:SetReset(RESET_PHASE+PHASE_END,2)
		-- 效果作用：注册EFFECT_CANNOT_ACTIVATE效果以限制发动
		Duel.RegisterEffect(e3,tp)
	end
	e:Reset()
end
-- 效果作用：当召唤被无效时，重置相关效果
function c5253985.rstop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	if e1 then e1:Reset() end
	e:Reset()
end
-- 效果作用：过滤条件函数，判断效果是否为幻神兽族怪兽类型
function c5253985.chainfilter(re,tp,cid)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRace(RACE_DIVINE)
end
-- 效果作用：判断是否已发动过非幻神兽族的魔法/陷阱/怪兽效果
function c5253985.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 效果作用：获取指定玩家在当前回合中发动的非幻神兽族效果次数
	return Duel.GetCustomActivityCount(5253985,tp,ACTIVITY_CHAIN)~=0
end
-- 效果作用：限制发动效果的条件函数，禁止发动幻神兽族以外的效果
function c5253985.aclimit(e,re,tp)
	return not (re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRace(RACE_DIVINE))
end
