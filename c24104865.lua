--エーリアン・マザー
-- 效果：
-- 这张卡战斗破坏有A指示物放置的怪兽送去墓地的场合，那次战斗阶段结束时发动。破坏的那些怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在这张卡从场上离开的场合全部破坏。
function c24104865.initial_effect(c)
	-- 创建效果，类型为单次持续效果，不可无效化，在怪兽进入战斗阶段时触发。该效果用于检测攻击目标是否具有A指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_BATTLED)
	e1:SetOperation(c24104865.checkop)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	e1:SetLabelObject(g)
	g:KeepAlive()
	-- 创建效果，类型为单次持续效果，不可无效化，在怪兽被战斗破坏送入墓地时触发。该效果与e1关联，用于记录被战斗破坏的怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetOperation(c24104865.checkop2)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 创建效果，类型为字段诱发效果，在战斗阶段触发，限制特殊召唤次数为1。该效果用于特殊召唤被战斗破坏且具有A指示物的怪兽。将e2作为标签对象。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24104865,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c24104865.spcon)
	e3:SetTarget(c24104865.sptg)
	e3:SetOperation(c24104865.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 创建效果，类型为单次持续效果，在卡片离开场上时触发。该效果用于破坏所有与此卡有关系并具有特定FlagEffect的怪兽。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetOperation(c24104865.desop)
	c:RegisterEffect(e4)
end
c24104865.mentioned_counter={
	[0x100e]=true,
}
-- 检查战斗伤害发生后，攻击目标是否是A指示物怪兽，如果是则设置e1的标签值为1，否则为0。
function c24104865.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取被攻击的目标怪兽。
	local t=Duel.GetAttackTarget()
	if t and t~=c and t:GetCounter(0x100e)>0 then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 检查战斗破坏送入墓地时，如果e1的标签值为0则直接返回。记录被战斗破坏的怪兽到g组，并给目标怪兽注册一个FlagEffect，用于标记该怪兽可以被特殊召唤。
function c24104865.checkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==0 then return end
	local t=c:GetBattleTarget()
	local g=e:GetLabelObject():GetLabelObject()
	if c:GetFieldID()~=e:GetLabel() then
		g:Clear()
		e:SetLabel(c:GetFieldID())
	end
	-- 检测 e:GetHandler() 是否和本次战斗有关，通常用于 EVENT_BATTLE_DESTROYING,并且战斗破坏对方怪兽送去墓地
	if aux.bdgcon(e,tp,eg,ep,ev,re,r,rp) then
		g:AddCard(t)
		t:RegisterFlagEffect(24104865,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 检查效果是否能够触发，条件是卡片持有者的场上ID与e2的标签值相等。
function c24104865.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFieldID()==e:GetLabelObject():GetLabel()
end
-- 过滤函数，返回具有FlagEffect且可以特殊召唤的怪兽。
function c24104865.filter(c,e,tp)
	return c:GetFlagEffect(24104865)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的目标卡片。首先获取g组，然后使用filter函数筛选出符合条件的卡片，并将其设置为目标卡片。
function c24104865.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject():GetLabelObject()
	if chk==0 then return g:IsExists(c24104865.filter,1,nil,e,tp) end
	local dg=g:Filter(c24104865.filter,nil,e,tp)
	g:Clear()
	-- 将当前正在处理的连锁的对象设置成targets
	Duel.SetTargetCard(dg)
	-- 设置当前处理的连锁的操作信息此操作信息包含了效果处理中确定要处理的效果分类
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,dg,dg:GetCount(),0,0)
end
-- 过滤函数，返回与效果相关且可以特殊召唤的怪兽。
function c24104865.sfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行特殊召唤操作。首先获取场上可放置怪兽的数量，并根据【青眼精灵龙】(59822133)的效果调整数量限制。然后筛选出符合条件的怪兽，提示玩家选择要特殊召唤的卡片，并进行特殊召唤。
function c24104865.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 返回玩家player的场上location可用的[区域 zone 里的]空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 返回连锁chainc的信息，如果chainc=0，则返回当前正在处理的连锁的信息
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(c24104865.sfilter,nil,e,tp)
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	if sg:GetCount()>ft then sg=sg:Select(tp,ft,ft,nil) end
	local tc=sg:GetFirst()
	local c=e:GetHandler()
	while tc do
		-- 将tc进行特殊召唤。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(24104865,RESET_EVENT+RESETS_STANDARD,0,0)
		c:CreateRelation(tc,RESET_EVENT+0x1020000)
		tc=sg:GetNext()
	end
	-- 完成特殊召唤流程。
	Duel.SpecialSummonComplete()
end
-- 过滤函数，返回具有FlagEffect且与指定卡片相关的怪兽。
function c24104865.desfilter(c,rc)
	return c:GetFlagEffect(24104865)~=0 and rc:IsRelateToCard(c)
end
-- 执行破坏操作。获取所有具有FlagEffect且与此卡有关系的怪兽，并以效果为理由进行破坏。
function c24104865.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 过滤场上满足条件的卡片
	local dg=Duel.GetMatchingGroup(c24104865.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler())
	-- 以reason原因破坏targets去dest，返回值是实际被破坏的数量
	Duel.Destroy(dg,REASON_EFFECT)
end
