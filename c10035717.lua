--ウェポンチェンジ
-- 效果：
-- 此效果只能在自己每回合的准备阶段支付700基本分发动1次。使自己场上1只战士族·机械族怪兽的攻击力与守备力互换直到对方的下一个结束阶段终了时为止。当这张卡被破坏时，此效果无效化。
function c10035717.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 此效果只能在自己每回合的准备阶段支付700基本分发动1次。使自己场上1只战士族·机械族怪兽的攻击力与守备力互换直到对方的下一个结束阶段终了时为止。当这张卡被破坏时，此效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10035717,0))  --"攻守交换"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c10035717.adcon)
	e2:SetCost(c10035717.adcost)
	e2:SetTarget(c10035717.adtg)
	e2:SetOperation(c10035717.adop)
	c:RegisterEffect(e2)
end
-- 发动条件：判断当前回合玩家是否为效果控制者
function c10035717.adcon(e,tp,eg,ep,ev,re,r,rp)
	-- 限制发动的条件：判断是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 代价支付：检查自己是否能支付700点基本分，若能支付则扣除700基本分
function c10035717.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检查：判断自己是否能支付700点LP
	if chk==0 then return Duel.CheckLPCost(tp,700) end
	-- 让玩家支付700点LP作为效果代价
	Duel.PayLPCost(tp,700)
end
-- 过滤条件：判断卡片是否为表侧表示，且属于机械族或战士族怪兽，且守备力大于等于0
function c10035717.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE+RACE_WARRIOR) and c:IsDefenseAbove(0)
end
-- 攻守交换效果的目标选择与检测：判断场上是否存在符合条件的表侧表示怪兽，并选择其为效果对象
function c10035717.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c10035717.filter(chkc) end
	-- 效果发动时的目标检查：判断自己场上是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c10035717.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只满足条件的战士族或机械族怪兽作为效果对象
	Duel.SelectTarget(tp,c10035717.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 攻守交换效果的执行操作：若对象怪兽表侧表示且仍符合条件，则注册将其攻击力与守备力互换的效果，此效果在对方的下一个结束阶段结束时失效
function c10035717.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsRace(RACE_MACHINE+RACE_WARRIOR) then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- 使自己场上1只战士族·机械族怪兽的攻击力与守备力互换直到对方的下一个结束阶段终了时为止。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		-- 使自己场上1只战士族·机械族怪兽的攻击力与守备力互换直到对方的下一个结束阶段终了时为止。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
	end
end
