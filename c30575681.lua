--聖騎士ベディヴィエール
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把1张「圣剑」装备魔法卡送去墓地。
-- ②：只在这张卡在场上表侧表示存在才有1次，以场上1张「圣剑」装备魔法卡和1只可以把那张卡装备的怪兽为对象才能发动。那张装备魔法卡转移给作为正确对象的那只怪兽。这个效果在对方回合也能发动。
function c30575681.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把1张「圣剑」装备魔法卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30575681,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetTarget(c30575681.target)
	e1:SetOperation(c30575681.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只在这张卡在场上表侧表示存在才有1次，以场上1张「圣剑」装备魔法卡和1只可以把那张卡装备的怪兽为对象才能发动。那张装备魔法卡转移给作为正确对象的那只怪兽。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30575681,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c30575681.eqtg)
	e3:SetOperation(c30575681.eqop)
	c:RegisterEffect(e3)
end
-- 效果①的筛选条件：判定卡是「圣剑」装备魔法卡，且可以送去墓地。
function c30575681.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(0x207a) and c:IsAbleToGrave()
end
-- 效果①的发动条件和操作信息设置：召唤·特殊召唤成功时，若卡组存在符合条件的「圣剑」装备魔法卡则可发动，并登记送去墓地的处理信息。
function c30575681.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：确认卡组中是否存在至少1张满足条件的「圣剑」装备魔法卡可送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(c30575681.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次效果将把卡组的1张「圣剑」装备魔法卡送去墓地的操作信息，便于后续检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理：从卡组选择1张「圣剑」装备魔法卡送去墓地。
function c30575681.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家弹出选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1张满足条件的「圣剑」装备魔法卡。
	local g=Duel.SelectMatchingCard(tp,c30575681.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果②的装备魔法卡筛选条件：该卡必须是「圣剑」装备魔法卡且当前正装备着怪兽，并且场上存在另一只能够装备它的怪兽（作为转移目标）。
function c30575681.eqfilter1(c)
	return c:IsSetCard(0x207a) and c:GetEquipTarget()
		-- 确认场上怪兽区存在至少1只除当前装备对象外的表侧表示怪兽，可以作为这张「圣剑」装备魔法卡的正确装备对象。
		and Duel.IsExistingTarget(c30575681.eqfilter2,0,LOCATION_MZONE,LOCATION_MZONE,1,c:GetEquipTarget(),c)
end
-- 怪兽侧筛选条件：怪兽须为表侧表示，且这只「圣剑」装备魔法卡可以正确装备给它。
function c30575681.eqfilter2(c,ec)
	return c:IsFaceup() and ec:CheckEquipTarget(c)
end
-- 效果②取对象处理：选择场上1张「圣剑」装备魔法卡和1只能够装备它的怪兽作为对象，并记录被选择的装备卡。
function c30575681.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检查：确认场上存在至少1张满足条件的「圣剑」装备魔法卡，且它可以转移给其他怪兽。
	if chk==0 then return Duel.IsExistingTarget(c30575681.eqfilter1,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 向玩家弹出选择提示：请选择效果的对象（「圣剑」装备魔法卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1张符合条件的「圣剑」装备魔法卡作为效果对象。
	local g1=Duel.SelectTarget(tp,c30575681.eqfilter1,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	local tc=g1:GetFirst()
	e:SetLabelObject(tc)
	-- 向玩家弹出选择提示：请选择要装备的卡（接收装备的怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示且能够装备所选「圣剑」装备魔法卡的怪兽作为效果对象。
	local g2=Duel.SelectTarget(tp,c30575681.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc:GetEquipTarget(),tc)
end
-- 效果②处理：取回发动时选择的装备魔法卡和怪兽，在全部条件仍满足时，将装备魔法卡转移装备给那只怪兽。
function c30575681.eqop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	-- 获取本连锁记录的效果对象（装备魔法卡和怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==ec then tc=g:GetNext() end
	if ec:IsFaceup() and ec:IsRelateToEffect(e) and ec:CheckEquipTarget(tc) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将「圣剑」装备魔法卡装备给对象怪兽，完成装备转移。
		Duel.Equip(tp,ec,tc)
	end
end
