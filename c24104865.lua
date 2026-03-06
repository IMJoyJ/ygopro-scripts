--エーリアン・マザー
-- 效果：
-- 这张卡战斗破坏有A指示物放置的怪兽送去墓地的场合，那次战斗阶段结束时发动。破坏的那些怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在这张卡从场上离开的场合全部破坏。
function c24104865.initial_effect(c)
	-- 这张卡战斗破坏有A指示物放置的怪兽送去墓地的场合，那次战斗阶段结束时发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_BATTLED)
	e1:SetOperation(c24104865.checkop)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	e1:SetLabelObject(g)
	g:KeepAlive()
	-- 破坏的那些怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetOperation(c24104865.checkop2)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 这个效果特殊召唤的怪兽在这张卡从场上离开的场合全部破坏。
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
	-- 效果作用
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetOperation(c24104865.desop)
	c:RegisterEffect(e4)
end
-- 检测是否为战斗破坏对方怪兽的场合，若满足条件则设置标签为1
function c24104865.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击目标怪兽
	local t=Duel.GetAttackTarget()
	if t and t~=c and t:GetCounter(0x100e)>0 then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 效果作用
function c24104865.checkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==0 then return end
	local t=c:GetBattleTarget()
	local g=e:GetLabelObject():GetLabelObject()
	if c:GetFieldID()~=e:GetLabel() then
		g:Clear()
		e:SetLabel(c:GetFieldID())
	end
	-- 判断是否为战斗破坏对方怪兽的事件
	if aux.bdgcon(e,tp,eg,ep,ev,re,r,rp) then
		g:AddCard(t)
		t:RegisterFlagEffect(24104865,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 判断是否为该卡的战斗阶段结束时触发
function c24104865.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFieldID()==e:GetLabelObject():GetLabel()
end
-- 过滤满足条件的怪兽（拥有flag 24104865且可特殊召唤）
function c24104865.filter(c,e,tp)
	return c:GetFlagEffect(24104865)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的目标卡片并准备操作信息
function c24104865.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject():GetLabelObject()
	if chk==0 then return g:IsExists(c24104865.filter,1,nil,e,tp) end
	local dg=g:Filter(c24104865.filter,nil,e,tp)
	g:Clear()
	-- 设置连锁操作的目标卡片
	Duel.SetTargetCard(dg)
	-- 设置操作信息为特殊召唤类别
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,dg,dg:GetCount(),0,0)
end
-- 过滤满足条件的怪兽（与效果相关且可特殊召唤）
function c24104865.sfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理特殊召唤操作，包括检测召唤数量限制和执行召唤
function c24104865.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取当前连锁的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(c24104865.sfilter,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	if sg:GetCount()>ft then sg=sg:Select(tp,ft,ft,nil) end
	local tc=sg:GetFirst()
	local c=e:GetHandler()
	while tc do
		-- 特殊召唤一张怪兽
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(24104865,RESET_EVENT+RESETS_STANDARD,0,0)
		c:CreateRelation(tc,RESET_EVENT+0x1020000)
		tc=sg:GetNext()
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 过滤满足条件的怪兽（拥有flag 24104865且与效果相关）
function c24104865.desfilter(c,rc)
	return c:GetFlagEffect(24104865)~=0 and rc:IsRelateToCard(c)
end
-- 效果作用
function c24104865.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的怪兽组
	local dg=Duel.GetMatchingGroup(c24104865.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler())
	-- 以效果原因破坏目标怪兽
	Duel.Destroy(dg,REASON_EFFECT)
end
