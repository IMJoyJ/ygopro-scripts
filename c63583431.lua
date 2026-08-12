--ゴゴゴ護符
-- 效果：
-- 自己场上有名字带有「隆隆隆」的怪兽2只以上存在的场合，自己受到的效果伤害变成0。此外，1回合1次，自己场上的名字带有「隆隆隆」的怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽不会被那次战斗破坏。
function c63583431.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上有名字带有「隆隆隆」的怪兽2只以上存在的场合，自己受到的效果伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c63583431.damcon)
	e2:SetValue(c63583431.damval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e3)
	-- 此外，1回合1次，自己场上的名字带有「隆隆隆」的怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽不会被那次战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(63583431,0))  --"破坏耐性"
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetHintTiming(TIMING_BATTLE_PHASE)
	e4:SetCountLimit(1)
	e4:SetCondition(c63583431.indcon)
	e4:SetTarget(c63583431.indtg)
	e4:SetOperation(c63583431.indop)
	c:RegisterEffect(e4)
end
-- 过滤条件：表侧表示且名字带有「隆隆隆」的怪兽
function c63583431.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x59)
end
-- 效果伤害变0的适用条件判定函数
function c63583431.damcon(e)
	-- 检查自己场上是否存在至少2只表侧表示的名字带有「隆隆隆」的怪兽
	return Duel.IsExistingMatchingCard(c63583431.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil)
end
-- 伤害值修改判定函数，若为效果伤害则将伤害值变为0
function c63583431.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0 end
	return val
end
-- 战斗破坏耐性效果的发动条件判定函数
function c63583431.indcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方怪兽，则将目标怪兽切换为被攻击的我方怪兽
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsSetCard(0x59)
end
-- 战斗破坏耐性效果的目标选择函数
function c63583431.indtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将进行战斗的我方「隆隆隆」怪兽设为当前效果的处理对象
	Duel.SetTargetCard(e:GetLabelObject())
end
-- 战斗破坏耐性效果的执行函数
function c63583431.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的处理对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只自己怪兽不会被那次战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
	end
end
