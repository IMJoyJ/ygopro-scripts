--ジェムナイトマスター・ダイヤ
-- 效果：
-- 「宝石骑士」怪兽×3
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡的攻击力上升自己墓地的「宝石」怪兽数量×100。
-- ②：1回合1次，从自己墓地把1只7星以下的「宝石骑士」融合怪兽除外才能发动。这张卡直到结束阶段得到和除外的怪兽的原本的卡名·效果相同的卡名·效果。
function c39512984.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用3个融合素材进行融合召唤，且素材必须为「宝石骑士」卡组的怪兽
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1047),3,true)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c39512984.splimit)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力上升自己墓地的「宝石」怪兽数量×100
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c39512984.atkup)
	c:RegisterEffect(e2)
	-- 1回合1次，从自己墓地把1只7星以下的「宝石骑士」融合怪兽除外才能发动。这张卡直到结束阶段得到和除外的怪兽的原本的卡名·效果相同的卡名·效果
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39512984,0))  --"获得效果"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c39512984.cost)
	e3:SetOperation(c39512984.operation)
	c:RegisterEffect(e3)
end
-- 判断召唤方式是否为融合召唤，若不是则不能从额外卡组特殊召唤
function c39512984.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 过滤墓地中的「宝石」怪兽
function c39512984.atkfilter(c)
	return c:IsSetCard(0x47) and c:IsType(TYPE_MONSTER)
end
-- 计算墓地中的「宝石」怪兽数量并乘以100作为攻击力加成
function c39512984.atkup(e,c)
	-- 计算墓地中的「宝石」怪兽数量并乘以100作为攻击力加成
	return Duel.GetMatchingGroupCount(c39512984.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*100
end
-- 过滤墓地中7星以下、属于「宝石骑士」卡组、且为融合怪兽的可除外卡片
function c39512984.filter(c)
	return c:IsLevelBelow(7) and c:IsSetCard(0x1047) and c:IsType(TYPE_FUSION) and c:IsAbleToRemoveAsCost()
end
-- 检查是否有满足条件的卡片可作为除外代价，并选择一张进行除外操作
function c39512984.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的卡片可作为除外代价
	if chk==0 then return Duel.IsExistingMatchingCard(c39512984.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张满足条件的卡片进行除外操作
	local g=Duel.SelectMatchingCard(tp,c39512984.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡片以正面表示的形式从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetOriginalCode())
end
-- 将该卡的卡名和效果替换为被除外的融合怪兽的原本卡名和效果
function c39512984.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=e:GetLabel()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将该卡的卡名替换为被除外的融合怪兽的原本卡名
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
