--硫酸のたまった落とし穴
-- 效果：
-- ①：以场上1只里侧守备表示怪兽为对象才能发动。那只怪兽变成表侧守备表示，守备力是2000以下的场合破坏。守备力比2000高的场合回到里侧守备表示。
function c41356845.initial_effect(c)
	-- ①：以场上1只里侧守备表示怪兽为对象才能发动。那只怪兽变成表侧守备表示，守备力是2000以下的场合破坏。守备力比2000高的场合回到里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c41356845.target)
	e1:SetOperation(c41356845.activate)
	c:RegisterEffect(e1)
end
-- 筛选符合条件的对象：怪兽必须是里侧守备表示。
function c41356845.filter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE)
end
-- 目标选择处理函数：发动时选择场上1只里侧守备表示怪兽作为对象，并登记变更表示形式的操作信息。
function c41356845.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c41356845.filter(chkc) end
	-- 发动合法性判定：确认场上存在至少1只里侧守备表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c41356845.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择提示信息，用于目标选择界面显示提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方主要怪兽区选择1只里侧守备表示怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c41356845.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 将‘变更表示形式’的操作信息登记到当前连锁，供效果处理及相关判定使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理：将对象怪兽变为表侧守备表示；若其守备力为2000以下则破坏，若高于2000则确认后变回里侧守备表示。
function c41356845.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与该效果关联，且已成功变为表侧守备表示，才继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
		if tc:IsDefenseBelow(2000) then
			-- 中断当前效果处理，使后续的破坏处理与变更表示形式分开，避免视为同时处理。
			Duel.BreakEffect()
			-- 将该怪兽破坏，破坏原因为效果。
			Duel.Destroy(tc,REASON_EFFECT)
		else
			-- 向对方玩家确认该怪兽，用于守备力高于2000时变回里侧前的展示。
			Duel.ConfirmCards(1-tc:GetControler(),tc)
			-- 将对象怪兽变回里侧守备表示。
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end
