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
	-- ②：自己场上没有卡存在的场合，对方怪兽的直接攻击宣言时才能在墓地发动。这张卡变成效果怪兽（战士族·暗·4星·攻300/守600）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。
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
-- 定义「幻影」魔法·陷阱卡的筛选条件：属于「幻影」系列（0xdb）、是魔法或陷阱卡，并且可以被送去墓地。
function c24212820.tgfilter(c)
	return c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 效果①的发动时点处理：确认卡组存在符合条件的「幻影」魔法·陷阱卡，并登记将卡组1张魔法·陷阱卡送去墓地的操作信息。
function c24212820.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检测：卡组中是否有至少1张满足条件的「幻影」魔法·陷阱卡可以送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(c24212820.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果将从卡组把1张卡送去墓地（具体卡片在效果处理时选择，因此目标暂不指定）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理时：从卡组选择1张符合条件的「幻影」魔法·陷阱卡，将其送去墓地。
function c24212820.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示选择提示，要求其选择1张要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中筛选并选择1张符合条件的「幻影」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c24212820.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果②的发动条件判定：自己场上没有卡，且对方怪兽直接攻击宣言时才能发动。
function c24212820.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（怪兽区域和魔法陷阱区域）没有任何卡。
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0
		-- 检查攻击怪兽为对方控制且攻击对象为空，即对方怪兽正在进行直接攻击。
		and Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果②的发动目标确认：满足发动条件且可以特殊召唤此卡时，登记特殊召唤的操作信息。
function c24212820.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认此卡不在连锁处理中，且自己主要怪兽区有可用的空位。
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认玩家可以将此卡以战士族·暗·4星·攻300/守600的效果怪兽形式特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,24212820,0x10db,TYPES_EFFECT_TRAP_MONSTER,300,600,4,RACE_WARRIOR,ATTRIBUTE_DARK) end
	-- 登记操作信息：本次效果将特殊召唤这张卡本身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②处理时：若仍有怪兽区空位且满足特殊召唤条件，将这张卡变成效果怪兽守备表示特殊召唤，并附加离场除外的效果。
function c24212820.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有空位，则直接终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 确认此卡仍与效果有关联，且玩家仍然可以将其作为上述参数的效果怪兽特殊召唤，防止处理时卡片状态或场地发生变动。
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,24212820,0x10db,TYPES_EFFECT_TRAP_MONSTER,300,600,4,RACE_WARRIOR,ATTRIBUTE_DARK) then
		c:AddMonsterAttribute(TYPE_EFFECT)
		-- 以自身效果（SUMMON_VALUE_SELF）作为特殊召唤方式，将这张卡守备表示特殊召唤到己方场上；跳过召唤条件检查，不解除苏生限制。
		Duel.SpecialSummonStep(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP_DEFENSE)
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
		-- 完成特殊召唤处理，使通过SpecialSummonStep设置的特殊召唤正式生效。
		Duel.SpecialSummonComplete()
	end
end
-- ③的守备力上升效果适用条件：仅当此卡是以②效果特殊召唤上场时（召唤类型为自身效果的特殊召唤）才适用。
function c24212820.defcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 定义墓地中「幻影」魔法·陷阱卡的过滤条件：属于「幻影」系列（0xdb），且是魔法或陷阱卡。
function c24212820.filter(c)
	return c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ③的守备力上升效果定义：此卡的守备力上升自己墓地的「幻影」魔法·陷阱卡数量×300。
function c24212820.defval(e,c)
	-- 计算墓地中符合条件的「幻影」魔法·陷阱卡数量并乘以300，作为此卡的守备力上升数值。
	return Duel.GetMatchingGroupCount(c24212820.filter,c:GetControler(),LOCATION_GRAVE,0,nil)*300
end
