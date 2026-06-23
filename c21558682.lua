--ディフェンド・スライム
-- 效果：
-- 对方的怪兽对自己的怪兽攻击的时候，自己的场上的「再生史莱姆」表侧表示存在的场合，攻击对象移去「再生史莱姆」。
function c21558682.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发选发效果，对应一速的【……才能发动】
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21558682,0))  --"攻击对象转移"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c21558682.atkcon)
	e2:SetTarget(c21558682.atktg)
	e2:SetOperation(c21558682.atkop)
	c:RegisterEffect(e2)
end
-- 对方的怪兽对自己的怪兽攻击的时候
function c21558682.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方玩家不是当前回合玩家且存在攻击对象
	return tp~=Duel.GetTurnPlayer() and Duel.GetAttackTarget()~=nil
end
-- 过滤条件：表侧表示的「再生史莱姆」且在攻击可攻击怪兽区
function c21558682.filter(c,atg)
	return c:IsFaceup() and c:IsCode(31709826) and atg:IsContains(c)
end
-- 选择攻击对象转移的目标怪兽
function c21558682.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取攻击怪兽的可攻击怪兽区
	local atg=Duel.GetAttacker():GetAttackableTarget()
	-- 获取当前攻击对象
	local at=Duel.GetAttackTarget()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc~=at and c21558682.filter(chkc,atg) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c21558682.filter,tp,LOCATION_MZONE,0,1,at,atg) end
	-- 提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的目标怪兽
	Duel.SelectTarget(tp,c21558682.filter,tp,LOCATION_MZONE,0,1,1,at,atg)
end
-- 执行攻击对象转移操作
function c21558682.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 目标怪兽存在且表侧表示、与效果相关且攻击怪兽未免疫此效果
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		-- 将攻击对象转移为目标怪兽
		Duel.ChangeAttackTarget(tc)
	end
end
