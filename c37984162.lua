--ゴルゴニック・ゴーレム
-- 效果：
-- 这张卡被战斗破坏送去墓地时，让把这张卡破坏的怪兽的攻击力变成0。此外，自己的主要阶段时，把墓地的这张卡从游戏中除外，选择对方场上盖放的1张魔法·陷阱卡才能发动。这个回合，选择的卡不能发动。对方不能对应这个效果的发动把选择的卡发动。
function c37984162.initial_effect(c)
	-- 诱发效果：这张卡被战斗破坏送去墓地时，让把这张卡破坏的怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37984162,0))  --"攻击变成0"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c37984162.condition)
	e1:SetOperation(c37984162.operation)
	c:RegisterEffect(e1)
	-- 起动效果：自己的主要阶段时，把墓地的这张卡从游戏中除外，选择对方场上盖放的1张魔法·陷阱卡才能发动。这个回合，选择的卡不能发动。对方不能对应这个效果的发动把选择的卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37984162,1))  --"发动限制"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 将此卡从游戏中除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c37984162.distg)
	e2:SetOperation(c37984162.disop)
	c:RegisterEffect(e2)
end
-- 效果条件：这张卡在墓地且因战斗破坏，且破坏此卡的怪兽仍在场上
function c37984162.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		and e:GetHandler():GetReasonCard():IsRelateToBattle()
end
-- 效果处理：将破坏此卡的怪兽的攻击力变成0
function c37984162.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	if rc:IsFaceup() and rc:IsRelateToBattle() then
		-- 将攻击力变成0的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
	end
end
-- 选择对方场上的1张里侧表示的魔法·陷阱卡
function c37984162.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and chkc:IsFacedown() end
	-- 检查对方场上是否存在里侧表示的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择里侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 选择对方场上的1张里侧表示的魔法·陷阱卡
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,nil)
	-- 设置连锁限制，防止选择的卡发动
	Duel.SetChainLimit(c37984162.limit(g:GetFirst()))
end
-- 连锁限制函数，防止选择的卡发动
function c37984162.limit(c)
	return	function (e,lp,tp)
				return e:GetHandler()~=c
			end
end
-- 效果处理：使选择的卡在本回合不能发动
function c37984162.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 使目标卡不能发动效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
