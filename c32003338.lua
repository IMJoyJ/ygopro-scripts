--No.34 電算機獣テラ・バイト
-- 效果：
-- 3星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只4星以下的攻击表示怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
function c32003338.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以3只等级3的怪兽作为超量素材来XYZ召唤（对应“3星怪兽×3”）。
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
-- 将这张卡登记为No.34的XYZ怪兽，供No.系列相关效果判断使用。
aux.xyz_number[32003338]=34
-- 实现发动代价：从这张卡上取除1个超量素材（先检查是否可以取除，再实际取除）。
function c32003338.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义可选对象条件：对方场上的表侧攻击表示、等级4以下、且控制权可以被变更的怪兽。
function c32003338.filter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsLevelBelow(4) and c:IsControlerCanBeChanged()
end
-- 效果发动阶段：确认存在合法对象后，由玩家选择对方场上1只符合条件的怪兽作为效果对象，并登记该操作信息。
function c32003338.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c32003338.filter(chkc) end
	-- 检查对方场上是否存在至少1只满足条件的怪兽，作为效果能否发动的条件。
	if chk==0 then return Duel.IsExistingTarget(c32003338.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作者显示“请选择要改变控制权的怪兽”的提示信息，用于目标选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方场上选择1只符合条件的怪兽作为本效果的对象，并自动建立对象关联。
	local g=Duel.SelectTarget(tp,c32003338.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将本次效果的操作信息设定为“变更控制权”，对象为选定怪兽，供其他卡（如星尘龙等）进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理阶段：取得效果对象怪兽的控制权，若对象仍与本效果关联，则变更其控制权直到结束阶段。
function c32003338.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取出本效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 让回合玩家获得该对象怪兽的控制权，持续到结束阶段为止（本回合结束阶段时恢复）。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
