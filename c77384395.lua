--パズズル
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，以另一边的自己的灵摆区域1张卡为对象才能发动。这张卡的灵摆刻度直到回合结束时变成和作为对象的灵摆怪兽卡的等级数值相同。这个效果的发动后，直到回合结束时自己不能作灵摆召唤以外的特殊召唤。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，自己怪兽的灵摆召唤不会被无效化。
function c77384395.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动等基本规则）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以另一边的自己的灵摆区域1张卡为对象才能发动。这张卡的灵摆刻度直到回合结束时变成和作为对象的灵摆怪兽卡的等级数值相同。这个效果的发动后，直到回合结束时自己不能作灵摆召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c77384395.target)
	e1:SetOperation(c77384395.operation)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，自己怪兽的灵摆召唤不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c77384395.distg)
	c:RegisterEffect(e2)
end
-- 过滤另一边灵摆区域中，原本等级大于0且原本等级不等于当前卡片灵摆刻度的卡片
function c77384395.filter(c,tc)
	return c:GetOriginalLevel()>0 and c:GetOriginalLevel()~=tc:GetCurrentScale()
end
-- 灵摆效果的发动准备与目标选择函数
function c77384395.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 检查另一边的灵摆区域是否存在可以作为对象且原本等级大于0、与自身当前刻度不同的卡片
	if chk==0 then return Duel.IsExistingTarget(c77384395.filter,tp,LOCATION_PZONE,0,1,c,c) end
	-- 获取另一边灵摆区域中符合过滤条件的第一张卡片
	local tc=Duel.GetFirstMatchingCard(c77384395.filter,tp,LOCATION_PZONE,0,c,c)
	-- 将获取到的卡片设置为效果的对象
	Duel.SetTargetCard(tc)
end
-- 灵摆效果的执行函数，处理刻度变更以及后续的特殊召唤限制
function c77384395.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这张卡的灵摆刻度直到回合结束时变成和作为对象的灵摆怪兽卡的等级数值相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(tc:GetOriginalLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		c:RegisterEffect(e2)
	end
	-- 这个效果的发动后，直到回合结束时自己不能作灵摆召唤以外的特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c77384395.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能作灵摆召唤以外的特殊召唤的限制效果
	Duel.RegisterEffect(e3,tp)
end
-- 限制特殊召唤的过滤函数，若召唤类型不含灵摆召唤则禁止特殊召唤
function c77384395.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return sumtype&SUMMON_TYPE_PENDULUM~=SUMMON_TYPE_PENDULUM
end
-- 过滤自身场上进行灵摆召唤的怪兽，使其特殊召唤不会被无效化
function c77384395.distg(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
