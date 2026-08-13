--破壊指輪
-- 效果：
-- 破坏自己场上1只表侧表示的怪兽，双方各受1000点伤害。
function c21219755.initial_effect(c)
	-- 破坏自己场上1只表侧表示的怪兽，双方各受1000点伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c21219755.target)
	e1:SetOperation(c21219755.activate)
	c:RegisterEffect(e1)
end
-- 定义表侧表示怪兽的筛选条件：对象必须为表侧表示。
function c21219755.filter(c)
	return c:IsFaceup()
end
-- 目标处理：检查自己场上是否存在表侧表示怪兽可供选择；若存在，则选择自己场上1只表侧表示怪兽作为破坏对象，并登记破坏与伤害的操作信息。
function c21219755.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21219755.filter(chkc) end
	-- 发动时点检查：确认自己场上是否存在至少1只可被选择为对象的表侧表示怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c21219755.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示，要求玩家选择要破坏的卡片（提示文案为“请选择要破坏的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1只表侧表示怪兽，并将其登记为本效果的对象。
	local g=Duel.SelectTarget(tp,c21219755.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记连锁操作信息：本连锁将破坏所选择的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记连锁操作信息：本连锁将对双方各造成1000点伤害，对象待定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
-- 效果处理：取得发动时选择的目标，若其仍表侧表示且与效果存在联系，则将其破坏；破坏成功后，给对方玩家造成1000点伤害，再给自己玩家造成1000点伤害，并完成伤害/恢复过程的时点处理。
function c21219755.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动效果时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该目标怪兽；若破坏成功，才执行后续伤害处理。
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			-- 给对方玩家造成1000点效果伤害，并作为伤害/恢复过程的一步。
			Duel.Damage(1-tp,1000,REASON_EFFECT,true)
			-- 给自己玩家造成1000点效果伤害，并作为伤害/恢复过程的一步。
			Duel.Damage(tp,1000,REASON_EFFECT,true)
			-- 完成伤害/恢复过程的分解，触发对应时点，使连锁处理正确继续。
			Duel.RDComplete()
		end
	end
end
