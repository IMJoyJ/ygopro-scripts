--ウィンドファーム・ジェネクス
-- 效果：
-- 「次世代控制员」＋调整以外的风属性怪兽1只以上
-- ①：这张卡的攻击力上升场上的里侧表示的魔法·陷阱卡数量×300。
-- ②：把1张手卡送去墓地，以场上1张里侧表示的魔法·陷阱卡为对象才能发动。那张里侧表示卡破坏。
function c43925870.initial_effect(c)
	-- 为该怪兽添加融合召唤所需的素材代码列表，允许使用代码为68505803的「次世代控制员」作为融合素材
	aux.AddMaterialCodeList(c,68505803)
	-- 设置该怪兽的同调召唤手续，要求1只代码为68505803的调整，以及1只调整以外的风属性怪兽作为同调素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,68505803),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_WIND),1)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升场上的里侧表示的魔法·陷阱卡数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c43925870.val)
	c:RegisterEffect(e1)
	-- ②：把1张手卡送去墓地，以场上1张里侧表示的魔法·陷阱卡为对象才能发动。那张里侧表示卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43925870,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c43925870.descost)
	e2:SetTarget(c43925870.destg)
	e2:SetOperation(c43925870.desop)
	c:RegisterEffect(e2)
end
-- 计算场上里侧表示的魔法·陷阱卡数量并乘以300作为攻击力加成
function c43925870.val(e,c)
	-- 获取场上里侧表示的魔法·陷阱卡数量并乘以300作为攻击力加成
	return Duel.GetMatchingGroupCount(Card.IsFacedown,0,LOCATION_SZONE,LOCATION_SZONE,nil)*300
end
-- 处理效果发动时的费用支付，要求玩家从手卡选择1张可送入墓地的卡并送去墓地
function c43925870.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手卡是否存在至少1张可送入墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家发送提示信息，提示其选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择并把1张手卡送去墓地作为效果发动的费用
	Duel.SendtoGrave(Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil),REASON_COST)
end
-- 定义用于筛选目标的过滤函数，判断目标是否为里侧表示的卡
function c43925870.filter(c)
	return c:IsFacedown()
end
-- 设置效果的目标选择逻辑，要求选择场上1张里侧表示的魔法·陷阱卡作为破坏对象
function c43925870.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c43925870.filter(chkc) end
	-- 检查场上是否存在至少1张里侧表示的魔法·陷阱卡作为效果目标
	if chk==0 then return Duel.IsExistingTarget(c43925870.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 向玩家发送提示信息，提示其选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张里侧表示的魔法·陷阱卡作为效果目标
	local g=Duel.SelectTarget(tp,c43925870.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	-- 设置效果操作信息，确定破坏效果将要处理的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果的破坏操作，若目标卡为里侧表示且有效，则将其破坏
function c43925870.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
