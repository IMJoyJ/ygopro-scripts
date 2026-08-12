--パペット・プラント
-- 效果：
-- 把这张卡从手卡丢弃去墓地。直到这个回合的结束阶段时，得到对方场上表侧表示存在的1只战士族或者魔法师族怪兽的控制权。
function c51119924.initial_effect(c)
	-- 把这张卡从手卡丢弃去墓地。直到这个回合的结束阶段时，得到对方场上表侧表示存在的1只战士族或者魔法师族怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51119924,0))  --"获取控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c51119924.cost)
	e1:SetTarget(c51119924.target)
	e1:SetOperation(c51119924.operation)
	c:RegisterEffect(e1)
end
-- 将此卡送入墓地作为费用
function c51119924.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送入墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 筛选条件：表侧表示、战士族或魔法师族、可以改变控制权
function c51119924.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR+RACE_SPELLCASTER) and c:IsControlerCanBeChanged()
end
-- 选择对方场上的1只符合条件的怪兽作为对象
function c51119924.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c51119924.filter(chkc) end
	-- 确认场上是否存在符合条件的对方怪兽
	if chk==0 then return Duel.IsExistingTarget(c51119924.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上的1只符合条件的怪兽
	local g=Duel.SelectTarget(tp,c51119924.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，确定将要改变控制权的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 获得选中怪兽的控制权直到结束阶段
function c51119924.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRace(RACE_WARRIOR+RACE_SPELLCASTER) then
		-- 将目标怪兽的控制权交给玩家，持续到结束阶段
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
