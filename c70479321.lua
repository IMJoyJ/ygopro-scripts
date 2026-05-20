--EMドラミング・コング
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，自己怪兽和对方怪兽进行战斗的攻击宣言时，以那1只自己怪兽为对象才能发动。那只怪兽的攻击力直到战斗阶段结束时上升600。
-- 【怪兽效果】
-- ①：双方场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：不用解放作召唤的这张卡的等级变成4星。
-- ③：1回合1次，自己怪兽和对方怪兽进行战斗的攻击宣言时，以那1只自己怪兽为对象才能发动。那只怪兽的攻击力直到战斗阶段结束时上升600。
function c70479321.initial_effect(c)
	-- 启用灵摆怪兽的灵摆召唤和灵摆卡发动等基本规则属性
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己怪兽和对方怪兽进行战斗的攻击宣言时，以那1只自己怪兽为对象才能发动。那只怪兽的攻击力直到战斗阶段结束时上升600。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c70479321.atkcon)
	e2:SetTarget(c70479321.atktg)
	e2:SetOperation(c70479321.atkop)
	c:RegisterEffect(e2)
	-- ①：双方场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70479321,0))  --"不用解放作召唤"
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SUMMON_PROC)
	e3:SetCondition(c70479321.ntcon)
	c:RegisterEffect(e3)
	-- ②：不用解放作召唤的这张卡的等级变成4星。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SUMMON_COST)
	e4:SetOperation(c70479321.lvop)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(c70479321.atkop2)
	c:RegisterEffect(e5)
end
-- 判定是否为自己怪兽与对方怪兽进行战斗的攻击宣言，并将己方战斗怪兽存入LabelObject中
function c70479321.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if d and a:GetControler()~=d:GetControler() then
		if a:IsControler(tp) then e:SetLabelObject(a)
		else e:SetLabelObject(d) end
		return true
	else return false end
end
-- 选择进行战斗的那1只自己怪兽作为效果的对象
function c70479321.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=e:GetLabelObject()
	if chkc then return chkc==tc end
	if chk==0 then return tc:IsOnField() and tc:IsCanBeEffectTarget(e) end
	-- 将目标怪兽设置为当前连锁的效果处理对象
	Duel.SetTargetCard(tc)
end
-- 灵摆效果处理：使作为对象的怪兽攻击力直到战斗阶段结束时上升600
function c70479321.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到战斗阶段结束时上升600。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
	end
end
-- 判定是否满足不用解放作召唤的条件（自身为5星以上、己方怪兽区有空位且双方场上没有怪兽）
function c70479321.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定自身为5星以上且己方怪兽区有可用空格
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判定双方场上没有怪兽存在
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,LOCATION_MZONE)==0
end
-- 判定这张卡在召唤时没有使用解放（祭品）
function c70479321.lvcon(e)
	return e:GetHandler():GetMaterialCount()==0
end
-- 在不用解放作召唤时，为这张卡注册等级变成4星的效果
function c70479321.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：不用解放作召唤的这张卡的等级变成4星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c70479321.lvcon)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 怪兽效果处理：使作为对象的怪兽攻击力直到战斗阶段结束时上升600
function c70479321.atkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到战斗阶段结束时上升600。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
	end
end
