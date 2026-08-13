--フリント・アタック
-- 效果：
-- 把有「打火石」装备的1只怪兽破坏。发动后这张卡被送去墓地时，这张卡可以回到卡组。
function c16437822.initial_effect(c)
	-- 对应效果原文‘把有「打火石」装备的1只怪兽破坏。’：创建并注册卡的发动效果（类型为魔陷发动、自由时点、取对象），并设定其目标选择与效果处理函数。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c16437822.target)
	e1:SetOperation(c16437822.activate)
	c:RegisterEffect(e1)
	-- 对应效果原文‘发动后这张卡被送去墓地时，这张卡可以回到卡组。’：创建并注册这张卡的诱发选发效果（送去墓地时触发，可返回卡组）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16437822,0))  --"返回卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c16437822.retcon)
	e2:SetTarget(c16437822.rettg)
	e2:SetOperation(c16437822.retop)
	c:RegisterEffect(e2)
	-- 对应效果原文‘发动后这张卡被送去墓地时’：设置一个不可无效的连续辅助效果，在卡离场前确认其是否处于‘连锁处理完后被送去墓地’的状态，为回卡组效果的正确时点提供判断依据。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c16437822.checkop)
	c:RegisterEffect(e3)
	e2:SetLabelObject(e3)
end
-- 筛选场上怪兽：该怪兽装备区存在卡号75560629的「打火石」装备卡（即装备有「打火石」的怪兽）。
function c16437822.filter(c)
	return c:GetEquipCount()~=0 and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,75560629)
end
-- 目标选择主函数：若chkc存在（卡片被指定为对象时的合法性确认），要求对象位于怪兽区且装备有「打火石」；若chk==0，则确认存在合法目标；随后提示玩家选择1只装备有「打火石」的怪兽，并设定破坏1张卡的操作信息。
function c16437822.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c16437822.filter(chkc) end
	-- 发动合法性检查：确认双方场上存在至少1只装备有「打火石」的怪兽可供选择作为对象。
	if chk==0 then return Duel.IsExistingTarget(c16437822.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向当前玩家显示‘请选择要破坏的卡’的提示，使用破坏专用选择消息类型，使玩家从可选择对象中进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 由当前玩家从双方场上选择1只装备有「打火石」的怪兽，并将其设置为这张卡的效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c16437822.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记当前连锁的操作信息：将以效果破坏所选择的对象1张卡，供后续相关卡牌效果（如星尘龙等）进行判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的实际处理：从连锁中获取对象怪兽，若该怪兽仍在场上、表侧表示且与效果仍有关联，则将其破坏。
function c16437822.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这张卡发动时选择的对象怪兽（即作为破坏对象的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 辅助连续效果的操作：在这张卡离开场上之前，检查其是否带有‘处理完毕后将被送去墓地’的状态（即确定因效果发动而会送去墓地），将结果记录到标签中（1/0）。
function c16437822.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_LEAVE_CONFIRMED) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 回卡组效果的发动条件：要求辅助效果记录过标签为1，即这张卡确实是在发动后被送去墓地（连锁处理结束后进入墓地），满足‘发动后这张卡被送去墓地时’的时点。
function c16437822.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
-- 回卡组效果的发动前准备：确认这张卡可以送去卡组，并设置将其返回卡组的操作信息。
function c16437822.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 登记当前连锁的操作信息：将这张卡自身返回持有者卡组，用于后续如‘王家长眠之谷’等效果的互动判定。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 回卡组效果的实际处理：若这张卡仍与当前效果有关联，则将其返回持有者卡组并重新洗切。
function c16437822.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以‘返回卡组并洗牌’的方式送往持有者卡组，并触发卡组洗切。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
