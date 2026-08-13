--ミュータント・ハイブレイン
-- 效果：
-- ①：对方场上有怪兽2只以上存在的场合，这张卡的攻击宣言时，以对方场上1只表侧攻击表示怪兽为对象才能发动。那1只对方的表侧攻击表示怪兽的控制权直到战斗阶段结束时得到。作为对象的怪兽在这个回合不能直接攻击，在可以攻击的场合，选1只对方怪兽作为攻击对象进行伤害计算。
function c11508758.initial_effect(c)
	-- ①：对方场上有怪兽2只以上存在的场合，这张卡的攻击宣言时，以对方场上1只表侧攻击表示怪兽为对象才能发动。那1只对方的表侧攻击表示怪兽的控制权直到战斗阶段结束时得到。作为对象的怪兽在这个回合不能直接攻击，在可以攻击的场合，选1只对方怪兽作为攻击对象进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11508758,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c11508758.ctlcon)
	e1:SetTarget(c11508758.ctltg)
	e1:SetOperation(c11508758.ctlop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：攻击宣言时存在攻击对象，且对方场上的怪兽数量≥2，满足①的发动前提。
function c11508758.ctlcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前攻击目标不为空，且对方场上怪兽数量不小于2。
	return Duel.GetAttackTarget()~=nil and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=2
end
-- 对象筛选：必须是对方场上表侧攻击表示、控制权可以被改变且可以攻击的怪兽。
function c11508758.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsControlerCanBeChanged() and c:IsAttackable()
end
-- 发动时的目标处理：检查是否存在合法对象，向玩家提示选择后，选择1只满足条件的对方怪兽作为效果对象，并登记改变控制权的操作信息。
function c11508758.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 对象合法性校验：对象必须位于对方怪兽区、是表侧攻击表示、不是当前攻击对象，并且满足filter条件。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc~=Duel.GetAttackTarget() and c11508758.filter(chkc) end
	-- 合法性检查阶段：确认对方场上存在至少1只满足条件的表侧攻击表示怪兽可选。
	if chk==0 then return Duel.IsExistingTarget(c11508758.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家显示选择提示，要求选择要改变控制权的那1只对方怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方场上选择1只满足filter的表侧攻击表示怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c11508758.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的操作信息为“改变控制权”，对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：若对象仍合法且仍为对方表侧攻击怪兽，则夺取其控制权直到战斗阶段结束；成功后给该怪兽附加不能直接攻击的效果；若该怪兽可以攻击且不免疫此效果，则令其选择对方1只怪兽作为攻击对象进行伤害计算。
function c11508758.ctlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsPosition(POS_FACEUP_ATTACK) and tc:IsControler(1-tp) then
		-- 尝试夺取对象怪兽的控制权，持续到战斗阶段结束（PHASE_BATTLE），成功则返回值非0，继续后续处理。
		if Duel.GetControl(tc,tp,PHASE_BATTLE,1)~=0 then
			-- 作为对象的怪兽在这个回合不能直接攻击。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			if tc:IsAttackable() and not tc:IsImmuneToEffect(e) then
				local ats=tc:GetAttackableTarget()
				if #ats==0 then return end
				-- 提示玩家为获得控制权的对象怪兽选择1只攻击对象。
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(11508758,1))  --"请选择攻击对象"
				local g=ats:Select(tp,1,1,nil)
				-- 让对象怪兽对所选对方怪兽进行强制战斗伤害计算，对应“作为攻击对象进行伤害计算”。
				Duel.CalculateDamage(tc,g:GetFirst())
			end
		end
	end
end
