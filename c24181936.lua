--闇味鍋パーティー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己战斗阶段开始时，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只自己怪兽的攻击对象由对方选择，那只自己怪兽的攻击力只在和对方怪兽进行战斗的伤害计算时上升自身的原本攻击力数值。
function c24181936.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己战斗阶段开始时，以自己场上1只表侧表示怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24181936,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,24181936)
	e2:SetCondition(c24181936.atkcon1)
	e2:SetTarget(c24181936.atktg1)
	e2:SetOperation(c24181936.atkop1)
	c:RegisterEffect(e2)
end
-- 判断是否为自己的战斗阶段开始
function c24181936.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 选择1只自己场上的表侧表示怪兽作为效果对象
function c24181936.atktg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只自己场上的表侧表示怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果的发动与执行
function c24181936.atkop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:GetFlagEffect(24181936)==0 then
			tc:RegisterFlagEffect(24181936,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			-- 设置由对方选择攻击对象的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetCondition(c24181936.effcon)
			e1:SetLabelObject(tc)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册由对方选择攻击对象的效果
			Duel.RegisterEffect(e1,tp)
			-- 设置攻击力上升的效果
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetTargetRange(LOCATION_MZONE,0)
			e2:SetCondition(c24181936.atkcon2)
			e2:SetTarget(c24181936.atktg)
			e2:SetValue(c24181936.atkval)
			e2:SetLabelObject(tc)
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 注册攻击力上升的效果
			Duel.RegisterEffect(e2,tp)
		end
	end
end
-- 判断是否处于伤害计算阶段且目标怪兽有效
function c24181936.effcon(e)
	local tc=e:GetLabelObject()
	-- 判断目标怪兽是否处于效果使用中且为攻击怪兽
	return tc:GetFlagEffect(24181936)~=0 and Duel.GetAttacker()==tc
end
-- 判断是否处于伤害计算阶段且目标怪兽有效
function c24181936.atkcon2(e)
	local tc=e:GetLabelObject()
	-- 判断当前阶段是否为伤害计算阶段
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		-- 判断目标怪兽是否处于效果使用中且为攻击怪兽且有攻击对象
		and tc:GetFlagEffect(24181936)~=0 and Duel.GetAttacker()==tc and Duel.GetAttackTarget()~=nil
end
-- 设定攻击力上升效果的目标
function c24181936.atktg(e,c)
	-- 设定攻击力上升效果的目标为当前攻击怪兽
	return c==Duel.GetAttacker()
end
-- 设定攻击力上升效果的数值为攻击怪兽的原本攻击力
function c24181936.atkval(e,c)
	return c:GetBaseAttack()
end
