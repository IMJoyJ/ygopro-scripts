--惑星からの物体A
-- 效果：
-- 向场上表侧攻击表示存在的这张卡攻击的怪兽的控制权在战斗阶段结束时得到。
function c14729426.initial_effect(c)
	-- 向场上表侧攻击表示存在的这张卡攻击的怪兽的控制权在战斗阶段结束时得到。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14729426,0))  --"得到控制权"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetOperation(c14729426.operation)
	c:RegisterEffect(e1)
end
-- 效果处理函数开始
function c14729426.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击的怪兽是否为这张卡
	if e:GetHandler()==Duel.GetAttackTarget() and e:GetHandler():IsAttackPos() then
		-- 获取此次战斗的攻击怪兽
		local a=Duel.GetAttacker()
		-- 得到控制权
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
		-- 将效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 控制权变更效果的目标设定函数开始
function c14729426.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local a=e:GetLabelObject()
	if a:IsControler(1-tp) and a:GetRealFieldID()==e:GetLabel() then
		-- 设置当前处理的连锁的对象为攻击怪兽
		Duel.SetTargetCard(a)
		-- 设置当前处理的连锁的操作信息为改变控制权
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,a,1,0,0)
	end
end
-- 控制权变更效果的处理函数开始
function c14729426.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的处理对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽的控制权转移给指定玩家
		Duel.GetControl(tc,tp)
	end
end
