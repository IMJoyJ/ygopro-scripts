--マジシャンズ・エイプ
-- 效果：
-- 这张卡不能特殊召唤。这张卡在场上表侧攻击表示存在的场合，1回合1次，把手卡1只怪兽送去墓地，选择对方场上表侧守备表示存在的1只怪兽才能发动。直到这个回合的结束阶段时，得到选择的怪兽的控制权。这个效果得到控制权的怪兽在这个回合不能把表示形式变更。
function c31975743.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡在场上表侧攻击表示存在的场合，1回合1次，把手卡1只怪兽送去墓地，选择对方场上表侧守备表示存在的1只怪兽才能发动。直到这个回合的结束阶段时，得到选择的怪兽的控制权。这个效果得到控制权的怪兽在这个回合不能把表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31975743,0))  --"获得控制权"
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c31975743.condition)
	e2:SetCost(c31975743.cost)
	e2:SetTarget(c31975743.target)
	e2:SetOperation(c31975743.operation)
	c:RegisterEffect(e2)
end
-- 效果发动的条件：怪兽卡必须处于攻击表示
function c31975743.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 费用支付时的过滤函数：检查手牌中是否存在怪兽卡且能作为墓地费用
function c31975743.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果的费用支付流程：检索手牌中满足条件的怪兽卡并将其送入墓地
function c31975743.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足费用支付条件：确认手牌中存在至少一张符合条件的怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c31975743.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示选择要送入墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张手牌怪兽卡
	local g=Duel.SelectMatchingCard(tp,c31975743.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡送入墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 目标选择时的过滤函数：检查对方场上是否存在表侧守备表示的怪兽且能改变控制权
function c31975743.filter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsControlerCanBeChanged()
end
-- 效果的目标选择流程：选择对方场上满足条件的1只怪兽作为目标
function c31975743.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c31975743.filter(chkc) end
	-- 检查是否满足目标选择条件：确认对方场上存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c31975743.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择满足条件的1只对方场上的怪兽作为目标
	local g=Duel.SelectTarget(tp,c31975743.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：记录本次效果将改变目标怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果的处理流程：获得目标怪兽的控制权并设置其在本回合不能改变表示形式
function c31975743.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 尝试获得目标怪兽的控制权，直到结束阶段
		if Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
			-- 为获得控制权的怪兽设置效果：本回合不能改变表示形式
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
