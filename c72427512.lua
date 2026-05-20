--擬態する人喰い虫
-- 效果：
-- ①：这张卡反转的场合，以场上1只怪兽为对象发动。那只怪兽破坏，这张卡的攻击力上升那个原本攻击力数值。那之后，可以把这张卡的种族变成和破坏的怪兽的原本种族相同。
-- ②：场上的这张卡不会被战斗破坏，也不会被和这张卡相同种族的怪兽的效果破坏。
function c72427512.initial_effect(c)
	-- ①：这张卡反转的场合，以场上1只怪兽为对象发动。那只怪兽破坏，这张卡的攻击力上升那个原本攻击力数值。那之后，可以把这张卡的种族变成和破坏的怪兽的原本种族相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72427512,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c72427512.destg)
	e1:SetOperation(c72427512.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(c72427512.efilter)
	c:RegisterEffect(e3)
end
-- ①号效果的发动阶段处理（检查对象、提示选择并设置破坏操作信息）
function c72427512.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	-- 给玩家发送选择要破坏的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为破坏该怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①号效果的执行阶段处理（破坏对象、上升攻击力，并可选改变自身种族）
function c72427512.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍对应效果，若成功将其破坏，且自身仍在场上表侧表示存在，则继续处理
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=tc:GetBaseAttack()
		if atk<=0 then return end
		local race=tc:GetOriginalRace()
		-- 这张卡的攻击力上升那个原本攻击力数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 若自身种族与破坏怪兽的原本种族不同，则询问玩家是否选择改变种族
		if not c:IsRace(race) and Duel.SelectYesNo(tp,aux.Stringid(72427512,1)) then  --"是否改变种族？"
			-- 中断当前效果处理，使后续的改变种族处理不与破坏、上升攻击力同时发生
			Duel.BreakEffect()
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CHANGE_RACE)
			e2:SetValue(race)
			c:RegisterEffect(e2)
		end
	end
end
-- 免疫效果破坏的过滤器，判断发动效果的怪兽种族是否与自身相同
function c72427512.efilter(e,re,rp)
	if not re:IsActiveType(TYPE_MONSTER) then return false end
	local rc=re:GetHandler()
	if (re:IsActivated() and rc:IsRelateToEffect(re) or not re:IsHasProperty(EFFECT_FLAG_FIELD_ONLY))
		and (rc:IsFaceup() or not rc:IsLocation(LOCATION_MZONE)) then
		return e:GetHandler():IsRace(rc:GetRace())
	else
		return e:GetHandler():IsRace(rc:GetOriginalRace())
	end
end
