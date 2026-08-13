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
-- 判断这张卡是否以表侧攻击表示存在于怪兽区，作为该起动效果的发动条件。
function c31975743.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 筛选可作为发动COST的手卡怪兽：必须是怪兽且能够作为COST被送去墓地。
function c31975743.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 支付COST：从手卡选择1只符合条件的怪兽，将其作为COST送入墓地。
function c31975743.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查COST是否满足：手卡中是否存在至少1只可作为COST送去墓地的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c31975743.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选择1只满足COST条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c31975743.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽作为COST送进墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 筛选效果对象：对方场上的表侧守备表示怪兽，并且其控制权能够被改变。
function c31975743.filter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsControlerCanBeChanged()
end
-- 设定效果对象：选择对方场上1只表侧守备表示且控制权可变更的怪兽，并登记获得控制权的操作信息。
function c31975743.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c31975743.filter(chkc) end
	-- 检查是否存在满足条件的对象（对方场上表侧守备表示且可被改变控制权的怪兽）。
	if chk==0 then return Duel.IsExistingTarget(c31975743.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c31975743.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：本连锁将处理获得1只怪兽控制权的效果。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：取得对象怪兽的控制权直到结束阶段；若成功，再给那只怪兽附加不能变更表示形式的效果。
function c31975743.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中的对象怪兽（选择的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 尝试将那只怪兽的控制权移转给自己，持续到结束阶段；成功时返回非0值。
		if Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
			-- 这个效果得到控制权的怪兽在这个回合不能把表示形式变更。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
