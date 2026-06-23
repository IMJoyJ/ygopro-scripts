--フェンリル
-- 效果：
-- 这张卡不能进行通常召唤。从自己墓地里除外2只水属性怪兽进行特殊召唤。这张卡战斗破坏对方怪兽时，略过对方的下一个抽卡阶段。
function c218704.initial_effect(c)
	c:EnableReviveLimit()
	-- 从自己墓地里除外2只水属性怪兽进行特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c218704.spcon)
	e1:SetTarget(c218704.sptg)
	e1:SetOperation(c218704.spop)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏对方怪兽时，略过对方的下一个抽卡阶段
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(218704,0))  --"跳过抽卡阶段"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测本次战斗是否与对方怪兽有关
	e2:SetCondition(aux.bdocon)
	e2:SetOperation(c218704.skipop)
	c:RegisterEffect(e2)
end
-- 过滤满足水属性且可作为费用除外的怪兽
function c218704.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足特殊召唤条件，包括场上是否有空位和墓地是否有2只水属性怪兽
function c218704.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断场上是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否有2只水属性怪兽
		and Duel.IsExistingMatchingCard(c218704.spfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 选择2只水属性怪兽除外
function c218704.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的水属性怪兽组
	local g=Duel.GetMatchingGroup(c218704.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的除外操作
function c218704.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 设置并注册跳过抽卡阶段的效果
function c218704.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过对方的下一个抽卡阶段
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
