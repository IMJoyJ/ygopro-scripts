--マスター・ジーグ
-- 效果：
-- 支付1000基本分发动。把自己场上表侧表示存在的念动力族怪兽数量的对方场上存在的怪兽破坏。这个效果1回合只能使用1次。
function c16191953.initial_effect(c)
	-- 对应效果原文：“支付1000基本分发动。把自己场上表侧表示存在的念动力族怪兽数量的对方场上存在的怪兽破坏。这个效果1回合只能使用1次。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16191953,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c16191953.cost)
	e1:SetTarget(c16191953.target)
	e1:SetOperation(c16191953.operation)
	c:RegisterEffect(e1)
end
-- 该效果的发动代价：检查能否支付1000基本分，并在发动时实际支付1000基本分。
function c16191953.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：在效果发动合法性检查时，确认玩家tp能否支付1000基本分（支付不能则不可发动）。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数：判断怪兽是否为表侧表示且种族为念动力族，用于统计自己场上表侧存在的念动力族怪兽数量。
function c16191953.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 效果发动的前置处理：计算自己场上表侧念动力族怪兽数量，获取对方场上全部怪兽，并设置本次破坏的操作信息。
function c16191953.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：自己场上表侧念动力族怪兽的数量必须不超过对方场上存在的怪兽总数，否则无法选出足够数量的破坏对象，不能发动。
	if chk==0 then return Duel.GetMatchingGroupCount(c16191953.filter,tp,LOCATION_MZONE,0,nil)<=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil) end
	-- 统计自己场上表侧表示且种族为念动力族的怪兽数量，该数量即为要破坏的对方怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c16191953.filter,tp,LOCATION_MZONE,0,nil)
	-- 获取对方场上的全部怪兽组合，作为后续可能被破坏的对象范围。
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：将本次连锁确定为破坏效果，对象范围是对方场上全部怪兽，预定破坏数量为ct。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,ct,0,0)
end
-- 效果处理：重新统计自己场上表侧念动力族怪兽数量，若该数量大于对方场上怪兽数量则效果不处理；否则提示玩家选择对应数量的对方怪兽并破坏。
function c16191953.operation(e,tp,eg,ep,ev,re,r,rp)
	-- （效果处理时）重新统计自己场上表侧念动力族怪兽的数量，作为实际需要破坏的怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c16191953.filter,tp,LOCATION_MZONE,0,nil)
	-- 获取对方场上的全部怪兽组合，用于从中选择破坏对象。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if ct>g:GetCount() then return end
	-- 向玩家显示选择要破坏的怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local dg=g:Select(tp,ct,ct,nil)
	-- 展示被选中的怪兽卡片的对象选择动画，并记录这些卡片被选为（广义的）对象。
	Duel.HintSelection(dg)
	-- 以效果原因（REASON_EFFECT）破坏选择出的怪兽。
	Duel.Destroy(dg,REASON_EFFECT)
end
