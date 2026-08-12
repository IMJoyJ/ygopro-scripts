--斬機超階乗
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以以自己墓地最多3只「斩机」怪兽为对象，从以下效果选择1个发动（同名卡最多1张）。
-- ●那些怪兽效果无效特殊召唤，只用那些怪兽为素材把1只「斩机」同调怪兽同调召唤。那个时候的同调素材怪兽不去墓地回到持有者卡组。
-- ●那些怪兽效果无效特殊召唤，只用那些怪兽为素材把1只「斩机」超量怪兽超量召唤。
function c87804365.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以以自己墓地最多3只「斩机」怪兽为对象，从以下效果选择1个发动（同名卡最多1张）。●那些怪兽效果无效特殊召唤，只用那些怪兽为素材把1只「斩机」同调怪兽同调召唤。那个时候的同调素材怪兽不去墓地回到持有者卡组。●那些怪兽效果无效特殊召唤，只用那些怪兽为素材把1只「斩机」超量怪兽超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,87804365+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c87804365.target)
	e1:SetOperation(c87804365.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以作为效果对象且可以特殊召唤的「斩机」怪兽
function c87804365.spfilter1(c,e,tp)
	return c:IsSetCard(0x132) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
-- 检查是否存在以选定怪兽组为素材可以同调召唤的「斩机」同调怪兽
function c87804365.fselect1(g,tp)
	-- 检查额外卡组是否存在至少1只以当前卡片组为素材可以进行同调召唤的怪兽
	return Duel.IsExistingMatchingCard(c87804365.synfilter,tp,LOCATION_EXTRA,0,1,nil,g)
end
-- 过滤额外卡组中，以指定卡片组（其中1只作为调整，其余作为非调整）为素材可以进行同调召唤的「斩机」同调怪兽
function c87804365.synfilter(c,g)
	return c:IsSetCard(0x132) and c:IsSynchroSummonable(nil,g,#g-1,#g-1)
end
-- 检查是否存在以选定怪兽组为素材可以超量召唤的「斩机」超量怪兽
function c87804365.fselect2(g,tp)
	-- 检查额外卡组是否存在至少1只以当前卡片组为素材可以进行超量召唤的怪兽
	return Duel.IsExistingMatchingCard(c87804365.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g)
end
-- 过滤额外卡组中，以指定卡片组全部作为素材可以进行超量召唤的「斩机」超量怪兽
function c87804365.xyzfilter(c,g)
	return c:IsSetCard(0x132) and c:IsXyzSummonable(g,#g,#g)
end
-- 效果发动的准备阶段，进行可行性检查、选择效果分支并选择墓地的怪兽作为对象
function c87804365.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 计算自己场上可用的怪兽区域空格数与最大限制数量3的较小值
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),3)
	-- 检查发动可行性：必须有可用怪兽区域，且玩家必须能够进行至少2次特殊召唤（一次苏生，一次额外召唤）
	if chk==0 and (ft<=0 or not Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.IsPlayerAffectedByEffect(tp,59822133)) then return false end
	-- 获取自己墓地中所有满足条件的「斩机」怪兽
	local g=Duel.GetMatchingGroup(c87804365.spfilter1,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 设置卡片组选择的附加检查函数，确保选择的怪兽卡名各不相同（同名卡最多1张）
	aux.GCheckAdditional=aux.dncheck
	local b1=g:CheckSubGroup(c87804365.fselect1,1,ft,tp)
	local b2=g:CheckSubGroup(c87804365.fselect2,1,ft,tp)
	-- 重置卡片组选择的附加检查函数
	aux.GCheckAdditional=nil
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 让玩家在“同调召唤”和“超量召唤”两个分支效果中选择一个发动
		op=Duel.SelectOption(tp,aux.Stringid(87804365,0),aux.Stringid(87804365,1))  --"苏生并同调召唤/苏生并超量召唤"
	elseif b1 then
		-- 仅能选择“同调召唤”分支效果
		op=Duel.SelectOption(tp,aux.Stringid(87804365,0))  --"苏生并同调召唤"
	else
		-- 仅能选择“超量召唤”分支效果，并将选项索引加1以匹配后续逻辑
		op=Duel.SelectOption(tp,aux.Stringid(87804365,1))+1  --"苏生并超量召唤"
	end
	e:SetLabel(op)
	local sg=nil
	-- 再次设置卡片组选择的附加检查函数，确保选择的对象怪兽卡名各不相同
	aux.GCheckAdditional=aux.dncheck
	if op==0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=g:SelectSubGroup(tp,c87804365.fselect1,false,1,ft,tp)
	else
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=g:SelectSubGroup(tp,c87804365.fselect2,false,1,ft,tp)
	end
	-- 重置卡片组选择的附加检查函数
	aux.GCheckAdditional=nil
	-- 将选定的怪兽组设置为当前效果的处理对象
	Duel.SetTargetCard(sg)
	-- 设置连锁的操作信息，表明此效果包含特殊召唤选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,sg:GetCount(),0,0)
end
-- 过滤仍与当前效果相关联且可以特殊召唤的对象怪兽
function c87804365.spfilter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理阶段，特殊召唤选定的墓地怪兽并使它们效果无效，然后使用这些怪兽作为素材进行同调召唤或超量召唤
function c87804365.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取当前连锁中仍合法的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c87804365.spfilter2,nil,e,tp)
	if #g==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if #g>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if #g>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	local tc=g:GetFirst()
	while tc do
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 那些怪兽效果无效特殊召唤
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
	-- 完成所有怪兽的特殊召唤处理
	Duel.SpecialSummonComplete()
	-- 获取本次操作中实际特殊召唤成功的怪兽卡片组
	local og=Duel.GetOperatedGroup()
	-- 立刻刷新场地信息，确保后续同调或超量召唤的素材合法性
	Duel.AdjustAll()
	if og:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<g:GetCount() then return end
	if op==0 then
		-- 获取额外卡组中，以实际特殊召唤成功的怪兽为素材可以进行同调召唤的「斩机」同调怪兽
		local tg=Duel.GetMatchingGroup(c87804365.synfilter,tp,LOCATION_EXTRA,0,nil,og)
		if og:GetCount()==g:GetCount() and tg:GetCount()>0 then
			local tc=og:GetFirst()
			while tc do
				-- 那个时候的同调素材怪兽不去墓地回到持有者卡组。
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
				e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				e3:SetValue(LOCATION_DECKBOT)
				tc:RegisterEffect(e3)
				tc=og:GetNext()
			end
			-- 提示玩家选择要特殊召唤（同调召唤）的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local rg=tg:Select(tp,1,1,nil)
			-- 使用特殊召唤的怪兽作为素材，对选定的「斩机」同调怪兽进行同调召唤
			Duel.SynchroSummon(tp,rg:GetFirst(),nil,og,#og-1,#og-1)
		end
	else
		-- 获取额外卡组中，以实际特殊召唤成功的怪兽为素材可以进行超量召唤的「斩机」超量怪兽
		local tg=Duel.GetMatchingGroup(c87804365.xyzfilter,tp,LOCATION_EXTRA,0,nil,og)
		if og:GetCount()==g:GetCount() and tg:GetCount()>0 then
			-- 提示玩家选择要特殊召唤（超量召唤）的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local rg=tg:Select(tp,1,1,nil)
			-- 使用特殊召唤的怪兽作为素材，对选定的「斩机」超量怪兽进行超量召唤
			Duel.XyzSummon(tp,rg:GetFirst(),og,#og,#og)
		end
	end
end
