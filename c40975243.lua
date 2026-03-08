--鉄獣の抗戦
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的墓地·除外状态的兽族·兽战士族·鸟兽族怪兽任意数量效果无效特殊召唤，只用那些怪兽为素材进行1只「铁兽」连接怪兽的连接召唤。
function c40975243.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,40975243+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c40975243.target)
	e1:SetOperation(c40975243.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的怪兽：兽族·兽战士族·鸟兽族且可以特殊召唤的墓地或除外状态的怪兽
function c40975243.spfilter(c,e,tp)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 检查是否存在满足连接召唤条件的「铁兽」连接怪兽
function c40975243.fselect(g,tp)
	-- 检查是否存在满足连接召唤条件的「铁兽」连接怪兽
	return Duel.IsExistingMatchingCard(c40975243.lkfilter,tp,LOCATION_EXTRA,0,1,nil,g)
end
-- 检查连接怪兽是否可以使用指定数量的素材进行连接召唤
function c40975243.lkfilter(c,g)
	return c:IsSetCard(0x14d) and c:IsLinkSummonable(g,nil,g:GetCount(),g:GetCount())
end
-- 检查额外卡组中是否存在「铁兽」连接怪兽且其召唤区域可用
function c40975243.chkfilter(c,tp)
	-- 检查额外卡组中是否存在「铁兽」连接怪兽且其召唤区域可用
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x14d) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果作用：判断是否满足发动条件，包括特殊召唤次数、场地空位、是否存在可用的连接怪兽
function c40975243.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否可以特殊召唤2次
		if not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return false end
		-- 获取玩家场上主怪兽区域的空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return false end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 获取满足条件的「铁兽」连接怪兽组
		local cg=Duel.GetMatchingGroup(c40975243.chkfilter,tp,LOCATION_EXTRA,0,nil,tp)
		if #cg==0 then return false end
		local _,maxlink=cg:GetMaxGroup(Card.GetLink)
		if maxlink>ft then maxlink=ft end
		-- 获取满足条件的墓地或除外状态的兽族·兽战士族·鸟兽族怪兽组
		local g=Duel.GetMatchingGroup(c40975243.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
		return g:CheckSubGroup(c40975243.fselect,1,maxlink,tp)
	end
	-- 设置连锁操作信息，提示将要特殊召唤的卡牌来源
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果作用：执行发动效果，包括选择并特殊召唤怪兽、使其效果无效、进行连接召唤
function c40975243.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否可以特殊召唤2次
	if not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return end
	-- 获取玩家场上主怪兽区域的空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取满足条件的墓地或除外状态的兽族·兽战士族·鸟兽族怪兽组（排除王家长眠之谷影响）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c40975243.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	-- 获取满足条件的「铁兽」连接怪兽组
	local cg=Duel.GetMatchingGroup(c40975243.chkfilter,tp,LOCATION_EXTRA,0,nil,tp)
	local _,maxlink=cg:GetMaxGroup(Card.GetLink)
	if ft>0 and maxlink then
		if maxlink>ft then maxlink=ft end
		-- 提示玩家选择要特殊召唤的卡牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroup(tp,c40975243.fselect,false,1,maxlink,tp)
		if not sg then return end
		local tc=sg:GetFirst()
		while tc do
			-- 特殊召唤一张怪兽到场上
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 效果原文内容：①：自己的墓地·除外状态的兽族·兽战士族·鸟兽族怪兽任意数量效果无效特殊召唤，只用那些怪兽为素材进行1只「铁兽」连接怪兽的连接召唤。
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
		-- 完成特殊召唤步骤
		Duel.SpecialSummonComplete()
		-- 获取实际操作的卡牌组
		local og=Duel.GetOperatedGroup()
		-- 刷新场地信息
		Duel.AdjustAll()
		if og:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<sg:GetCount() then return end
		-- 获取满足连接召唤条件的「铁兽」连接怪兽组
		local tg=Duel.GetMatchingGroup(c40975243.lkfilter,tp,LOCATION_EXTRA,0,nil,og)
		if og:GetCount()==sg:GetCount() and tg:GetCount()>0 then
			-- 提示玩家选择要特殊召唤的卡牌
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local rg=tg:Select(tp,1,1,nil)
			-- 使用指定素材进行连接召唤
			Duel.LinkSummon(tp,rg:GetFirst(),og,nil,#og,#og)
		end
	end
end
