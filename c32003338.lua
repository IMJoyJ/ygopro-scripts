--No.34 電算機獣テラ・バイト
-- 效果：
-- 3星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只4星以下的攻击表示怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
function c32003338.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用3星怪兽叠放3次
	aux.AddXyzProcedure(c,nil,3,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只4星以下的攻击表示怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetDescription(aux.Stringid(32003338,0))  --"获得控制权"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c32003338.cost)
	e1:SetTarget(c32003338.target)
	e1:SetOperation(c32003338.operation)
	c:RegisterEffect(e1)
end
-- 设置该卡的XYZ编号为34
aux.xyz_number[32003338]=34
-- 效果发动时的费用处理，移除1个超量素材作为费用
function c32003338.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选符合条件的目标怪兽，必须是攻击表示、等级4以下且可以改变控制权
function c32003338.filter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsLevelBelow(4) and c:IsControlerCanBeChanged()
end
-- 设置效果的目标选择逻辑，选择对方场上符合条件的1只怪兽
function c32003338.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c32003338.filter(chkc) end
	-- 判断是否有符合条件的目标怪兽存在
	if chk==0 then return Duel.IsExistingTarget(c32003338.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c32003338.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，确定将要改变控制权的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理函数，使目标怪兽的控制权转移给使用者
function c32003338.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽的控制权转移给使用者，持续到结束阶段
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
