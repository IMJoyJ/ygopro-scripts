--スレッショルド・ボーグ
-- 效果：
-- ①：自己场上没有怪兽存在的场合，这张卡可以把手卡1只电子界族怪兽丢弃，从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降500。
function c31944175.initial_effect(c)
	-- 效果原文内容：①：自己场上没有怪兽存在的场合，这张卡可以把手卡1只电子界族怪兽丢弃，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c31944175.spcon)
	e1:SetTarget(c31944175.sptg)
	e1:SetOperation(c31944175.spop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(-500)
	c:RegisterEffect(e2)
end
-- 规则层面作用：定义用于筛选手卡中电子界族怪兽的过滤函数
function c31944175.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_CYBERSE) and c:IsDiscardable()
end
-- 规则层面作用：判断特殊召唤条件是否满足，包括场上是否有空位、自己场上是否无怪兽、手卡是否有电子界族怪兽
function c31944175.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面作用：检查玩家场上主怪兽区是否有空位且自己场上没有怪兽
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 规则层面作用：检查手卡是否存在至少1张满足条件的电子界族怪兽
		and Duel.IsExistingMatchingCard(c31944175.cfilter,tp,LOCATION_HAND,0,1,c)
end
-- 规则层面作用：设置特殊召唤时的选择目标，提示玩家选择要丢弃的电子界族怪兽
function c31944175.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 规则层面作用：获取满足条件的电子界族怪兽组
	local g=Duel.GetMatchingGroup(c31944175.cfilter,tp,LOCATION_HAND,0,c)
	-- 规则层面作用：向玩家发送提示信息，提示选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 规则层面作用：执行特殊召唤后的处理，将选定的怪兽送去墓地
function c31944175.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 规则层面作用：将目标怪兽以特殊召唤和丢弃的原因送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON+REASON_DISCARD)
end
