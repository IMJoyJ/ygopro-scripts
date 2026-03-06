--H・C ウォー・ハンマー
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，可以把破坏的怪兽当作装备卡使用只有1只给这张卡装备。这张卡的攻击力上升这个效果装备的怪兽的攻击力数值。
function c26885836.initial_effect(c)
	-- 效果原文：这张卡战斗破坏对方怪兽送去墓地时，可以把破坏的怪兽当作装备卡使用只有1只给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26885836,0))  --"装备"
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCondition(c26885836.eqcon)
	e1:SetTarget(c26885836.eqtg)
	e1:SetOperation(c26885836.eqop)
	c:RegisterEffect(e1)
end
-- 效果作用：检测是否与对方怪兽战斗并破坏对方怪兽送去墓地，且被破坏的怪兽未被禁止使用。
function c26885836.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(tc)
	-- 效果原文：这张卡战斗破坏对方怪兽送去墓地时，可以把破坏的怪兽当作装备卡使用只有1只给这张卡装备。
	return aux.bdogcon(e,tp,eg,ep,ev,re,r,rp) and not tc:IsForbidden()
end
-- 效果作用：判断是否满足装备条件，即未装备过且场上魔陷区有空位。
function c26885836.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsHasEffect(26885836)
		-- 效果原文：这张卡战斗破坏对方怪兽送去墓地时，可以把破坏的怪兽当作装备卡使用只有1只给这张卡装备。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local tc=e:GetLabelObject()
	-- 效果作用：将被战斗破坏送去墓地的怪兽设置为连锁对象。
	Duel.SetTargetCard(tc)
	-- 效果作用：设置操作信息，表示将要处理被破坏送去墓地的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
-- 效果作用：执行装备操作，将怪兽装备给自身并设置装备限制和攻击力加成效果。
function c26885836.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：获取当前连锁的装备对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=tc:GetBaseAttack()
		if atk<0 then atk=0 end
		-- 效果作用：尝试将目标怪兽装备给自身，若失败则返回。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 效果原文：这张卡战斗破坏对方怪兽送去墓地时，可以把破坏的怪兽当作装备卡使用只有1只给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c26885836.eqlimit)
		tc:RegisterEffect(e1)
		if atk>0 then
			-- 效果原文：这张卡的攻击力上升这个效果装备的怪兽的攻击力数值。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk)
			tc:RegisterEffect(e2)
		end
		-- 效果原文：这张卡战斗破坏对方怪兽送去墓地时，可以把破坏的怪兽当作装备卡使用只有1只给这张卡装备。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(26885836)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end
-- 效果作用：限制该装备卡只能装备给自身
function c26885836.eqlimit(e,c)
	return e:GetOwner()==c
end
