--黄昏の忍者－カゲン
-- 效果：
-- ←10 【灵摆】 10→
-- ①：自己不是「忍者」怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：1回合1次，自己的「忍者」怪兽的攻击宣言时才能发动。那只怪兽的攻击力直到伤害步骤结束时上升1000。
-- 【怪兽效果】
-- ①：把这张卡解放，以自己场上1只「忍者」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升800。
function c6830480.initial_effect(c)
	-- 注册灵摆怪兽属性（灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「忍者」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c6830480.splimit)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己的「忍者」怪兽的攻击宣言时才能发动。那只怪兽的攻击力直到伤害步骤结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6830480,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c6830480.atkcon)
	e2:SetOperation(c6830480.atkop)
	c:RegisterEffect(e2)
	-- ①：把这张卡解放，以自己场上1只「忍者」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升800。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(6830480,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c6830480.cost)
	e3:SetTarget(c6830480.tg)
	e3:SetOperation(c6830480.op)
	c:RegisterEffect(e3)
end
-- 限制自己只能灵摆召唤「忍者」怪兽的过滤函数
function c6830480.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x2b) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 判定攻击宣言的怪兽是否为自己场上的「忍者」怪兽
function c6830480.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	return at:IsControler(tp) and at:IsSetCard(0x2b)
end
-- 攻击力上升效果的执行函数，使攻击怪兽的攻击力直到伤害步骤结束时上升1000
function c6830480.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行战斗的攻击怪兽
	local at=Duel.GetAttacker()
	if at:IsFaceup() and at:IsRelateToBattle() then
		-- 那只怪兽的攻击力直到伤害步骤结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		at:RegisterEffect(e1)
	end
end
-- 效果发动的代价：检查并解放自身
function c6830480.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 作为发动代价解放这张卡
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤场上表侧表示的「忍者」怪兽
function c6830480.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2b)
end
-- 效果的目标选择函数，选择自己场上1只表侧表示的「忍者」怪兽作为对象
function c6830480.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c6830480.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「忍者」怪兽
	if chk==0 then return Duel.IsExistingTarget(c6830480.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 给玩家发送选择效果对象的提示消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「忍者」怪兽作为效果的对象
	Duel.SelectTarget(tp,c6830480.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果的执行函数，使作为对象的怪兽攻击力直到回合结束时上升800
function c6830480.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升800。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(800)
		tc:RegisterEffect(e1)
	end
end
