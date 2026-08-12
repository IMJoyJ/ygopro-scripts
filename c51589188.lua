--フォトン・トライデント
-- 效果：
-- 选择自己场上1只名字带有「光子」的怪兽才能发动。直到结束阶段时，选择的怪兽的攻击力上升700，向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。此外，选择的怪兽给与对方基本分战斗伤害时，可以选择场上1张魔法·陷阱卡破坏。
function c51589188.initial_effect(c)
	-- 选择自己场上1只名字带有「光子」的怪兽才能发动。直到结束阶段时，选择的怪兽的攻击力上升700，向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。此外，选择的怪兽给与对方基本分战斗伤害时，可以选择场上1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c51589188.target)
	e1:SetOperation(c51589188.activate)
	c:RegisterEffect(e1)
end
-- 筛选场上表侧表示的「光子」怪兽
function c51589188.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x55)
end
-- 选择自己场上1只名字带有「光子」的怪兽作为效果对象
function c51589188.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c51589188.filter(chkc) end
	-- 检查是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c51589188.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c51589188.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将攻击力上升700和贯穿伤害效果应用到目标怪兽上，并注册破坏效果
function c51589188.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 直到结束阶段时，选择的怪兽的攻击力上升700
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(700)
		tc:RegisterEffect(e1)
		-- 向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 选择场上1张魔法·陷阱卡破坏
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetDescription(aux.Stringid(51589188,0))  --"破坏"
		e3:SetCategory(CATEGORY_DESTROY)
		e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e3:SetCode(EVENT_BATTLE_DAMAGE)
		e3:SetLabelObject(tc)
		e3:SetCondition(c51589188.descon)
		e3:SetTarget(c51589188.destg)
		e3:SetOperation(c51589188.desop)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将破坏效果注册到游戏环境
		Duel.RegisterEffect(e3,tp)
	end
end
-- 判断是否为对方造成的战斗伤害且伤害来源为目标怪兽
function c51589188.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst()==e:GetLabelObject()
end
-- 筛选场上的魔法或陷阱卡
function c51589188.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 选择场上1张魔法·陷阱卡作为破坏对象
function c51589188.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c51589188.desfilter(chkc) end
	-- 检查是否满足选择破坏对象的条件
	if chk==0 then return Duel.IsExistingTarget(c51589188.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择符合条件的魔法·陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c51589188.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表明将要破坏一张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果，将目标卡破坏
function c51589188.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
