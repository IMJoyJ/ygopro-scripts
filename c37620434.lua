--デーモン・テイマー
-- 效果：
-- 反转：在回合结束前得到对方场上的1只表侧表示存在的恶魔族怪兽。
function c37620434.initial_effect(c)
	-- 反转：在回合结束前得到对方场上的1只表侧表示存在的恶魔族怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37620434,0))  --"控制权转移"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c37620434.target)
	e1:SetOperation(c37620434.operation)
	c:RegisterEffect(e1)
end
-- 定义选择对象的过滤器：对方场上的表侧表示恶魔族怪兽，且尚未受到“不能改变控制权”效果影响的卡才能被选择。
function c37620434.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and c:IsAbleToChangeControler()
end
-- 发动时的对象选择处理：若在连锁处理前进行合法性检查则只判断是否能发动；若不取对象则直接返回可发动；随后提示玩家选择，从对方场上选择1只符合条件的表侧表示恶魔族怪兽作为对象，并设置操作信息为改变控制权。
function c37620434.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c37620434.filter(chkc) end
	if chk==0 then return true end
	-- 向操作玩家显示“请选择要改变控制权的怪兽”的选择提示，用于卡片选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方场上（LOCATION_MZONE）选择1只满足filter的怪兽作为效果对象，同时将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c37620434.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的操作信息为“改变控制权”，对象为已选择的怪兽，数量为1，持有者/位置参数为0（表示不确定或默认）。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理时的操作：取得对象卡；若对象仍与效果关联且仍在对方场上表侧表示并仍为恶魔族，则将其控制权在结束阶段前转移给发动玩家。
function c37620434.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果发动时选择的对象怪兽（通常只有1只）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRace(RACE_FIEND) then
		-- 在结束阶段到来前将对象怪兽的控制权转移给发动方玩家（PHASE_END,1表示直到1次结束阶段为止）。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
