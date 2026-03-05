--ダイナミスト・ステゴサウラー
-- 效果：
-- ←3 【灵摆】 3→
-- ①：这张卡以外的自己场上的「雾动机龙」卡被战斗或者对方的效果破坏的场合，可以作为代替把这张卡破坏。
-- 【怪兽效果】
-- ①：这张卡以外的自己的灵摆怪兽和对方怪兽进行战斗的伤害计算后才能发动。那些进行战斗的双方怪兽破坏。
function c1580833.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- ①：这张卡以外的自己场上的「雾动机龙」卡被战斗或者对方的效果破坏的场合，可以作为代替把这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTarget(c1580833.reptg)
	e2:SetValue(c1580833.repval)
	e2:SetOperation(c1580833.repop)
	c:RegisterEffect(e2)
	-- ①：这张卡以外的自己的灵摆怪兽和对方怪兽进行战斗的伤害计算后才能发动。那些进行战斗的双方怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c1580833.descon)
	e3:SetTarget(c1580833.destg)
	e3:SetOperation(c1580833.desop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的被破坏的灵摆怪兽：必须是自己场上正面表示存在的雾动机龙卡，且被战斗或对方效果破坏，且不是代替破坏
function c1580833.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0xd8)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足代替破坏的条件：场上存在满足条件的灵摆怪兽，且该卡可被破坏，且未被预定破坏
function c1580833.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c1580833.filter,1,c,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 设置代替破坏的判断函数，用于判断目标卡是否满足代替破坏条件
function c1580833.repval(e,c)
	return c1580833.filter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏操作，将该卡破坏
function c1580833.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果和代替原因破坏该卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 判断是否满足战斗破坏效果的发动条件：攻击怪兽是灵摆怪兽且不是该卡，防守怪兽是对方控制
function c1580833.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
	return a:IsType(TYPE_PENDULUM) and a~=e:GetHandler() and d:IsControler(1-tp)
end
-- 设置战斗破坏效果的目标：将攻击怪兽和防守怪兽设为破坏对象
function c1580833.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	if chk==0 then return a:IsDestructable() and d:IsDestructable() end
	local g=Group.FromCards(a,d)
	-- 设置当前处理的连锁对象为攻击怪兽和防守怪兽
	Duel.SetTargetCard(g)
	-- 设置当前处理的连锁操作信息为破坏效果，目标为攻击怪兽和防守怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 执行战斗破坏效果的操作：获取连锁中的目标卡组并进行破坏
function c1580833.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中获取目标卡组，并筛选出与该效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 以效果原因破坏目标卡组中的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
