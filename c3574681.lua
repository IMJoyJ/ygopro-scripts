--金科玉条
-- 效果：
-- 这个卡名在规则上也当作「宝玉」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：从卡组选2只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。那之后，从自己的手卡·墓地选和放置的卡卡名不同的1只「宝玉兽」怪兽特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
function c3574681.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组选2只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。那之后，从自己的手卡·墓地选和放置的卡卡名不同的1只「宝玉兽」怪兽特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,3574681+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c3574681.target)
	e1:SetOperation(c3574681.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c3574681.checkop)
	c:RegisterEffect(e2)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c3574681.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 筛选可作为永续魔法卡放置在魔陷区的「宝玉兽」怪兽：属于「宝玉兽」字段、是怪兽且未被禁止放置。
function c3574681.filter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 筛选满足特殊召唤条件的「宝玉兽」怪兽：卡名不同于已放置的两只，属于「宝玉兽」字段、是怪兽且可以被玩家tp特殊召唤。
function c3574681.spfilter(c,e,tp,code1,code2)
	return not c:IsCode(code1,code2) and c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查组g是否为正好2张，且手卡·墓地存在至少1只卡名不同于g中两张卡的「宝玉兽」怪兽可特殊召唤，以满足后续特殊召唤的条件。
function c3574681.gcheck(g,e,tp)
	if #g~=2 then return false end
	local a=g:GetFirst()
	local d=g:GetNext()
	-- 检查我方手卡·墓地是否存在至少1只卡名不同于a和d的「宝玉兽」怪兽可特殊召唤。
	return Duel.IsExistingMatchingCard(c3574681.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,a:GetCode(),d:GetCode())
end
-- 定义效果发动时的合法性判定：需要魔陷区至少2个可用格（从手牌发动时需额外1个）、怪兽区至少1个可用格，且卡组中存在满足gcheck的2张「宝玉兽」怪兽组合。
function c3574681.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取我方魔陷区的可用空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 获取我方卡组中所有符合条件的「宝玉兽」怪兽集合（用作后续选择放置的候选）。
	local g=Duel.GetMatchingGroup(c3574681.filter,tp,LOCATION_DECK,0,nil)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
	-- 在效果发动时检查条件：魔陷区空格数>1、怪兽区空格>0，且卡组中存在符合条件的2张「宝玉兽」怪兽组合。
	if chk==0 then return ft>1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:CheckSubGroup(c3574681.gcheck,2,2,e,tp) end
	-- 登记本次效果将执行特殊召唤操作：预计从手卡·墓地特殊召唤1只怪兽，供相关卡牌效果判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行①效果：从卡组选2只「宝玉兽」怪兽当作永续魔法放置到魔陷区，再从手卡·墓地选1只卡名不同的「宝玉兽」怪兽特殊召唤并装备此卡，并处理离场破坏的关联。
function c3574681.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取我方魔陷区的可用空格数量（处理阶段再次确认）。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 获取我方卡组中所有符合条件的「宝玉兽」怪兽集合（用于选择放置的卡）。
	local g=Duel.GetMatchingGroup(c3574681.filter,tp,LOCATION_DECK,0,nil)
	if ft>1 then
		-- 显示提示，让玩家选择要放置到场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		local sg=g:SelectSubGroup(tp,c3574681.gcheck,false,2,2,e,tp)
		if not sg then return end
		local ac=sg:GetFirst()
		local bc=sg:GetNext()
		-- 尝试将选中的第一只「宝玉兽」怪兽移动到己方魔陷区并表侧表示放置；成功则继续后续处理。
		if Duel.MoveToField(ac,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 同时将选中的第二只「宝玉兽」怪兽移动到己方魔陷区并表侧表示放置；两只都成功才继续。
			and Duel.MoveToField(bc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			-- 当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
			local e1=Effect.CreateEffect(c)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			ac:RegisterEffect(e1)
			-- 当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
			local e2=Effect.CreateEffect(c)
			e2:SetCode(EFFECT_CHANGE_TYPE)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e2:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			bc:RegisterEffect(e2)
			-- 如果怪兽区没有可用空格，则无法特殊召唤，直接终止处理。
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			-- 获取手卡·墓地中可被特殊召唤、卡名不同于已放置的两只的「宝玉兽」怪兽集合，并通过王家长眠之谷的过滤（若墓地效果被无效则排除）。
			local rg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c3574681.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp,ac:GetCode(),bc:GetCode())
			if #rg==0 then return end
			-- 中断当前效果处理，使后续特殊召唤作为另一个处理流程进行，避免时点被错误占用。
			Duel.BreakEffect()
			-- 显示提示，让玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=rg:Select(tp,1,1,nil):GetFirst()
			-- 以表侧表示将选择的怪兽特殊召唤（作为特殊召唤过程的一步）；成功则进行装备。
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				-- 将效果卡「金科玉条」作为装备卡装备给刚特殊召唤的怪兽。
				Duel.Equip(tp,c,tc)
				-- 把这张卡装备。
				local e1=Effect.CreateEffect(tc)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(c3574681.eqlimit)
				c:RegisterEffect(e1)
			end
			-- 完成特殊召唤过程，结束SpecialSummonStep系列操作。
			Duel.SpecialSummonComplete()
		end
	end
end
-- 装备限制判定函数：只有被特殊召唤的那只「宝玉兽」怪兽才能装备这张卡（e:GetOwner()==c）。
function c3574681.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 在离场前事件中记录本卡是否处于无效状态，将标记（label）设为1或0，供离场时判断是否执行破坏。
function c3574681.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 在离场事件发生后，若此前标记为未无效，则获取本卡装备的怪兽；若该怪兽还在怪兽区，则将其破坏。
function c3574681.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果原因破坏装备怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
