--ダイナミスト・ステゴサウラー
-- 效果：
-- ←3 【灵摆】 3→
-- ①：这张卡以外的自己场上的「雾动机龙」卡被战斗或者对方的效果破坏的场合，可以作为代替把这张卡破坏。
-- 【怪兽效果】
-- ①：这张卡以外的自己的灵摆怪兽和对方怪兽进行战斗的伤害计算后才能发动。那些进行战斗的双方怪兽破坏。
function c1580833.initial_effect(c)
	-- 为灵摆怪兽c添加灵摆怪兽属性（灵摆召唤、灵摆卡发动等），使其可在灵摆区作为魔法卡发动。
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
-- 判定一张卡是否为满足代破条件的「雾动机龙」卡：表侧表示、在自己场上、属于雾动机龙系列，且本次破坏原因是战斗破坏或对方的效果破坏，并排除因代替破坏而发生的破坏。
function c1580833.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0xd8)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 代破效果适用判定：本次被破坏的卡组eg中存在至少1张除本卡以外满足filter条件的「雾动机龙」卡，且本卡自身可被破坏、没有被预定破坏。
function c1580833.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c1580833.filter,1,c,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 向本卡控制者询问是否发动代替破坏效果（选择“是”则用本卡代替破坏）。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 作为EFFECT_DESTROY_REPLACE的值函数：判断将被破坏的卡c是否满足本卡代替破坏的条件（即是否属于可被本卡代破的「雾动机龙」卡）。
function c1580833.repval(e,c)
	return c1580833.filter(c,e:GetHandlerPlayer())
end
-- 代替破坏的处理函数：将本卡（灵摆区的这张卡）作为代替破坏的对象。
function c1580833.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 把这张灵摆卡自身破坏，破坏原因标记为效果并带有代替破坏属性，以代替原本那张「雾动机龙」卡被破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 怪兽效果的发动条件：通过攻击者和攻击对象确定战斗双方，若攻击对象是己方怪兽则交换二者，然后确认己方存在除本卡以外的表侧灵摆怪兽与对方怪兽进行了战斗（伤害计算后EVENT_BATTLED时点）。
function c1580833.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得此次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 取得此次战斗的被攻击怪兽。
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
	return a:IsType(TYPE_PENDULUM) and a~=e:GetHandler() and d:IsControler(1-tp)
end
-- 怪兽效果发动时判定：取攻击怪兽和被攻击怪兽，若两者均可被破坏，则将它们作为效果对象，并设置破坏两张卡的操作信息。
function c1580833.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得此次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 取得此次战斗的被攻击怪兽。
	local d=Duel.GetAttackTarget()
	if chk==0 then return a:IsDestructable() and d:IsDestructable() end
	local g=Group.FromCards(a,d)
	-- 将进行战斗的双方怪兽设置为当前连锁的对象，使效果处理时能够获取并关联这两张卡。
	Duel.SetTargetCard(g)
	-- 设置操作信息：当前连锁将破坏这2张战斗怪兽，供“破坏”相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 效果处理：从连锁对象中筛选出仍与本效果相关的卡（未离场或未失效），若存在则将其全部破坏。
function c1580833.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组，并过滤出仍与效果e相关的怪兽（战斗的双方怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将筛选出的进行战斗的双方怪兽破坏，破坏原因为效果。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
