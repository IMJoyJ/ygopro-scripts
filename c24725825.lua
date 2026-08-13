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
-- 定义代价函数：发动前先检查这张卡是否可作为代价从手卡丢弃去墓地，若可以则在发动时实际将其丢弃去墓地。
function c24725825.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 以“代价+丢弃”的理由把这张卡从手卡送去墓地，完成代价支付。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 定义可选择对象的筛选条件：对象必须是表侧表示、种族为机械族或龙族、且控制权可以被改变。
function c24725825.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE+RACE_DRAGON) and c:IsControlerCanBeChanged()
end
-- 定义取对象目标函数：若在连锁处理时验证对象，则要求对象在对方场上且满足筛选；若在发动判定时，检查是否存在合法对象；然后提示玩家选择，选择对方场上1只符合条件的怪兽作为对象，并登记操作信息为改变控制权。
function c24725825.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c24725825.filter(chkc) end
	-- 发动合法性检查：确认对方场上有至少1只满足筛选条件、且可被取为对象的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c24725825.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向当前玩家显示选择提示，提示内容为“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让当前玩家从对方场上选择1只满足条件的表侧表示龙族或机械族怪兽作为效果对象，并自动将其登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c24725825.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将本次连锁的操作信息登记为“改变控制权”，对象为已选择的怪兽，数量为1，供其他卡片的响应和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 定义效果处理函数：取得效果处理时的对象，若对象仍与效果相关、仍为表侧表示且仍为龙族或机械族，则对其执行控制权转移。
function c24725825.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁处理时登记的第一只（也是唯一一只）效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRace(RACE_MACHINE+RACE_DRAGON) then
		-- 将那只怪兽的控制权转移给发动者tp，持续到结束阶段（PHASE_END），1次后效果结束，控制权归还。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
