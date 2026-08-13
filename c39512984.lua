--ジェムナイトマスター・ダイヤ
-- 效果：
-- 「宝石骑士」怪兽×3
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡的攻击力上升自己墓地的「宝石」怪兽数量×100。
-- ②：1回合1次，从自己墓地把1只7星以下的「宝石骑士」融合怪兽除外才能发动。这张卡直到结束阶段得到和除外的怪兽的原本的卡名·效果相同的卡名·效果。
function c39512984.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，指定3只“宝石骑士”字段怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1047),3,true)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c39512984.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升自己墓地的「宝石」怪兽数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c39512984.atkup)
	c:RegisterEffect(e2)
	-- ②：1回合1次，从自己墓地把1只7星以下的「宝石骑士」融合怪兽除外才能发动。这张卡直到结束阶段得到和除外的怪兽的原本的卡名·效果相同的卡名·效果。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39512984,0))  --"获得效果"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c39512984.cost)
	e3:SetOperation(c39512984.operation)
	c:RegisterEffect(e3)
end
-- 特殊召唤限制判定：若这张卡不在额外卡组则允许特殊召唤；若在额外卡组则召唤方式必须为融合召唤。
function c39512984.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 墓地中“宝石”字段怪兽的过滤条件：属于0x47系列且为怪兽卡。
function c39512984.atkfilter(c)
	return c:IsSetCard(0x47) and c:IsType(TYPE_MONSTER)
end
-- 攻击力上升值计算：统计自己墓地中满足“宝石”怪兽的卡数量并乘以100。
function c39512984.atkup(e,c)
	-- 取得自己墓地的「宝石」怪兽数量×100作为攻击力上升数值。
	return Duel.GetMatchingGroupCount(c39512984.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*100
end
-- 墓地中可作为代价除外的融合怪兽过滤条件：7星以下、“宝石骑士”字段、融合怪兽、可作为代价除外。
function c39512984.filter(c)
	return c:IsLevelBelow(7) and c:IsSetCard(0x1047) and c:IsType(TYPE_FUSION) and c:IsAbleToRemoveAsCost()
end
-- 发动代价处理：检查墓地是否存在符合条件的融合怪兽，提示玩家选择1张，将其表侧表示除外，并记录其原本卡号供效果处理使用。
function c39512984.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己墓地存在至少1张满足条件的可除外的“宝石骑士”融合怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c39512984.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足filter条件的“宝石骑士”融合怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c39512984.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的融合怪兽表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetOriginalCode())
end
-- 效果处理：若此卡仍与效果关联且表侧表示，则获取被除外怪兽的原本卡号，注册改变卡名的效果并复制其效果，直到结束阶段。
function c39512984.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=e:GetLabel()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡直到结束阶段得到和除外的怪兽的原本的卡名·效果相同的卡名·效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		c:RegisterEffect(e1)
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	end
end
