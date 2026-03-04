--ミュータント・ハイブレイン
-- 效果：
-- ①：对方场上有怪兽2只以上存在的场合，这张卡的攻击宣言时，以对方场上1只表侧攻击表示怪兽为对象才能发动。那1只对方的表侧攻击表示怪兽的控制权直到战斗阶段结束时得到。作为对象的怪兽在这个回合不能直接攻击，在可以攻击的场合，选1只对方怪兽作为攻击对象进行伤害计算。
function c11508758.initial_effect(c)
	-- 创建一个诱发选发效果，用于在攻击宣言时发动，效果描述为“获得控制权”，分类为改变控制权，具有取对象属性，类型为单体诱发效果，触发时机为攻击宣言时，条件为对方场上有2只以上怪兽存在，目标为对方场上的1只表侧攻击表示怪兽，效果处理为改变该怪兽的控制权并使其本回合不能直接攻击，若可攻击则选择对方怪兽进行伤害计算。
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
-- 判断效果发动的条件，即对方场上有怪兽2只以上存在。
function c11508758.ctlcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方场上有怪兽2只以上存在且攻击目标不为空。
	return Duel.GetAttackTarget()~=nil and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=2
end
-- 定义用于筛选目标怪兽的过滤函数，筛选条件为表侧攻击表示、可以改变控制权、可以攻击。
function c11508758.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsControlerCanBeChanged() and c:IsAttackable()
end
-- 定义效果的目标选择函数，用于选择对方场上的1只表侧攻击表示怪兽作为对象。
function c11508758.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 当chkc不为空时，判断该卡是否满足目标条件，即在主要怪兽区、对方控制、不是当前攻击目标且满足过滤条件。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc~=Duel.GetAttackTarget() and c11508758.filter(chkc) end
	-- 当chk为0时，判断对方场上有满足条件的怪兽存在。
	if chk==0 then return Duel.IsExistingTarget(c11508758.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	-- 选择满足条件的对方怪兽作为目标。
	local g=Duel.SelectTarget(tp,c11508758.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示将要改变目标怪兽的控制权。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 定义效果的处理函数，用于执行效果处理逻辑。
function c11508758.ctlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsPosition(POS_FACEUP_ATTACK) and tc:IsControler(1-tp) then
		-- 尝试获得目标怪兽的控制权，直到战斗阶段结束。
		if Duel.GetControl(tc,tp,PHASE_BATTLE,1)~=0 then
			-- 效果原文内容：作为对象的怪兽在这个回合不能直接攻击。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			if tc:IsAttackable() and not tc:IsImmuneToEffect(e) then
				local ats=tc:GetAttackableTarget()
				if #ats==0 then return end
				-- 向玩家提示选择攻击对象。
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(11508758,1))  --"请选择攻击对象"
				local g=ats:Select(tp,1,1,nil)
				-- 令目标怪兽与选择的对方怪兽进行伤害计算。
				Duel.CalculateDamage(tc,g:GetFirst())
			end
		end
	end
end
