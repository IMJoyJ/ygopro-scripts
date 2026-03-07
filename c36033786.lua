--サイバース・ウィザード
-- 效果：
-- ①：1回合1次，以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。这个效果变成守备表示的回合，自己怪兽只能向作为对象的怪兽攻击，自己的电子界族怪兽向作为对象的守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c36033786.initial_effect(c)
	-- 效果原文内容：①：1回合1次，以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetDescription(aux.Stringid(36033786,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c36033786.postg)
	e1:SetOperation(c36033786.posop)
	c:RegisterEffect(e1)
end
-- 效果作用：筛选出处于表侧攻击表示且可以改变表示形式的怪兽
function c36033786.posfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 效果作用：选择对方场上的1只攻击表示怪兽作为对象
function c36033786.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c36033786.posfilter(chkc) end
	-- 效果作用：判断是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c36033786.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 效果作用：提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 效果作用：选择符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c36033786.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 效果作用：设置连锁操作信息，表明将要改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果原文内容：这个效果变成守备表示的回合，自己怪兽只能向作为对象的怪兽攻击，自己的电子界族怪兽向作为对象的守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c36033786.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 效果作用：确认目标怪兽有效且成功改变表示形式为守备表示
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
		local fid=tc:GetRealFieldID()
		-- 效果作用：设置不能直接攻击的效果，使己方怪兽只能攻击该目标怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 效果作用：注册不能直接攻击效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e2:SetValue(c36033786.atklimit)
		e2:SetLabel(fid)
		-- 效果作用：注册不能选择为攻击对象的效果，使己方怪兽只能攻击该目标怪兽
		Duel.RegisterEffect(e2,tp)
		-- 效果作用：设置贯穿伤害效果，使己方电子界族怪兽攻击该目标怪兽时造成额外伤害
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_PIERCE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		-- 效果作用：设置效果目标为电子界族怪兽
		e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_CYBERSE))
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 效果作用：注册贯穿伤害效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 效果作用：判断是否为被指定的目标怪兽，用于限制攻击对象
function c36033786.atklimit(e,c)
	return c:GetRealFieldID()~=e:GetLabel()
end
