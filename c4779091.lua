--ユベル－Das Abscheulich Ritter
-- 效果：
-- 这张卡不能通常召唤，用「于贝尔」的效果才能特殊召唤。
-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：攻击表示的这张卡被选择作为攻击对象的场合，那次伤害计算前发动。给与对方攻击怪兽的攻击力数值的伤害。
-- ③：自己结束阶段发动。场上的其他怪兽全部破坏。
-- ④：表侧表示的这张卡从场上离开时才能发动。从自己的手卡·卡组·墓地把1只「于贝尔-极度悲伤的魔龙」特殊召唤。
function c4779091.initial_effect(c)
	-- 注册卡片代码列表，记录该卡与「于贝尔」的关联
	aux.AddCodeList(c,78371393)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：攻击表示的这张卡被选择作为攻击对象的场合，那次伤害计算前发动。给与对方攻击怪兽的攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4779091,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(c4779091.damcon)
	e3:SetTarget(c4779091.damtg)
	e3:SetOperation(c4779091.damop)
	c:RegisterEffect(e3)
	-- ③：自己结束阶段发动。场上的其他怪兽全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_RELEASE+CATEGORY_DESTROY)
	e4:SetDescription(aux.Stringid(4779091,1))  --"破坏"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCondition(c4779091.descon)
	e4:SetTarget(c4779091.destg)
	e4:SetOperation(c4779091.desop)
	c:RegisterEffect(e4)
	-- ④：表侧表示的这张卡从场上离开时才能发动。从自己的手卡·卡组·墓地把1只「于贝尔-极度悲伤的魔龙」特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(4779091,2))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCondition(c4779091.spcon)
	e5:SetTarget(c4779091.sptg)
	e5:SetOperation(c4779091.spop)
	c:RegisterEffect(e5)
	-- 这张卡不能通常召唤，用「于贝尔」的效果才能特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e6)
end
-- 判断是否为攻击表示的这张卡被选择作为攻击对象
function c4779091.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为攻击表示的这张卡被选择作为攻击对象
	return e:GetHandler()==Duel.GetAttackTarget()
end
-- 设置伤害效果的目标玩家和伤害值
function c4779091.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置伤害效果的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 获取攻击怪兽的攻击力
	local atk=Duel.GetAttacker():GetAttack()
	-- 设置伤害效果的目标参数为攻击怪兽的攻击力
	Duel.SetTargetParam(atk)
	-- 设置操作信息为造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 执行伤害效果
function c4779091.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 判断是否为自己的结束阶段
function c4779091.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的结束阶段
	return Duel.GetTurnPlayer()==tp
end
-- 设置破坏效果的目标卡片组
function c4779091.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有怪兽作为目标卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果
function c4779091.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除自身外的所有怪兽作为目标卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 将目标卡片组全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 判断该卡是否以表侧表示离开场上的状态
function c4779091.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤满足条件的「于贝尔-极度悲伤的魔龙」卡片
function c4779091.filter(c,e,tp)
	return c:IsCode(31764700) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 设置特殊召唤效果的目标
function c4779091.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c4779091.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 执行特殊召唤效果
function c4779091.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「于贝尔-极度悲伤的魔龙」卡片
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4779091.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡片特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
