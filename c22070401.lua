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
	-- 为这张卡注册融合召唤手续：以3只满足条件ffilter的怪兽（暗属性灵摆怪兽）为融合素材
	aux.AddFusionProcFunRep(c,c22070401.ffilter,3,true)
	-- 为这张卡添加灵摆怪兽属性（可进行灵摆召唤），但不注册灵摆卡的「卡的发动」效果
	aux.EnablePendulumAttribute(c,false)
	-- 灵摆效果①：1回合1次，自己主要阶段才能发动。给对方场上的全部表侧表示怪兽各放置1个蛊指示物
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22070401,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c22070401.cttg)
	e1:SetOperation(c22070401.ctop)
	c:RegisterEffect(e1)
	-- 灵摆效果②：龙族·暗属性怪兽以外的场上的怪兽的攻击力下降场上的蛊指示物数量×200
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
	-- 怪兽效果①：每次场上的卡被送去墓地，每有1张给这张卡放置1个蛊指示物
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(c22070401.counter)
	c:RegisterEffect(e4)
	-- 怪兽效果③：1回合1次，自己主要阶段才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(22070401,1))
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c22070401.target)
	e5:SetOperation(c22070401.operation)
	c:RegisterEffect(e5)
	-- 怪兽效果④：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置
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
-- 融合素材过滤函数：筛选暗属性的灵摆怪兽（对应素材要求「暗属性灵摆怪兽×3」）
function c22070401.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsFusionType(TYPE_PENDULUM)
end
-- 过滤函数：筛选表侧表示且可以放置1个蛊指示物的怪兽
function c22070401.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x104f,1)
end
-- 灵摆效果①的发动检测：确认对方场上存在可放置蛊指示物的表侧表示怪兽，并设置指示物效果的操作信息
function c22070401.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：对方怪兽区域存在至少1只表侧表示且可以放置蛊指示物的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c22070401.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置操作信息：此连锁为指示物效果，预计放置1个蛊指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x104f)
end
-- 效果处理：遍历对方场上所有表侧表示且可放置蛊指示物的怪兽，给每1只各放置1个蛊指示物
function c22070401.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取对方怪兽区域所有表侧表示且可以放置蛊指示物的怪兽
	local g=Duel.GetMatchingGroup(c22070401.ctfilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x104f,1)
		tc=g:GetNext()
	end
end
-- 效果适用对象过滤：仅限龙族·暗属性怪兽以外的怪兽（即「龙族·暗属性怪兽以外的场上的怪兽」）
function c22070401.atktg(e,c)
	return not (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK))
end
-- 攻击力变化值计算函数：按场上的蛊指示物数量计算攻击力下降值
function c22070401.atkval(e,c)
	-- 返回场上蛊指示物数量×-200，即攻击力下降蛊指示物数量×200
	return Duel.GetCounter(0,1,1,0x104f)*-200
end
-- 过滤函数：筛选送去墓地之前在场上的卡
function c22070401.cfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 不入连锁的效果处理：统计本次从场上送去墓地的卡的数量，每有1张给这张卡放置1个蛊指示物
function c22070401.counter(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c22070401.cfilter,nil)
	if ct>0 then
		e:GetHandler():AddCounter(0x104f,ct)
	end
end
-- 无效效果的发动检测：确认对方场上存在可无效的效果怪兽，并设置效果无效的操作信息
function c22070401.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：对方怪兽区域存在至少1只表侧表示且未被无效的效果怪兽（这张卡除外）
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取对方怪兽区域所有表侧表示且未被无效的效果怪兽（这张卡除外）
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,e:GetHandler())
	-- 设置操作信息：此效果将对方场上全部上述怪兽的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 效果处理：遍历对方场上所有表侧表示且未被无效的效果怪兽，逐只注册直到回合结束时的效果无效状态
function c22070401.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方怪兽区域所有表侧表示且未被无效的效果怪兽
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部表侧表示怪兽的效果无效（赋予该怪兽效果无效状态）
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果直到回合结束时无效（同时无效其效果，回合结束时重置）
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 发动条件：这张卡在怪兽区域以表侧表示被战斗或效果破坏
function c22070401.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 对象检测：检查自己的灵摆区域是否存在可用空格
function c22070401.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：自己灵摆区域左右两侧至少有一处空格可用
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 效果处理：若这张卡仍与此效果关联，则将这张卡表侧表示放置到自己的灵摆区域
function c22070401.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示移动到自己的灵摆区域，并立即适用其效果
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
