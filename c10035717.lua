--ウェポンチェンジ
-- 效果：
-- 此效果只能在自己每回合的准备阶段支付700基本分发动1次。使自己场上1只战士族·机械族怪兽的攻击力与守备力互换直到对方的下一个结束阶段终了时为止。当这张卡被破坏时，此效果无效化。
function c10035717.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建效果，设置类型为激活，代码为自由连锁，注册效果。
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
-- 创建效果e2，描述为“攻守交换”，类型为字段+触发型效果，代码为阶段结束+准备阶段，属性为可取对象，生效范围为魔法陷阱区，发动次数限制为1次，设置发动条件为c10035717.adcon，支付费用为c10035717.adcost，选择目标为c10035717.adtg，执行操作为c10035717.adop，注册效果。
function c10035717.adcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否是tp（发动者）。
	return Duel.GetTurnPlayer()==tp
end
-- 检查tp是否能支付700基本分。
function c10035717.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 让tp支付700基本分。
	if chk==0 then return Duel.CheckLPCost(tp,700) end
	-- 定义过滤函数c10035717.filter，用于筛选表侧表示、种族为机械或战士的怪兽且守备力大于0的卡片。
	Duel.PayLPCost(tp,700)
end
-- 创建效果e2，设置类型为单体效果，代码为最终改变攻击力，数值为def，重置条件为事件+标准重置+阶段结束+回合结束，注册效果。
function c10035717.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE+RACE_WARRIOR) and c:IsDefenseAbove(0)
end
-- 如果存在可选择的目标则返回目标是否由tp控制、位于怪兽区以及满足c10035717.filter的条件；否则检查是否存在满足c10035717.filter条件的卡片在怪兽区域，并返回结果。
function c10035717.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c10035717.filter(chkc) end
	-- 判断是否存在满足过滤条件的卡片。
	if chk==0 then return Duel.IsExistingTarget(c10035717.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标卡片，使用c10035717.filter作为筛选条件。
	Duel.SelectTarget(tp,c10035717.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 创建效果e2，设置类型为单体效果，代码为最终改变守备力，数值为atk，重置条件为事件+标准重置+阶段结束+回合结束，注册效果。
function c10035717.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个目标卡片。
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
