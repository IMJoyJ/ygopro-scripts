--スターヴ・ヴェネミー・リーサルドーズ・ドラゴン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，自己主要阶段才能发动。给对方场上的全部表侧表示怪兽各放置1个蛊指示物。
-- ②：龙族·暗属性怪兽以外的场上的怪兽的攻击力下降场上的蛊指示物数量×200。
-- 【怪兽效果】
-- 暗属性灵摆怪兽×3
-- ①：每次场上的卡被送去墓地，每有1张给这张卡放置1个蛊指示物。
-- ②：龙族·暗属性怪兽以外的场上的怪兽的攻击力下降场上的蛊指示物数量×200。
-- ③：1回合1次，自己主要阶段才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
-- ④：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c22070401.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加需要3个暗属性灵摆类型的融合素材的融合召唤手续
	aux.AddFusionProcFunRep(c,c22070401.ffilter,3,true)
	-- 为卡片添加灵摆怪兽属性，但不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：1回合1次，自己主要阶段才能发动。给对方场上的全部表侧表示怪兽各放置1个蛊指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22070401,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c22070401.cttg)
	e1:SetOperation(c22070401.ctop)
	c:RegisterEffect(e1)
	-- ②：龙族·暗属性怪兽以外的场上的怪兽的攻击力下降场上的蛊指示物数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c22070401.atktg)
	e2:SetValue(c22070401.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e3)
	-- 每次场上的卡被送去墓地，每有1张给这张卡放置1个蛊指示物。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(c22070401.counter)
	c:RegisterEffect(e4)
	-- ③：1回合1次，自己主要阶段才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(22070401,1))
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c22070401.target)
	e5:SetOperation(c22070401.operation)
	c:RegisterEffect(e5)
	-- ④：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(22070401,2))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(c22070401.pencon)
	e6:SetTarget(c22070401.pentg)
	e6:SetOperation(c22070401.penop)
	c:RegisterEffect(e6)
end
c22070401.mentioned_counter={
	[0x104f]=true,
}
-- 融合素材必须为暗属性且灵摆类型的怪兽
function c22070401.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsFusionType(TYPE_PENDULUM)
end
-- 目标怪兽必须表侧表示且能放置蛊指示物
function c22070401.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x104f,1)
end
-- 检查是否有满足条件的目标怪兽
function c22070401.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c22070401.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置连锁操作信息，指定将要放置蛊指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x104f)
end
-- 将满足条件的怪兽全部放置1个蛊指示物
function c22070401.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c22070401.ctfilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x104f,1)
		tc=g:GetNext()
	end
end
-- 判断目标怪兽是否为龙族暗属性怪兽
function c22070401.atktg(e,c)
	return not (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK))
end
-- 计算攻击力下降值
function c22070401.atkval(e,c)
	-- 返回场上蛊指示物数量乘以-200作为攻击力下降值
	return Duel.GetCounter(0,1,1,0x104f)*-200
end
-- 过滤被送去墓地的卡必须在场上停留过
function c22070401.cfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 统计被送去墓地的卡的数量并为自身添加相同数量的蛊指示物
function c22070401.counter(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c22070401.cfilter,nil)
	if ct>0 then
		e:GetHandler():AddCounter(0x104f,ct)
	end
end
-- 检查是否有可无效效果的怪兽
function c22070401.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有可无效效果的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取所有可无效效果的怪兽组
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,e:GetHandler())
	-- 设置连锁操作信息，指定将要使效果无效的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 为所有可无效效果的怪兽添加效果无效和效果破坏效果
function c22070401.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有可无效效果的怪兽组
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为怪兽添加效果无效效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 为怪兽添加效果破坏效果
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 判断此卡是否因战斗或效果被破坏且在怪兽区域
function c22070401.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 检查是否有空闲的灵摆区域
function c22070401.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有空闲的灵摆区域
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 将此卡移至自己的灵摆区域
function c22070401.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片移动到指定玩家的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
