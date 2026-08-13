--華麗なる密偵－C
-- 效果：
-- ①：这张卡召唤成功的场合发动。从对方的额外卡组随机1张确认。攻击力2000以上的怪兽的场合，这张卡的攻击力上升1000。攻击力未满2000的怪兽的场合，自己基本分回复那个攻击力的数值。
function c21088856.initial_effect(c)
	-- ①：这张卡召唤成功的场合发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21088856,0))  --"确认额外卡组"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c21088856.operation)
	c:RegisterEffect(e1)
end
-- 效果处理：从对方额外卡组随机确认1张，根据其攻击力决定提升自身攻击力或回复LP，并洗切对方额外卡组。
function c21088856.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组的全部卡片。
	local g=Duel.GetFieldGroup(1-tp,LOCATION_EXTRA,0)
	if g:GetCount()==0 then return end
	-- 洗切对方额外卡组。
	Duel.ShuffleExtra(1-tp)
	local tc=g:RandomSelect(tp,1):GetFirst()
	-- 向发动者展示被随机选中的额外卡组卡片。
	Duel.ConfirmCards(tp,tc)
	local atk=tc:GetAttack()
	if atk<0 then atk=0 end
	if atk>=2000 then
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		-- 攻击力2000以上的怪兽的场合，这张卡的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	else
		-- 让发动者回复那只怪兽攻击力数值的LP，对应攻击力未满2000的场合。
		Duel.Recover(tp,atk,REASON_EFFECT)
	end
	-- 最后再次洗切对方额外卡组，恢复随机顺序。
	Duel.ShuffleExtra(1-tp)
end
