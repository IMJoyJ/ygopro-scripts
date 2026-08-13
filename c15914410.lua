--機装天使エンジネル
-- 效果：
-- 3星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择自己场上表侧攻击表示存在的1只怪兽才能发动。选择的怪兽变成表侧守备表示，这个回合那只怪兽不会被战斗以及卡的效果破坏。这个效果在对方回合也能发动。
function c15914410.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用任意2只等级3的怪兽叠放作为超量素材。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除，选择自己场上表侧攻击表示存在的1只怪兽才能发动。选择的怪兽变成表侧守备表示，这个回合那只怪兽不会被战斗以及卡的效果破坏。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15914410,0))  --"破坏耐性"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c15914410.poscost)
	e1:SetTarget(c15914410.postg)
	e1:SetOperation(c15914410.posop)
	c:RegisterEffect(e1)
end
-- 代价处理：发动前先检查能否移除这张卡上的1个超量素材作为代价，确认后实际移除1个超量素材。
function c15914410.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：卡必须是我方场上表侧攻击表示，并且能够变更表示形式。
function c15914410.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 目标选择与合法性校验：若指定对象则检查其是否仍符合条件；发动时从自己场上选择1只表侧攻击表示且能变更表示形式的怪兽作为对象。
function c15914410.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c15914410.filter(chkc) end
	-- 发动合法性检查：自己场上是否存在至少1只满足过滤条件的表侧攻击表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c15914410.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示选择提示，要求从表侧攻击表示的怪兽中选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 让操作玩家从自己场上选择1只满足条件的表侧攻击表示怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,c15914410.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：将对象怪兽变为表侧守备表示，并赋予其本回合内不会被战斗或卡的效果破坏的耐性。
function c15914410.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式变为表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		-- 这个回合那只怪兽不会被战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
