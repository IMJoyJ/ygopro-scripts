--エーリアン・マザー
-- 效果：
-- 这张卡战斗破坏有A指示物放置的怪兽送去墓地的场合，那次战斗阶段结束时发动。破坏的那些怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在这张卡从场上离开的场合全部破坏。
function c24104865.initial_effect(c)
	-- 这张卡战斗破坏有A指示物放置的怪兽（检测被攻击的怪兽是否有A指示物放置）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_BATTLED)
	e1:SetOperation(c24104865.checkop)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	e1:SetLabelObject(g)
	g:KeepAlive()
	-- 这张卡战斗破坏有A指示物放置的怪兽送去墓地的场合（记录被战斗破坏送去墓地的那些怪兽）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetOperation(c24104865.checkop2)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 那次战斗阶段结束时发动。破坏的那些怪兽在自己场上特殊召唤。
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
	-- 这个效果特殊召唤的怪兽在这张卡从场上离开的场合全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetOperation(c24104865.desop)
	c:RegisterEffect(e4)
end
c24104865.mentioned_counter={
	[0x100e]=true,
}
-- 战斗伤害计算后检测这张卡攻击的对方怪兽是否放置有A指示物，有则记录标记为1，否则为0
function c24104865.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本次战斗的攻击目标
	local t=Duel.GetAttackTarget()
	if t and t~=c and t:GetCounter(0x100e)>0 then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 这张卡战斗破坏怪兽送去墓地时，若该怪兽放置有A指示物，则把被破坏的怪兽加入记录卡组并为其登记战斗阶段结束时重置的旗标
function c24104865.checkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==0 then return end
	local t=c:GetBattleTarget()
	local g=e:GetLabelObject():GetLabelObject()
	if c:GetFieldID()~=e:GetLabel() then
		g:Clear()
		e:SetLabel(c:GetFieldID())
	end
	-- 检测这张卡是否与本次战斗有关，且把对方怪兽战斗破坏送去了墓地
	if aux.bdgcon(e,tp,eg,ep,ev,re,r,rp) then
		g:AddCard(t)
		t:RegisterFlagEffect(24104865,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 发动条件：确认这张卡仍是记录时的同一张卡（FieldID一致）
function c24104865.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFieldID()==e:GetLabelObject():GetLabel()
end
-- 过滤器：带有本卡旗标且可以被特殊召唤的卡
function c24104865.filter(c,e,tp)
	return c:GetFlagEffect(24104865)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 确认记录的怪兽中存在可特殊召唤的卡，将其设为连锁对象并设置特殊召唤的操作信息，随后清空记录卡组
function c24104865.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject():GetLabelObject()
	if chk==0 then return g:IsExists(c24104865.filter,1,nil,e,tp) end
	local dg=g:Filter(c24104865.filter,nil,e,tp)
	g:Clear()
	-- 把要特殊召唤的怪兽组设置为当前连锁的对象
	Duel.SetTargetCard(dg)
	-- 设置操作信息：特殊召唤这些怪兽，数量为对象组的数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,dg,dg:GetCount(),0,0)
end
-- 过滤器：仍与该效果关联且可以被特殊召唤的卡
function c24104865.sfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 按自己场上可用怪兽区数量（受青眼精灵龙效果影响时只能特召1只）选取对象，逐个以表侧表示特殊召唤，并登记旗标及与这张卡的关联，最后完成特殊召唤
function c24104865.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上主要怪兽区的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 取得当前连锁的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(c24104865.sfilter,nil,e,tp)
	-- 向玩家提示请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	if sg:GetCount()>ft then sg=sg:Select(tp,ft,ft,nil) end
	local tc=sg:GetFirst()
	local c=e:GetHandler()
	while tc do
		-- 以表侧表示将该怪兽特殊召唤（特殊召唤的分解步骤）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(24104865,RESET_EVENT+RESETS_STANDARD,0,0)
		c:CreateRelation(tc,RESET_EVENT+0x1020000)
		tc=sg:GetNext()
	end
	-- 完成本次特殊召唤的分解处理
	Duel.SpecialSummonComplete()
end
-- 过滤器：带有本卡旗标且与离场的这张卡相关联的怪兽
function c24104865.desfilter(c,rc)
	return c:GetFlagEffect(24104865)~=0 and rc:IsRelateToCard(c)
end
-- 这张卡离场时，检索双方场上满足条件的怪兽并全部以效果破坏
function c24104865.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索双方场上与这张卡关联且带有本卡旗标的怪兽
	local dg=Duel.GetMatchingGroup(c24104865.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler())
	-- 以效果原因破坏这些怪兽
	Duel.Destroy(dg,REASON_EFFECT)
end
