--帝王の溶撃
-- 效果：
-- 自己的额外卡组没有卡存在，自己场上有上级召唤的怪兽存在的场合才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，上级召唤的怪兽以外的场上的表侧表示怪兽的效果无效化。
-- ②：自己结束阶段，上级召唤的怪兽不在自己场上存在的场合这张卡送去墓地。
function c48716527.initial_effect(c)
	-- 开启全局标记 GLOBALFLAG_SELF_TOGRAVE，使本卡②效果这类不入连锁的自我送墓效果能够被引擎正确检测与处理。
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- 自己的额外卡组没有卡存在，自己场上有上级召唤的怪兽存在的场合才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c48716527.actcon)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，上级召唤的怪兽以外的场上的表侧表示怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c48716527.distg)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	-- ②：自己结束阶段，上级召唤的怪兽不在自己场上存在的场合这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_SELF_TOGRAVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c48716527.tgcon)
	c:RegisterEffect(e3)
end
-- 定义过滤函数：判断怪兽是否具有上级召唤（解放召唤）的召唤类型，用于筛选上级召唤的怪兽。
function c48716527.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 发动条件的判定：满足“自己的额外卡组没有卡存在，且自己场上有上级召唤的怪兽存在”时才可发动。
function c48716527.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件之一：自己（tp）的额外卡组卡数为0，即额外卡组没有卡存在。
	return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0
		-- 发动条件之二：自己场上存在至少1只上级召唤的怪兽。
		and Duel.IsExistingMatchingCard(c48716527.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的适用对象判定：该怪兽不是上级召唤的怪兽，因此会被无效化。
function c48716527.distg(e,c)
	return not c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果②的送墓条件判定：在控制者的结束阶段，自己场上没有上级召唤的怪兽存在时，这张卡送去墓地。
function c48716527.tgcon(e)
	local tp=e:GetHandlerPlayer()
	-- 满足效果②的时点：当前是这张卡的控制者的结束阶段。
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_END
		-- 送墓条件成立：自己场上不存在上级召唤的怪兽。
		and not Duel.IsExistingMatchingCard(c48716527.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
