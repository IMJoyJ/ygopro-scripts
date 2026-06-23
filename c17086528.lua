--相生の魔術師
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，以自己场上1只超量怪兽和1只5星以上的怪兽为对象才能发动。那只超量怪兽的阶级直到回合结束时变成和那只5星以上的怪兽的等级数值相同。
-- ②：自己场上的卡比对方场上多的场合，这张卡的灵摆刻度变成4。
-- 【怪兽效果】
-- ①：这张卡的战斗发生的对对方的战斗伤害变成0。
-- ②：1回合1次，以这张卡以外的自己场上1只怪兽为对象才能发动。这张卡的攻击力直到回合结束时变成和那只怪兽相同。
function c17086528.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只超量怪兽和1只5星以上的怪兽为对象才能发动。那只超量怪兽的阶级直到回合结束时变成和那只5星以上的怪兽的等级数值相同。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c17086528.rktg)
	e2:SetOperation(c17086528.rkop)
	c:RegisterEffect(e2)
	-- ②：自己场上的卡比对方场上多的场合，这张卡的灵摆刻度变成4。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_LSCALE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(c17086528.slcon)
	e3:SetValue(4)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e4)
	-- ①：这张卡的战斗发生的对对方的战斗伤害变成0。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	c:RegisterEffect(e5)
	-- ②：1回合1次，以这张卡以外的自己场上1只怪兽为对象才能发动。这张卡的攻击力直到回合结束时变成和那只怪兽相同。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCountLimit(1)
	e6:SetTarget(c17086528.atktg)
	e6:SetOperation(c17086528.atkop)
	c:RegisterEffect(e6)
end
-- 筛选满足条件的超量怪兽（场上正面表示且为超量怪兽）
function c17086528.rkfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查是否存在满足条件的5星以上怪兽（且等级与超量怪兽不同）
		and Duel.IsExistingTarget(c17086528.lvfilter,tp,LOCATION_MZONE,0,1,c,c:GetRank())
end
-- 筛选满足条件的5星以上怪兽（场上正面表示且等级大于等于5且等级与目标超量怪兽不同）
function c17086528.lvfilter(c,rk)
	return c:IsFaceup() and c:IsLevelAbove(5) and not c:IsLevel(rk)
end
-- 设置效果目标：选择1只超量怪兽和1只5星以上怪兽作为对象
function c17086528.rktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足选择目标的条件：场上存在符合条件的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c17086528.rkfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的超量怪兽作为第一个目标
	local g=Duel.SelectTarget(tp,c17086528.rkfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的5星以上怪兽作为第二个目标
	Duel.SelectTarget(tp,c17086528.lvfilter,tp,LOCATION_MZONE,0,1,1,g:GetFirst(),g:GetFirst():GetRank())
end
-- 处理效果：将超量怪兽的阶级设置为5星以上怪兽的等级
function c17086528.rkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取当前连锁的效果对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if lc==tc then lc=tg:GetNext() end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and lc:IsRelateToEffect(e) and lc:IsFaceup() and lc:IsLevelAbove(5) then
		-- 创建并注册改变阶级的效果，使目标超量怪兽的阶级变为5星以上怪兽的等级
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RANK)
		e1:SetValue(lc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判断是否满足灵摆刻度改变的条件：己方场上卡数多于对方
function c17086528.slcon(e)
	local tp=e:GetHandlerPlayer()
	-- 比较己方与对方场上卡数，若己方多则返回true
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
end
-- 筛选满足条件的怪兽（场上正面表示且攻击力与目标不同）
function c17086528.atkfilter(c,atk)
	return c:IsFaceup() and not c:IsAttack(atk)
end
-- 设置效果目标：选择1只除自身外的己方怪兽作为对象
function c17086528.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc~=c and c17086528.atkfilter(chkc,atk) end
	-- 判断是否满足选择目标的条件：场上存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c17086528.atkfilter,tp,LOCATION_MZONE,0,1,c,atk) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的怪兽作为目标
	Duel.SelectTarget(tp,c17086528.atkfilter,tp,LOCATION_MZONE,0,1,1,c,atk)
end
-- 处理效果：将自身攻击力设置为目标怪兽的攻击力
function c17086528.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetAttack()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 创建并注册改变攻击力的效果，使自身攻击力变为目标怪兽的攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
