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
-- 过滤函数，用于筛选满足条件的「圣剑」装备魔法卡（类型为装备魔法、种族为圣剑、可以送去墓地）
function c30575681.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(0x207a) and c:IsAbleToGrave()
end
-- 效果处理时的判断函数，检查是否满足发动条件（卡组中存在符合条件的「圣剑」装备魔法卡）
function c30575681.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件（卡组中存在符合条件的「圣剑」装备魔法卡）
	if chk==0 then return Duel.IsExistingMatchingCard(c30575681.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定效果处理时会将1张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并把符合条件的「圣剑」装备魔法卡送去墓地
function c30575681.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「圣剑」装备魔法卡
	local g=Duel.SelectMatchingCard(tp,c30575681.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选场上已装备怪兽的「圣剑」装备魔法卡（拥有装备对象，并且存在可以装备的怪兽）
function c30575681.eqfilter1(c)
	return c:IsSetCard(0x207a) and c:GetEquipTarget()
		-- 检查是否存在可以装备该装备魔法卡的怪兽
		and Duel.IsExistingTarget(c30575681.eqfilter2,0,LOCATION_MZONE,LOCATION_MZONE,1,c:GetEquipTarget(),c)
end
-- 过滤函数，用于筛选可以装备「圣剑」装备魔法卡的怪兽（必须表侧表示且能装备该装备魔法卡）
function c30575681.eqfilter2(c,ec)
	return c:IsFaceup() and ec:CheckEquipTarget(c)
end
-- 效果处理时的判断函数，选择目标装备魔法卡和目标怪兽
function c30575681.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否满足发动条件（场上存在符合条件的「圣剑」装备魔法卡）
	if chk==0 then return Duel.IsExistingTarget(c30575681.eqfilter1,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择效果的对象（装备魔法卡）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标装备魔法卡
	local g1=Duel.SelectTarget(tp,c30575681.eqfilter1,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	local tc=g1:GetFirst()
	e:SetLabelObject(tc)
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	local g2=Duel.SelectTarget(tp,c30575681.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc:GetEquipTarget(),tc)
end
-- 效果处理函数，将装备魔法卡转移给目标怪兽
function c30575681.eqop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	-- 获取当前连锁处理的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==ec then tc=g:GetNext() end
	if ec:IsFaceup() and ec:IsRelateToEffect(e) and ec:CheckEquipTarget(tc) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将装备魔法卡装备给目标怪兽
		Duel.Equip(tp,ec,tc)
	end
end
