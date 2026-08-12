--魔界劇団－ティンクル・リトルスター
-- 效果：
-- ←9 【灵摆】 9→
-- ①：自己不是「魔界剧团」怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：1回合1次，以自己场上1只「魔界剧团」怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中最多3次可以向怪兽攻击，作为对象的怪兽以外的自己怪兽不能攻击。
-- 【怪兽效果】
-- ①：这张卡在自己回合不会被战斗破坏，同1次的战斗阶段中最多3次可以向怪兽攻击。
function c7279373.initial_effect(c)
	-- 启用灵摆怪兽的默认灵摆属性（包括灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「魔界剧团」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c7279373.splimit)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己场上1只「魔界剧团」怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中最多3次可以向怪兽攻击，作为对象的怪兽以外的自己怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7279373,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c7279373.atkcon)
	e2:SetTarget(c7279373.atktg)
	e2:SetOperation(c7279373.atkop)
	c:RegisterEffect(e2)
	-- 同1次的战斗阶段中最多3次可以向怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(2)
	c:RegisterEffect(e3)
	-- ①：这张卡在自己回合不会被战斗破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetCondition(c7279373.indcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 限制灵摆召唤怪兽只能是「魔界剧团」怪兽的过滤函数
function c7279373.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x10ec) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 灵摆效果②的发动条件：自己能够进入战斗阶段
function c7279373.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否能够进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 过滤自己场上表侧表示的「魔界剧团」怪兽
function c7279373.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec)
end
-- 灵摆效果②的靶向目标选择与合法性检测
function c7279373.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c7279373.atkfilter(chkc) end
	-- 检查自己场上是否存在符合条件的「魔界剧团」怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c7279373.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送选择表侧表示卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「魔界剧团」怪兽作为效果对象
	Duel.SelectTarget(tp,c7279373.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 灵摆效果②的效果处理：赋予目标怪兽最多3次向怪兽攻击的能力，并限制其他怪兽不能攻击
function c7279373.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只怪兽在同1次的战斗阶段中最多3次可以向怪兽攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 作为对象的怪兽以外的自己怪兽不能攻击。 / 在自己回合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c7279373.ftarget)
	e2:SetLabel(tc:GetFieldID())
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 向当前玩家注册限制其他怪兽攻击的场地效果
	Duel.RegisterEffect(e2,tp)
end
-- 过滤出除作为对象的怪兽以外的自己场上怪兽的靶向函数
function c7279373.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 怪兽效果①的战斗破坏抗性适用条件：当前是自己回合
function c7279373.indcon(e)
	-- 判断当前回合玩家是否为该卡控制者
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
