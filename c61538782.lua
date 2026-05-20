--トラックロイド
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，把破坏怪兽当作装备卡使用给这张卡装备。这张卡的攻击力上升装备的怪兽卡的攻击力数值。
function c61538782.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽送去墓地时，把破坏怪兽当作装备卡使用给这张卡装备。这张卡的攻击力上升装备的怪兽卡的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61538782,0))  --"装备"
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCondition(c61538782.eqcon)
	e1:SetTarget(c61538782.eqtg)
	e1:SetOperation(c61538782.eqop)
	c:RegisterEffect(e1)
end
-- 检查自身是否与战斗关联且表侧表示，并确认被战斗破坏的怪兽已送去墓地且可以被装备。
function c61538782.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if not c:IsRelateToBattle() or c:IsFacedown() then return false end
	e:SetLabelObject(tc)
	return tc:IsLocation(LOCATION_GRAVE) and tc:IsType(TYPE_MONSTER) and tc:IsReason(REASON_BATTLE) and not tc:IsForbidden()
end
-- 效果发动的靶向处理，将被破坏的怪兽设为效果对象，并声明涉及移出墓地的操作信息。
function c61538782.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject()
	-- 将被战斗破坏的怪兽设置为当前连锁的效果处理对象。
	Duel.SetTargetCard(tc)
	-- 设置操作信息，表示该效果包含将1张墓地的卡移出墓地的操作。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
-- 效果处理，将被破坏的怪兽作为装备卡装备给自身，并使其攻击力上升该怪兽的攻击力数值。
function c61538782.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中设定的第一个效果对象（即被战斗破坏的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 尝试将被破坏的怪兽作为装备卡装备给自身，若装备失败则结束处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 把破坏怪兽当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c61538782.eqlimit)
		tc:RegisterEffect(e1)
		if atk>0 then
			-- 这张卡的攻击力上升装备的怪兽卡的攻击力数值。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk)
			tc:RegisterEffect(e2)
		end
	end
end
-- 定义装备限制，使该装备卡只能装备给这张卡自身。
function c61538782.eqlimit(e,c)
	return e:GetOwner()==c
end
