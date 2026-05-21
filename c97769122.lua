--バリアンズ・カオス・ドロー
-- 效果：
-- ①：自己抽卡阶段通过把通常抽卡的这张卡持续公开，那个回合的主要阶段1，可以从以下效果选择1个发动。
-- ●从卡组把1张「七皇」通常魔法卡送去墓地才能发动。这个效果变成和那张魔法卡发动时的效果相同。
-- ●从卡组把最多2只怪兽效果无效特殊召唤，用包含那些怪兽全部在内的自己场上的怪兽为素材把1只「No.」超量怪兽超量召唤。
function c97769122.initial_effect(c)
	-- ①：自己抽卡阶段通过把通常抽卡的这张卡持续公开，那个回合的主要阶段1，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c97769122.regcon)
	e1:SetOperation(c97769122.regop)
	c:RegisterEffect(e1)
	-- ●从卡组把1张「七皇」通常魔法卡送去墓地才能发动。这个效果变成和那张魔法卡发动时的效果相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97769122,1))  --"复制「七皇」通常魔法卡"
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c97769122.condition)
	e2:SetCost(c97769122.cpcost)
	e2:SetTarget(c97769122.cptg)
	e2:SetOperation(c97769122.cpop)
	c:RegisterEffect(e2)
	-- ●从卡组把最多2只怪兽效果无效特殊召唤，用包含那些怪兽全部在内的自己场上的怪兽为素材把1只「No.」超量怪兽超量召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(97769122,2))  --"从卡组特殊召唤并超量召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(c97769122.condition)
	e3:SetTarget(c97769122.xyztg)
	e3:SetOperation(c97769122.xyzop)
	c:RegisterEffect(e3)
end
-- 注册抽卡阶段通常抽卡时公开手牌效果的条件判断函数
function c97769122.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前是否为抽卡阶段、该玩家本回合未注册过此效果，且该卡是通过规则抽卡加入手牌
	return Duel.GetFlagEffect(tp,97769122)==0 and Duel.GetCurrentPhase()==PHASE_DRAW and c:IsReason(REASON_RULE)
end
-- 注册抽卡阶段通常抽卡时公开手牌效果的处理函数
function c97769122.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 询问玩家是否要持续公开手牌中的这张卡
	if Duel.SelectYesNo(tp,aux.Stringid(97769122,0)) then  --"是否要持续公开「异晶人的混沌抽卡」？"
		-- 通过把通常抽卡的这张卡持续公开
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(97769122,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1,EFFECT_FLAG_CLIENT_HINT,1,0,66)
	end
end
-- 检查当前是否为主要阶段1，且该卡已被持续公开
function c97769122.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1，且该卡具有持续公开的标记
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and e:GetHandler():GetFlagEffect(97769122)~=0
end
-- 复制效果的发动代价处理函数
function c97769122.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- 过滤卡组中可被复制效果的「七皇」通常魔法卡
function c97769122.cpfilter(c)
	return c:GetType()==TYPE_SPELL and c:IsSetCard(0x175) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(true,true,false)~=nil
end
-- 复制效果的发动准备与效果复制处理函数
function c97769122.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查卡组中是否存在可被复制效果的「七皇」通常魔法卡
		return Duel.IsExistingMatchingCard(c97769122.cpfilter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张满足条件的「七皇」通常魔法卡
	local g=Duel.SelectMatchingCard(tp,c97769122.cpfilter,tp,LOCATION_DECK,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(true,true,true)
	-- 将选择的「七皇」通常魔法卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前的连锁操作信息，防止被针对特定分类的效果响应
	Duel.ClearOperationInfo(0)
end
-- 复制效果的执行函数，运行被复制魔法卡的效果处理
function c97769122.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
-- 过滤卡组中可以特殊召唤的怪兽
function c97769122.filter1(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤场上表侧表示且等级在1星以上的怪兽
function c97769122.filter2(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 检查选定的特殊召唤怪兽与场上怪兽组合后，是否能进行合法的「No.」超量召唤
function c97769122.fselect(sg,tp)
	-- 获取自己场上所有表侧表示且有等级的怪兽
	local mg=Duel.GetMatchingGroup(c97769122.filter2,tp,LOCATION_MZONE,0,nil)
	mg:Merge(sg)
	return mg:CheckSubGroup(c97769122.matfilter,1,#mg,tp,sg)
end
-- 检查超量素材子集是否包含所有新特殊召唤的怪兽，且能用于超量召唤额外卡组的「No.」怪兽
function c97769122.matfilter(sg,tp,g)
	-- 检查选用的超量素材中是否完整包含了所有本次特殊召唤的怪兽
	if sg:Filter(aux.IsInGroup,nil,g):GetCount()~=g:GetCount() then return false end
	-- 检查额外卡组是否存在能以选定卡片为素材进行超量召唤的「No.」怪兽
	return Duel.IsExistingMatchingCard(c97769122.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,sg)
end
-- 过滤额外卡组中能以指定素材组进行超量召唤的「No.」超量怪兽
function c97769122.xyzfilter(c,mg)
	return c:IsSetCard(0x48) and c:IsXyzSummonable(mg,#mg,#mg)
end
-- 特殊召唤并超量召唤效果的发动准备与合法性检测
function c97769122.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有可以特殊召唤的怪兽
	local mg=Duel.GetMatchingGroup(c97769122.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	-- 获取自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 检查玩家是否能进行2次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and mg:CheckSubGroup(c97769122.fselect,1,ft,tp) end
	-- 设置特殊召唤的操作信息，包含卡组和额外卡组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 特殊召唤并超量召唤效果的处理函数
function c97769122.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查玩家是否能进行2次特殊召唤，且场上是否有空位，若不满足则结束处理
	if not Duel.IsPlayerCanSpecialSummonCount(tp,2) or ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取卡组中所有可以特殊召唤的怪兽
	local mg=Duel.GetMatchingGroup(c97769122.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=mg:SelectSubGroup(tp,c97769122.fselect,false,1,ft,tp)
	if not g then return end
	local tc=g:GetFirst()
	while tc do
		-- 将选定的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 效果无效特殊召唤
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 完成所有分步特殊召唤的处理
	Duel.SpecialSummonComplete()
	-- 刷新场上卡片状态信息
	Duel.AdjustAll()
	if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<#g then return end
	-- 获取额外卡组中所有的「No.」超量怪兽
	local exg=Duel.GetMatchingGroup(c97769122.xyzfilter2,tp,LOCATION_EXTRA,0,nil)
	local xyzg=exg:Filter(c97769122.ovfilter,nil,tp,g)
	if xyzg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 获取自己场上所有表侧表示且有等级的怪兽
		local fg=Duel.GetMatchingGroup(c97769122.filter2,tp,LOCATION_MZONE,0,nil)
		local sg=fg:SelectSubGroup(tp,c97769122.gselect,false,1,7,xyz,g)
		-- 使用选定的素材将指定的「No.」超量怪兽进行超量召唤
		Duel.XyzSummon(tp,xyz,sg)
	end
end
-- 过滤额外卡组中的「No.」超量怪兽
function c97769122.xyzfilter2(c)
	return c:IsSetCard(0x48)
end
-- 检查额外卡组的某只「No.」怪兽是否能以包含新特召怪兽在内的场上怪兽为素材进行超量召唤
function c97769122.ovfilter(c,tp,sg)
	-- 获取自己场上所有表侧表示且有等级的怪兽
	local mg=Duel.GetMatchingGroup(c97769122.filter2,tp,LOCATION_MZONE,0,nil)
	mg:Merge(sg)
	return mg:CheckSubGroup(c97769122.gselect,1,#mg,c,sg)
end
-- 检查选定的超量素材是否包含所有新特殊召唤的怪兽，且数量和条件符合该「No.」怪兽的超量召唤要求
function c97769122.gselect(sg,c,g)
	-- 检查选用的超量素材中是否完整包含了所有本次特殊召唤的怪兽
	if sg:Filter(aux.IsInGroup,nil,g):GetCount()~=g:GetCount() then return false end
	return c:IsXyzSummonable(sg,#sg,#sg)
end
