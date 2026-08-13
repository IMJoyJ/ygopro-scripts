--フェンリル
-- 效果：
-- 这张卡不能进行通常召唤。从自己墓地里除外2只水属性怪兽进行特殊召唤。这张卡战斗破坏对方怪兽时，略过对方的下一个抽卡阶段。
function c218704.initial_effect(c)
	c:EnableReviveLimit()
	-- 对应效果原文：从自己墓地里除外2只水属性怪兽进行特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c218704.spcon)
	e1:SetTarget(c218704.sptg)
	e1:SetOperation(c218704.spop)
	c:RegisterEffect(e1)
	-- 对应效果原文：这张卡战斗破坏对方怪兽时，略过对方的下一个抽卡阶段。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(218704,0))  --"跳过抽卡阶段"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设定诱发效果的发动条件：这张卡与对方怪兽进行战斗，并因该战斗破坏了对方怪兽。
	e2:SetCondition(aux.bdocon)
	e2:SetOperation(c218704.skipop)
	c:RegisterEffect(e2)
end
-- 定义可作为特殊召唤代价的怪兽筛选条件：自己墓地的水属性怪兽且可以除外。
function c218704.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToRemoveAsCost()
end
-- 设定特殊召唤规则的发动条件：自己场上有空位，且自己墓地存在至少2只可除外的水属性怪兽。
function c218704.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上怪兽区域是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少2只满足筛选条件（可除外的水属性怪兽）的怪兽。
		and Duel.IsExistingMatchingCard(c218704.spfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 进行特殊召唤规则的目标处理：选择自己墓地的2只水属性怪兽作为除外代价，选择成功则保存并返回true，否则返回false。
function c218704.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有可作为代价的水属性怪兽，生成候选组供玩家选择。
	local g=Duel.GetMatchingGroup(c218704.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤规则的代价处理：将之前选中的墓地怪兽除外，代价完成后由核心将芬里尔特殊召唤。
function c218704.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的墓地怪兽以表侧表示除外，原因为特殊召唤的代价（REASON_SPSUMMON）。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 处理战斗破坏对方怪兽后的效果：为对方玩家附加跳过其下一个抽卡阶段的效果，该效果持续到对方抽卡阶段结束。
function c218704.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 对应效果原文：略过对方的下一个抽卡阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN)
	-- 将生成的“跳过抽卡阶段”效果注册到决斗中，使其影响对方玩家。
	Duel.RegisterEffect(e1,tp)
end
