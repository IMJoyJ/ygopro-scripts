--惑星からの物体A
-- 效果：
-- 向场上表侧攻击表示存在的这张卡攻击的怪兽的控制权在战斗阶段结束时得到。
function c14729426.initial_effect(c)
	-- 向场上表侧攻击表示存在的这张卡攻击的怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14729426,0))  --"得到控制权"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetOperation(c14729426.operation)
	c:RegisterEffect(e1)
end
-- 当这张卡成为攻击对象且为表侧攻击表示时，将攻击怪兽记录到临时效果中，并注册一个在战斗阶段结束时必定发动、获得该怪兽控制权的效果。
function c14729426.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断条件：这张卡正是当前被攻击的表侧攻击表示怪兽。
	if e:GetHandler()==Duel.GetAttackTarget() and e:GetHandler():IsAttackPos() then
		-- 获取本次战斗的攻击怪兽，作为之后要夺取控制权的对象。
		local a=Duel.GetAttacker()
		-- 的控制权在战斗阶段结束时得到。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(14729426,0))  --"得到控制权"
		e1:SetCategory(CATEGORY_CONTROL)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e1:SetCountLimit(1)
		e1:SetTarget(c14729426.cttg)
		e1:SetOperation(c14729426.ctop)
		e1:SetLabelObject(a)
		e1:SetLabel(a:GetRealFieldID())
		e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		-- 将战斗阶段结束时获得控制权的效果注册给当前玩家tp，使其在场上的全局范围内生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 战斗阶段结束时触发效果的发动条件：确认记录的怪兽仍在对方场上且未因离场等原因重置时，将其设为效果对象并声明控制权变更的操作信息。
function c14729426.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local a=e:GetLabelObject()
	if a:IsControler(1-tp) and a:GetRealFieldID()==e:GetLabel() then
		-- 将记录的怪兽a设定为当前连锁的效果对象。
		Duel.SetTargetCard(a)
		-- 设置操作信息，声明此效果将对象a的控制权转移，类别为CATEGORY_CONTROL。
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,a,1,0,0)
	end
end
-- 战斗阶段结束时效果的处理：取得先前记录的目标怪兽，若其仍与效果关联，则将其控制权转移给当前玩家tp。
function c14729426.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该效果记录的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 让当前玩家tp获得目标怪兽的控制权。
		Duel.GetControl(tc,tp)
	end
end
