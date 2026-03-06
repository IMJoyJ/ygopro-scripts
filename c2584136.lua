--シャクトパス
-- 效果：
-- 这张卡被和对方怪兽的战斗破坏送去墓地时，可以把这张卡当作装备卡使用给那只对方怪兽装备。用这个效果把这张卡装备的怪兽攻击力变成0，不能把表示形式变更。
function c2584136.initial_effect(c)
	-- 效果原文：这张卡被和对方怪兽的战斗破坏送去墓地时，可以把这张卡当作装备卡使用给那只对方怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2584136,0))  --"装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c2584136.eqcon)
	e1:SetOperation(c2584136.eqop)
	c:RegisterEffect(e1)
end
-- 效果作用：检查触发条件，确认此卡在战斗破坏时进入墓地且战斗对象为对方表侧表示怪兽。
function c2584136.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and rp==1-tp
		and bc:IsFaceup() and bc:IsRelateToBattle()
end
-- 效果作用：限制装备对象，只能装备给拥有此效果的卡。
function c2584136.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果作用：执行装备操作，将此卡装备给对方怪兽并设置其装备限制、攻击力变为0及不能改变表示形式。
function c2584136.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：判断装备区域是否足够，若无则不执行装备。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=c:GetBattleTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToBattle() then
		-- 效果作用：将此卡作为装备卡装备给对方怪兽。
		Duel.Equip(tp,c,tc)
		-- 效果原文：用这个效果把这张卡装备的怪兽攻击力变成0，不能把表示形式变更。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c2584136.eqlimit)
		c:RegisterEffect(e1)
		-- 效果原文：用这个效果把这张卡装备的怪兽攻击力变成0，不能把表示形式变更。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_ATTACK)
		e2:SetValue(0)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 效果原文：用这个效果把这张卡装备的怪兽攻击力变成0，不能把表示形式变更。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	end
end
