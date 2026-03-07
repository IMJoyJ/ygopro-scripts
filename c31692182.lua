--コアキメイル・フルバリア
-- 效果：
-- 从手卡让1张「核成兽的钢核」回到卡组最上面发动。直到下次的自己回合的准备阶段时，名字带有「核成」的怪兽以外的场上表侧表示存在的效果怪兽的效果无效化。
function c31692182.initial_effect(c)
	-- 记录此卡与「核成兽的钢核」之间的关联
	aux.AddCodeList(c,36623431)
	-- 从手卡让1张「核成兽的钢核」回到卡组最上面发动。直到下次的自己回合的准备阶段时，名字带有「核成」的怪兽以外的场上表侧表示存在的效果怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31692182,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c31692182.cost)
	e1:SetOperation(c31692182.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断手卡中是否存在可作为代价送入卡组的「核成兽的钢核」
function c31692182.cfilter(c)
	return c:IsCode(36623431) and c:IsAbleToDeckAsCost()
end
-- 支付代价时检查手卡是否存在「核成兽的钢核」并选择送入卡组
function c31692182.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张「核成兽的钢核」
	if chk==0 then return Duel.IsExistingMatchingCard(c31692182.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1张满足条件的「核成兽的钢核」送入卡组
	local g=Duel.SelectMatchingCard(tp,c31692182.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡送入卡组最上面作为发动代价
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end
-- 过滤函数，用于筛选场上表侧表示的效果怪兽（排除名字带有「核成」的怪兽）
function c31692182.filter(e,c)
	return c:IsType(TYPE_EFFECT) and not c:IsSetCard(0x1d)
end
-- 发动效果，将符合条件的怪兽效果无效化直到下次准备阶段
function c31692182.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 名字带有「核成」的怪兽以外的场上表侧表示存在的效果怪兽的效果无效化。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c31692182.filter)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
	-- 将效果注册给全局环境，使效果生效
	Duel.RegisterEffect(e1,tp)
end
