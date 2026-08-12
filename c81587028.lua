--おもちゃ箱
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被破坏送去墓地的场合才能发动。从卡组把2只攻击力或守备力是0的通常怪兽守备表示特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽不能作为同调素材，下次的自己结束阶段破坏。
function c81587028.initial_effect(c)
	-- ①：这张卡被破坏送去墓地的场合才能发动。从卡组把2只攻击力或守备力是0的通常怪兽守备表示特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽不能作为同调素材，下次的自己结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81587028,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,81587028)
	e1:SetCondition(c81587028.spcon)
	e1:SetTarget(c81587028.sptg)
	e1:SetOperation(c81587028.spop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：此卡是否因破坏而送去墓地
function c81587028.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤卡组中满足条件的怪兽：攻击力或守备力为0的通常怪兽，且可以守备表示特殊召唤
function c81587028.filter1(c,e,tp)
	return c:IsType(TYPE_NORMAL) and (c:IsAttack(0) or c:IsDefense(0)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的可行性检测与操作信息设置
function c81587028.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 检查自己场上的怪兽区域空余格子是否少于2个
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		-- 获取卡组中所有符合条件的怪兽组
		local g=Duel.GetMatchingGroup(c81587028.filter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置连锁处理的操作信息：从卡组特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择2只卡名不同的符合条件怪兽守备表示特殊召唤，并适用限制效果
function c81587028.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时，若自己场上的怪兽区域空余格子少于2个，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 效果处理时，重新获取卡组中所有符合条件的怪兽组
	local g=Duel.GetMatchingGroup(c81587028.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetClassCount(Card.GetCode)>=2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从符合条件的怪兽中选择2只卡名不同的怪兽
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		local tc1=sg:GetFirst()
		local tc2=sg:GetNext()
		-- 将第一只怪兽以表侧守备表示特殊召唤的准备步骤
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 将第二只怪兽以表侧守备表示特殊召唤的准备步骤
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		tc1:RegisterFlagEffect(81587028,RESET_EVENT+RESETS_STANDARD,0,1)
		tc2:RegisterFlagEffect(81587028,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 这个效果特殊召唤的怪兽不能作为同调素材
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e1)
		local e2=e1:Clone()
		tc2:RegisterEffect(e2)
		-- 完成所有准备步骤中的特殊召唤
		Duel.SpecialSummonComplete()
		sg:KeepAlive()
		-- 下次的自己结束阶段破坏。
		local de=Effect.CreateEffect(e:GetHandler())
		de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		de:SetCode(EVENT_PHASE+PHASE_END)
		de:SetCountLimit(1)
		de:SetLabelObject(sg)
		de:SetCondition(c81587028.descon)
		de:SetOperation(c81587028.desop)
		-- 判断当前是否已处于自己的结束阶段（若是，则破坏时点需顺延至下个自己的结束阶段）
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_END then
			-- 记录当前回合数，以便在后续判断中避开当前回合
			de:SetLabel(Duel.GetTurnCount())
			de:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			de:SetLabel(0)
			de:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		end
		-- 注册全局环境效果，用于在结束阶段执行破坏处理
		Duel.RegisterEffect(de,tp)
	end
end
-- 检查结束阶段破坏效果的发动条件：被特殊召唤的怪兽依然存在，且当前是自己的结束阶段，并且不是刚发动效果的那个回合的结束阶段
function c81587028.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c81587028.desfilter,1,nil) then
		g:DeleteGroup()
		e:Reset()
		return false
	end
	-- 判断当前是否为自己的回合，且并非效果发动时的那个回合（确保在“下次”结束阶段适用）
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetLabel()
end
-- 检查怪兽是否带有该效果特殊召唤的标记
function c81587028.desfilter(c)
	return c:GetFlagEffect(81587028)>0
end
-- 结束阶段破坏效果的处理：筛选出仍带有标记的怪兽并将其破坏
function c81587028.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c81587028.desfilter,nil)
	g:DeleteGroup()
	-- 因效果将目标怪兽破坏
	Duel.Destroy(tg,REASON_EFFECT)
end
