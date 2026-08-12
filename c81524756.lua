--天穹のパラディオン
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以从手卡往作为连接怪兽所连接区的自己场上守备表示特殊召唤。
-- ②：以自己场上1只「圣像骑士」连接怪兽为对象才能发动。这个回合，自己不用那只怪兽不能攻击，那只怪兽用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
function c81524756.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以从手卡往作为连接怪兽所连接区的自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCountLimit(1,81524756+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c81524756.spcon)
	e1:SetValue(c81524756.spval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己场上1只「圣像骑士」连接怪兽为对象才能发动。这个回合，自己不用那只怪兽不能攻击，那只怪兽用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81524756,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,81524757)
	e2:SetCondition(c81524756.dbcon)
	e2:SetTarget(c81524756.dbtg)
	e2:SetOperation(c81524756.dbop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件判定函数：检查自己场上是否存在可用的连接怪兽所连接的区域
function c81524756.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家场上所有连接怪兽所连接的区域
	local zone=Duel.GetLinkedZone(tp)
	-- 判断在连接怪兽所连接的区域中，自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 特殊召唤规则的数值设定函数：指定特殊召唤到连接怪兽所连接的区域
function c81524756.spval(e,c)
	-- 返回特殊召唤所需的区域限制（0表示不限制特定怪兽，第二个返回值指定为连接怪兽所连接的区域）
	return 0,Duel.GetLinkedZone(c:GetControler())
end
-- 效果②的发动条件判定函数：自己能够进入战斗阶段
function c81524756.dbcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否能够进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 过滤条件：选择自己场上表侧表示、属于「圣像骑士」系列、且是连接怪兽，并且本回合未被此效果选择过的怪兽
function c81524756.dbfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x116) and c:IsType(TYPE_LINK) and c:GetFlagEffect(81524756)==0
end
-- 效果②的对象选择与发动准备函数
function c81524756.dbtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c81524756.dbfilter(chkc) end
	-- 在发动阶段（chk==0）检查自己场上是否存在满足条件的「圣像骑士」连接怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c81524756.dbfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择一只表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只符合过滤条件的「圣像骑士」连接怪兽作为效果对象
	Duel.SelectTarget(tp,c81524756.dbfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的效果处理函数：限制其他怪兽攻击，并使目标怪兽的战斗伤害翻倍
function c81524756.dbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 这个回合，自己不用那只怪兽不能攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c81524756.ftarget)
	e1:SetLabel(tc:GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制攻击的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	if tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(81524756,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
		-- 那只怪兽用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e1:SetCondition(c81524756.damcon)
		-- 设置战斗伤害改变效果：使给与对方的战斗伤害变成2倍
		e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 限制攻击效果的目标过滤函数：除了被选中的怪兽（通过FieldID匹配）以外的怪兽都不能攻击
function c81524756.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 伤害翻倍效果的条件判定函数：该怪兽必须与对方怪兽进行战斗（存在战斗对象）
function c81524756.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end
