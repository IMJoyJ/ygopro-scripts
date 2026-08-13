--古代の機械爆弾
-- 效果：
-- 把自己场上表侧表示存在的1只名字带有「古代的机械」的怪兽作为对象才能发动。对象的怪兽破坏，给与对方基本分那只怪兽的原本攻击力一半数值的伤害。
function c4446672.initial_effect(c)
	-- 把自己场上表侧表示存在的1只名字带有「古代的机械」的怪兽作为对象才能发动。对象的怪兽破坏，给与对方基本分那只怪兽的原本攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c4446672.target)
	e1:SetOperation(c4446672.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选出自己场上表侧表示且卡名带有「古代的机械」的怪兽，作为可选择的对象。
function c4446672.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x7)
end
-- 发动时的目标处理：检查是否能选择合法对象，提示并选择对象，同时设置破坏与伤害的处理信息。
function c4446672.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c4446672.filter(chkc) end
	-- 发动时点检查：确认场上是否存在至少1只满足条件的表侧表示「古代的机械」怪兽，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c4446672.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作者显示选择提示信息“请选择要破坏的卡”，用于后续选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上表侧表示的「古代的机械」怪兽中选择1张作为效果对象，并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c4446672.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次效果将破坏选择的那1张卡，破坏对象为已选对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本次效果将给对方造成伤害，伤害数值在处理时确定，因此对象暂为空，目标玩家为对方，分类为伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果处理函数：取得对象卡，若对象仍与效果关联，则将其破坏；破坏成功后再给予对方原本攻击力一半数值的伤害。
function c4446672.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡；若实际破坏成功（返回值大于0），才继续执行伤害处理。
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			-- 给予对方玩家那只怪兽原本攻击力一半数值的伤害（向下取整），伤害原因为效果。
			Duel.Damage(1-tp,math.floor(tc:GetBaseAttack()/2),REASON_EFFECT)
		end
	end
end
