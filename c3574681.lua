--金科玉条
-- 效果：
-- 这个卡名在规则上也当作「宝玉」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：从卡组选2只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。那之后，从自己的手卡·墓地选和放置的卡卡名不同的1只「宝玉兽」怪兽特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
function c3574681.initial_effect(c)
	-- 效果发动时，设置连锁分类为特殊召唤和装备，类型为发动效果，时点为自由连锁，发动次数限制为1次，目标函数为c3574681.target，处理函数为c3574681.operation
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,3574681+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c3574681.target)
	e1:SetOperation(c3574681.operation)
	c:RegisterEffect(e1)
	-- 当此卡离开场上的前一刻，记录其是否被无效
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c3574681.checkop)
	c:RegisterEffect(e2)
	-- 当此卡离开场上时，若其在离开前未被无效，则破坏装备的怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c3574681.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 过滤函数，返回满足宝玉兽卡组、怪兽类型且未被禁止的卡
function c3574681.filter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 过滤函数，返回满足宝玉兽卡组、怪兽类型、未被禁止且可特殊召唤的卡，且不能与已放置的卡同名
function c3574681.spfilter(c,e,tp,code1,code2)
	return not c:IsCode(code1,code2) and c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查所选的2张卡是否满足后续特殊召唤条件
function c3574681.gcheck(g,e,tp)
	if #g~=2 then return false end
	local a=g:GetFirst()
	local d=g:GetNext()
	-- 检查是否存在满足特殊召唤条件的宝玉兽怪兽
	return Duel.IsExistingMatchingCard(c3574681.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,a:GetCode(),d:GetCode())
end
-- 目标函数，检查是否满足发动条件：魔法陷阱区空位大于1，怪兽区空位大于0，且卡组中存在满足条件的2张宝玉兽怪兽
function c3574681.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家当前魔法陷阱区可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 获取玩家卡组中满足宝玉兽怪兽条件的卡组
	local g=Duel.GetMatchingGroup(c3574681.filter,tp,LOCATION_DECK,0,nil)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
	-- 判断是否满足发动条件：魔法陷阱区空位大于1，怪兽区空位大于0，且卡组中存在满足条件的2张宝玉兽怪兽
	if chk==0 then return ft>1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:CheckSubGroup(c3574681.gcheck,2,2,e,tp) end
	-- 设置操作信息，表示将特殊召唤1张来自手牌或墓地的宝玉兽怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 处理函数，从卡组选择2张宝玉兽怪兽作为永续魔法卡放置于魔法陷阱区，然后从手牌或墓地选择一张不同名的宝玉兽怪兽特殊召唤并装备
function c3574681.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家当前魔法陷阱区可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 获取玩家卡组中满足宝玉兽怪兽条件的卡组
	local g=Duel.GetMatchingGroup(c3574681.filter,tp,LOCATION_DECK,0,nil)
	if ft>1 then
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		local sg=g:SelectSubGroup(tp,c3574681.gcheck,false,2,2,e,tp)
		if not sg then return end
		local ac=sg:GetFirst()
		local bc=sg:GetNext()
		-- 尝试将第一张卡移动到魔法陷阱区
		if Duel.MoveToField(ac,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 尝试将第二张卡移动到魔法陷阱区
			and Duel.MoveToField(bc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			-- 将第一张卡变为永续魔法卡
			local e1=Effect.CreateEffect(c)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			ac:RegisterEffect(e1)
			-- 将第二张卡变为永续魔法卡
			local e2=Effect.CreateEffect(c)
			e2:SetCode(EFFECT_CHANGE_TYPE)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e2:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			bc:RegisterEffect(e2)
			-- 若怪兽区空位不足则返回
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			-- 获取满足特殊召唤条件且未受王家长眠之谷影响的宝玉兽怪兽
			local rg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c3574681.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp,ac:GetCode(),bc:GetCode())
			if #rg==0 then return end
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=rg:Select(tp,1,1,nil):GetFirst()
			-- 尝试特殊召唤所选的宝玉兽怪兽
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				-- 将此卡装备给特殊召唤的宝玉兽怪兽
				Duel.Equip(tp,c,tc)
				-- 设置装备限制效果，确保只有装备的宝玉兽怪兽能装备此卡
				local e1=Effect.CreateEffect(tc)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(c3574681.eqlimit)
				c:RegisterEffect(e1)
			end
			-- 完成特殊召唤步骤
			Duel.SpecialSummonComplete()
		end
	end
end
-- 装备限制函数，确保只有装备的宝玉兽怪兽能装备此卡
function c3574681.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 检查此卡是否被无效，若无效则标记为1，否则为0
function c3574681.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 若此卡未被无效，则破坏装备的宝玉兽怪兽
function c3574681.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果原因破坏装备的宝玉兽怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
