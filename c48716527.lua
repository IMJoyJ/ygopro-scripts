--帝王の溶撃
-- 效果：
-- 自己的额外卡组没有卡存在，自己场上有上级召唤的怪兽存在的场合才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，上级召唤的怪兽以外的场上的表侧表示怪兽的效果无效化。
-- ②：自己结束阶段，上级召唤的怪兽不在自己场上存在的场合这张卡送去墓地。
function c48716527.initial_effect(c)
	-- 设置全局标记，用于检测是否因效果送入墓地
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- ①：只要这张卡在魔法与陷阱区域存在，上级召唤的怪兽以外的场上的表侧表示怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c48716527.actcon)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段，上级召唤的怪兽不在自己场上存在的场合这张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c48716527.distg)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	-- 自己的额外卡组没有卡存在，自己场上有上级召唤的怪兽存在的场合才能把这张卡发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_SELF_TOGRAVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c48716527.tgcon)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否为上级召唤的怪兽
function c48716527.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 发动条件函数，检查自己额外卡组是否为空且场上是否存在上级召唤的怪兽
function c48716527.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己额外卡组是否没有卡存在
	return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0
		-- 检查自己场地上是否存在至少1只上级召唤的怪兽
		and Duel.IsExistingMatchingCard(c48716527.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 无效化目标怪兽效果的过滤函数，排除上级召唤的怪兽
function c48716527.distg(e,c)
	return not c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 送墓条件函数，判断是否在自己的结束阶段且场上不存在上级召唤的怪兽
function c48716527.tgcon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断当前阶段是否为自己的结束阶段
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_END
		-- 检查自己场地上是否存在至少1只上级召唤的怪兽
		and not Duel.IsExistingMatchingCard(c48716527.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
