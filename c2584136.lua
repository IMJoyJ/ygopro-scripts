--シャクトパス
-- 效果：
-- 这张卡被和对方怪兽的战斗破坏送去墓地时，可以把这张卡当作装备卡使用给那只对方怪兽装备。用这个效果把这张卡装备的怪兽攻击力变成0，不能把表示形式变更。
function c2584136.initial_effect(c)
	-- 这张卡被和对方怪兽的战斗破坏送去墓地时，可以把这张卡当作装备卡使用给那只对方怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2584136,0))  --"装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c2584136.eqcon)
	e1:SetOperation(c2584136.eqop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：自身因战斗被破坏后位于墓地，攻击怪兽为对方怪兽（rp==1-tp），且战斗对象怪兽仍表侧表示并和本次战斗关联。
function c2584136.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and rp==1-tp
		and bc:IsFaceup() and bc:IsRelateToBattle()
end
-- 装备限制函数：仅允许这张章鲛作为装备卡装备给原来的战斗对象怪兽（e:GetOwner()即该对象怪兽）。
function c2584136.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理：先确认魔陷区有空位，再确认章鲛仍在墓地且效果关联、战斗对象仍表侧且与战斗关联；成功后执行装备，并给章鲛附加装备限制、攻击力变0、不能变更表示形式的永续效果。
function c2584136.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若我方魔陷区没有可用区域，则无法进行装备，结束处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=c:GetBattleTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToBattle() then
		-- 将章鲛作为装备卡装备给战斗对象怪兽tc。
		Duel.Equip(tp,c,tc)
		-- 给那只对方怪兽装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c2584136.eqlimit)
		c:RegisterEffect(e1)
		-- 用这个效果把这张卡装备的怪兽攻击力变成0。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_ATTACK)
		e2:SetValue(0)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 不能把表示形式变更。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	end
end
