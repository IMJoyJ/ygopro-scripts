--スカラベの大群
-- 效果：
-- 这张卡1个回合可以有1次变回里侧守备表示。这张卡反转召唤成功时，破坏对方场上1只怪兽。
function c15383415.initial_effect(c)
	-- 这张卡1个回合可以有1次变回里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15383415,0))  --"变成里侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c15383415.target)
	e1:SetOperation(c15383415.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转召唤成功时，破坏对方场上1只怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15383415,1))  --"破坏对方1只怪兽"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c15383415.destg)
	e2:SetOperation(c15383415.desop)
	c:RegisterEffect(e2)
end
-- 该目标函数在检查阶段返回此卡能否变为里侧守备表示且本回合未使用过该效果；在发动阶段登记本回合已使用该效果，并设置变更表示形式的操作信息。
function c15383415.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(15383415)==0 end
	c:RegisterFlagEffect(15383415,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息，表明效果处理时将把此卡（数量1）的表示形式变更为里侧守备表示。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理：若此卡仍与效果相关且为表侧表示，则将其变更为里侧守备表示。
function c15383415.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡变更为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 破坏效果的目标选择处理：从对方场上选择1只怪兽作为对象，并设置破坏的操作信息。
function c15383415.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只怪兽（不限表示形式）作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，登记将破坏所选择的怪兽（数量为g中的卡数）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 处理破坏效果：若对象怪兽仍与效果相关，则将该怪兽破坏。
function c15383415.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
