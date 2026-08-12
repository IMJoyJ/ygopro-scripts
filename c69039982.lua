--リユナイト・パラディオン
-- 效果：
-- ①：场上的「圣像骑士」连接怪兽的攻击力上升500。
-- ②：1回合1次，以自己场上1只「圣像骑士」连接怪兽为对象才能发动。这个回合，自己不用那只怪兽不能攻击，那只怪兽可以向对方怪兽全部各作1次攻击。
function c69039982.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「圣像骑士」连接怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(500)
	e2:SetTarget(c69039982.atktg)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己场上1只「圣像骑士」连接怪兽为对象才能发动。这个回合，自己不用那只怪兽不能攻击，那只怪兽可以向对方怪兽全部各作1次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69039982,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c69039982.condition)
	e3:SetTarget(c69039982.eatg)
	e3:SetOperation(c69039982.eaop)
	c:RegisterEffect(e3)
end
-- 过滤出场上的「圣像骑士」连接怪兽
function c69039982.atktg(e,c)
	return c:IsSetCard(0x116) and c:IsType(TYPE_LINK)
end
-- 效果②的发动条件判定函数（检查是否能进入战斗阶段）
function c69039982.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能够进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 过滤出自己场上表侧表示、未被限制攻击的「圣像骑士」连接怪兽
function c69039982.eafilter(c)
	return c:IsFaceup() and c:IsSetCard(0x116) and c:IsType(TYPE_LINK) and not c:IsHasEffect(EFFECT_CANNOT_ATTACK)
end
-- 效果②的对象选择与发动合法性检测函数
function c69039982.eatg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c69039982.eafilter(chkc) end
	-- 在发动时，检查自己场上是否存在符合条件的可选择对象
	if chk==0 then return Duel.IsExistingTarget(c69039982.eafilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 在客户端显示“请选择效果的对象”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择并锁定1只符合条件的「圣像骑士」连接怪兽作为效果对象
	Duel.SelectTarget(tp,c69039982.eafilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的效果处理函数（赋予全体攻击并限制其他怪兽攻击）
function c69039982.eaop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的那个效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只怪兽可以向对方怪兽全部各作1次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ATTACK_ALL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 这个回合，自己不用那只怪兽不能攻击
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c69039982.ftarget)
	e2:SetLabel(tc:GetFieldID())
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制其他怪兽攻击的玩家效果注册到全局环境
	Duel.RegisterEffect(e2,tp)
end
-- 过滤出除被选为对象的怪兽以外的其他怪兽（用于应用不能攻击的限制）
function c69039982.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
