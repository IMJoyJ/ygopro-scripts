--幻影騎士団ダーク・ガントレット
-- 效果：
-- ①：从卡组把1张「幻影」魔法·陷阱卡送去墓地。
-- ②：自己场上没有卡存在的场合，对方怪兽的直接攻击宣言时才能在墓地发动。这张卡变成效果怪兽（战士族·暗·4星·攻300/守600）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ③：这张卡的效果特殊召唤的这张卡的守备力上升自己墓地的「幻影」魔法·陷阱卡数量×300。
function c24212820.initial_effect(c)
	-- ①：从卡组把1张「幻影」魔法·陷阱卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c24212820.target)
	e1:SetOperation(c24212820.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上没有卡存在的场合，对方怪兽的直接攻击宣言时才能在墓地发动。这张卡变成效果怪兽（战士族·暗·4星·攻300/守600）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24212820,0))  --"这张卡变成效果怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c24212820.spcon)
	e2:SetTarget(c24212820.sptg)
	e2:SetOperation(c24212820.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡的效果特殊召唤的这张卡的守备力上升自己墓地的「幻影」魔法·陷阱卡数量×300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetCondition(c24212820.defcon)
	e3:SetValue(c24212820.defval)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选卡组中可送去墓地的「幻影」魔法·陷阱卡。
function c24212820.tgfilter(c)
	return c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 效果处理时检查是否满足条件，即卡组中是否存在至少1张「幻影」魔法·陷阱卡。
function c24212820.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「幻影」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c24212820.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组选择1张「幻影」魔法·陷阱卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 发动效果时执行的操作，提示玩家选择一张「幻影」魔法·陷阱卡并将其送去墓地。
function c24212820.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张「幻影」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c24212820.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 发动条件判断，检查自己场上是否没有卡，且对方怪兽进行直接攻击。
function c24212820.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否没有卡。
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0
		-- 检查对方怪兽是否进行直接攻击且未被攻击目标。
		and Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 设置特殊召唤的处理条件，判断是否可以发动效果并进行特殊召唤。
function c24212820.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以发动效果并进行特殊召唤。
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤该卡为效果怪兽。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,24212820,0x10db,TYPES_EFFECT_TRAP_MONSTER,300,600,4,RACE_WARRIOR,ATTRIBUTE_DARK) end
	-- 设置操作信息，表示将特殊召唤该卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 发动效果时执行的操作，将该卡特殊召唤为效果怪兽。
function c24212820.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的空间进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 判断是否可以发动特殊召唤效果。
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,24212820,0x10db,TYPES_EFFECT_TRAP_MONSTER,300,600,4,RACE_WARRIOR,ATTRIBUTE_DARK) then
		c:AddMonsterAttribute(TYPE_EFFECT)
		-- 将该卡特殊召唤到场上。
		Duel.SpecialSummonStep(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP_DEFENSE)
		-- 设置效果，使该卡从场上离开时被移除。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
		-- 完成特殊召唤流程。
		Duel.SpecialSummonComplete()
	end
end
-- 守备力提升效果的触发条件，判断该卡是否为特殊召唤而来。
function c24212820.defcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤函数，用于筛选墓地中「幻影」魔法·陷阱卡。
function c24212820.filter(c)
	return c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 计算守备力提升值，即墓地中「幻影」魔法·陷阱卡数量乘以300。
function c24212820.defval(e,c)
	-- 计算墓地中「幻影」魔法·陷阱卡的数量并乘以300作为守备力提升值。
	return Duel.GetMatchingGroupCount(c24212820.filter,c:GetControler(),LOCATION_GRAVE,0,nil)*300
end
