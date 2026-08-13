--ヴァイロン・ステラ
-- 效果：
-- 这张卡从怪兽卡区域上送去墓地的场合，可以支付500基本分，把这张卡当作装备卡使用给自己场上表侧表示存在的1只怪兽装备。和这张卡的装备怪兽进行战斗的对方怪兽在那次伤害步骤结束时破坏。
function c38679204.initial_effect(c)
	-- 这张卡从怪兽卡区域上送去墓地的场合，可以支付500基本分，把这张卡当作装备卡使用给自己场上表侧表示存在的1只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38679204,0))  --"当成装备卡装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c38679204.eqcon)
	e1:SetCost(c38679204.eqcost)
	e1:SetTarget(c38679204.eqtg)
	e1:SetOperation(c38679204.eqop)
	c:RegisterEffect(e1)
	-- 和这张卡的装备怪兽进行战斗的对方怪兽在那次伤害步骤结束时破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38679204,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c38679204.descon)
	e2:SetTarget(c38679204.destg)
	e2:SetOperation(c38679204.desop)
	c:RegisterEffect(e2)
end
-- 检查触发条件：这张卡从怪兽卡区域被送去墓地时，该效果才满足发动条件。
function c38679204.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 发动时需支付500基本分作为代价，并检查是否满足支付条件。
function c38679204.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动前检查当前玩家能否支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分作为发动代价。
	Duel.PayLPCost(tp,500)
end
-- 选择自己场上1只表侧表示怪兽作为装备对象，同时要求魔陷区有空位可以放置装备卡。
function c38679204.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己的魔陷区是否存在可用的空格，确保这张卡装备后有位置安置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在表侧表示怪兽可以作为装备对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示怪兽，并将其登记为这次效果的处理对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理时，若这张卡仍在墓地且选择的怪兽仍表侧表示且与效果关联，则将这张卡装备给那只怪兽，并给这张卡附加装备对象限制效果。
function c38679204.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时选择的那只装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将这张卡作为装备卡装备到对象怪兽上。
		Duel.Equip(tp,c,tc)
		-- 把这张卡当作装备卡使用给自己场上表侧表示存在的1只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c38679204.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 定义装备限制：只有这张卡的控制者场上的怪兽才能装备，防止装备到对方怪兽或非法对象。
function c38679204.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp)
end
-- 判定破坏效果的触发条件：装备怪兽参与了战斗，并且在伤害步骤结束时存在与之战斗的对方怪兽。
function c38679204.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return false end
	local dt=nil
	-- 若装备怪兽是攻击方，则把攻击对象（对方怪兽）作为将被破坏的卡。
	if ec==Duel.GetAttacker() then dt=Duel.GetAttackTarget()
	-- 若装备怪兽是被攻击方，则把攻击怪兽作为将被破坏的卡。
	elseif ec==Duel.GetAttackTarget() then dt=Duel.GetAttacker() end
	e:SetLabelObject(dt)
	return dt and dt:IsRelateToBattle()
end
-- 在发动时登记这次破坏效果的对象，并允许效果发动。
function c38679204.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，标明这次效果将破坏的对象（即与装备怪兽战斗的对方怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 效果处理时，若对方怪兽仍与本次战斗关联，则将其破坏。
function c38679204.desop(e,tp,eg,ep,ev,re,r,rp)
	local dt=e:GetLabelObject()
	if dt:IsRelateToBattle() then
		-- 对与装备怪兽战斗的对方怪兽执行破坏处理。
		Duel.Destroy(dt,REASON_EFFECT)
	end
end
