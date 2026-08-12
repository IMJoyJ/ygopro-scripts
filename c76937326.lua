--ダイガスタ・ラプラムピリカ
-- 效果：
-- 调整＋调整以外的「薰风」怪兽1只以上
-- 自己对「大薰风兽使 翼心皮莉佳」1回合只能有1次特殊召唤。
-- ①：这张卡同调召唤成功的场合才能发动。「薰风」怪兽从手卡以及卡组各1只效果无效特殊召唤，只用那2只为素材把1只「薰风」同调怪兽同调召唤。这个回合，自己不是风属性怪兽不能特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的其他的「薰风」同调怪兽不会成为对方的效果的对象。
function c76937326.initial_effect(c)
	c:SetSPSummonOnce(76937326)
	-- 添加同调召唤手续：调整＋调整以外的「薰风」怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x10),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合才能发动。「薰风」怪兽从手卡以及卡组各1只效果无效特殊召唤，只用那2只为素材把1只「薰风」同调怪兽同调召唤。这个回合，自己不是风属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76937326,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c76937326.spcon)
	e1:SetTarget(c76937326.sptg)
	e1:SetOperation(c76937326.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的其他的「薰风」同调怪兽不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c76937326.imval)
	-- 设置不会成为对方的效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡同调召唤成功
function c76937326.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤手卡·卡组中可以特殊召唤的「薰风」怪兽
function c76937326.spfilter(c,e,tp)
	return c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查选出的2张卡是否分别来自手卡和卡组，且能作为素材同调召唤额外卡组的「薰风」同调怪兽
function c76937326.fselect(g,tp)
	-- 检查选出的卡片所在区域数量等于卡片数量（即手卡、卡组各1张），且额外卡组存在以这两张卡为素材可同调召唤的「薰风」同调怪兽
	return g:GetClassCount(Card.GetLocation)==#g and Duel.IsExistingMatchingCard(c76937326.synfilter,tp,LOCATION_EXTRA,0,1,nil,g)
end
-- 过滤额外卡组中可以用指定怪兽组作为素材进行同调召唤的「薰风」同调怪兽
function c76937326.synfilter(c,g)
	return c:IsSetCard(0x10) and c:IsSynchroSummonable(nil,g)
end
-- 过滤额外卡组中可以利用额外怪兽区域空格特殊召唤的「薰风」同调怪兽
function c76937326.chkfilter(c,tp)
	-- 检查该卡是否为「薰风」同调怪兽，且额外怪兽区域有足够的空格供其特殊召唤
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x10) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果①的发动准备（检查是否能特殊召唤2只怪兽、是否有足够的怪兽区域、手卡和卡组是否有符合条件的怪兽等，并设置操作信息）
function c76937326.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家本回合是否还能进行至少2次特殊召唤
		if not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return false end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 检查怪兽区域的空位数是否大于1（需要特殊召唤2只怪兽）
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return false end
		-- 获取额外卡组中满足特殊召唤条件的「薰风」同调怪兽组
		local cg=Duel.GetMatchingGroup(c76937326.chkfilter,tp,LOCATION_EXTRA,0,nil,tp)
		if #cg==0 then return false end
		-- 获取手卡和卡组中可以特殊召唤的「薰风」怪兽组
		local g=Duel.GetMatchingGroup(c76937326.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
		return g:CheckSubGroup(c76937326.fselect,2,2,tp)
	end
	-- 设置连锁处理的操作信息：从手卡·卡组特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果①的运行空间（特殊召唤手卡·卡组各1只「薰风」怪兽并使效果无效，之后将那2只作为素材同调召唤1只「薰风」同调怪兽，并适用风属性特召限制）
function c76937326.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerCanSpecialSummonCount(tp,2) and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		-- 获取额外卡组中满足特殊召唤条件的「薰风」同调怪兽组
		local cg=Duel.GetMatchingGroup(c76937326.chkfilter,tp,LOCATION_EXTRA,0,nil,tp)
		if #cg>0 then
			-- 获取手卡和卡组中可以特殊召唤的「薰风」怪兽组
			local g=Duel.GetMatchingGroup(c76937326.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:SelectSubGroup(tp,c76937326.fselect,false,2,2,tp)
			if sg then
				local tc=sg:GetFirst()
				while tc do
					-- 逐步特殊召唤选定的怪兽（表侧表示）
					Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
					-- 效果无效
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e1)
					local e2=e1:Clone()
					e2:SetCode(EFFECT_DISABLE_EFFECT)
					e2:SetValue(RESET_TURN_SET)
					tc:RegisterEffect(e2)
					tc=sg:GetNext()
				end
				-- 完成特殊召唤的最终处理
				Duel.SpecialSummonComplete()
				-- 获取本次操作实际特殊召唤成功的怪兽组
				local og=Duel.GetOperatedGroup()
				-- 刷新场地信息，确保后续同调召唤的合法性检测准确
				Duel.AdjustAll()
				if og:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
				-- 过滤额外卡组中能以特殊召唤的2只怪兽为素材进行同调召唤的「薰风」同调怪兽
				local tg=Duel.GetMatchingGroup(c76937326.synfilter,tp,LOCATION_EXTRA,0,nil,og)
				if og:GetCount()==sg:GetCount() and tg:GetCount()>0 then
					-- 提示玩家选择要同调召唤的怪兽
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					local rg=tg:Select(tp,1,1,nil)
					-- 以特殊召唤的2只怪兽为素材，对选定的怪兽进行同调召唤
					Duel.SynchroSummon(tp,rg:GetFirst(),nil,og)
				end
			end
		end
	end
	-- 这个回合，自己不是风属性怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c76937326.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤风属性以外怪兽的玩家限制效果
	Duel.RegisterEffect(e3,tp)
end
-- 限制只能特殊召唤风属性怪兽
function c76937326.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- 过滤自身以外的自己场上的「薰风」同调怪兽
function c76937326.imval(e,c)
	return c~=e:GetHandler() and c:IsSetCard(0x10) and c:IsType(TYPE_SYNCHRO)
end
