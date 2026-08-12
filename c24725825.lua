--エレクトリック・ワーム
-- 效果：
-- ①：把这张卡从手卡丢弃去墓地，以对方场上1只龙族·机械族怪兽为对象才能发动。那只龙族·机械族怪兽的控制权直到结束阶段得到。
function c24725825.initial_effect(c)
	-- ①：把这张卡从手卡丢弃去墓地，以对方场上1只龙族·机械族怪兽为对象才能发动。那只龙族·机械族怪兽的控制权直到结束阶段得到。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24725825,0))  --"获取控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c24725825.cost)
	e1:SetTarget(c24725825.target)
	e1:SetOperation(c24725825.operation)
	c:RegisterEffect(e1)
end
-- 将此卡从手牌丢弃至墓地作为费用
function c24725825.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡从手牌丢弃至墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 筛选条件：场上正面表示的龙族·机械族怪兽且控制权可变更
function c24725825.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE+RACE_DRAGON) and c:IsControlerCanBeChanged()
end
-- 选择对象：选择对方场上1只龙族·机械族怪兽作为效果对象
function c24725825.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c24725825.filter(chkc) end
	-- 判断是否满足发动条件：对方场上是否存在龙族·机械族怪兽
	if chk==0 then return Duel.IsExistingTarget(c24725825.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只龙族·机械族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c24725825.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：将选择的怪兽控制权变更效果加入连锁处理
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：将选择的怪兽控制权交给发动者直到结束阶段
function c24725825.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRace(RACE_MACHINE+RACE_DRAGON) then
		-- 将对象怪兽的控制权交给发动者直到结束阶段
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
