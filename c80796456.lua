--No.70 デッドリー・シン
-- 效果：
-- 4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽直到下次的对方准备阶段除外。
-- ②：这张卡攻击的伤害步骤结束时才能发动。这张卡的攻击力上升300，阶级上升3阶。
function c80796456.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽2只
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽直到下次的对方准备阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80796456,0))  --"对方怪兽除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c80796456.rmcost)
	e1:SetTarget(c80796456.rmtg)
	e1:SetOperation(c80796456.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡攻击的伤害步骤结束时才能发动。这张卡的攻击力上升300，阶级上升3阶。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80796456,1))  --"这张卡攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c80796456.atkcon)
	e2:SetOperation(c80796456.atkop)
	c:RegisterEffect(e2)
end
-- 设置该怪兽的“No.”编号为70
aux.xyz_number[80796456]=70
-- 效果①的COST：取除这张卡的1个超量素材
function c80796456.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的TARGET：选择对方场上1只怪兽作为对象，并设置操作信息
function c80796456.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方场上是否存在可以除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只可以除外的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为除外选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的OPERATION：将对象怪兽暂时除外，并注册在下次对方准备阶段返回场上的效果
function c80796456.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用于此效果，则将其暂时除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(80796456,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN,0,1)
		-- 那只怪兽直到下次的对方准备阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c80796456.retcon)
		e1:SetOperation(c80796456.retop)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN)
		-- 注册在准备阶段将怪兽返回场上的效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟效果的Condition：必须是对方的回合，且该怪兽的标记效果依然存在
function c80796456.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合是否为对方回合，且被除外怪兽的标记依然有效
	return Duel.GetTurnPlayer()~=tp and e:GetLabelObject():GetFlagEffect(80796456)~=0
end
-- 延迟效果的Operation：将被除外的怪兽返回场上
function c80796456.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将被暂时除外的怪兽返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
-- 效果②的Condition：这张卡进行过攻击，且在伤害步骤结束时仍在场上
function c80796456.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽是否为自身，且自身仍与战斗相关联
	return Duel.GetAttacker()==e:GetHandler() and e:GetHandler():IsRelateToBattle()
end
-- 效果②的Operation：使这张卡的攻击力上升300，阶级上升3阶
function c80796456.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升300
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 阶级上升3阶
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_RANK)
		e2:SetValue(3)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e2)
	end
end
