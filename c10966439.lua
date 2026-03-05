--マシュマオ☆ヤミー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有兽族·光属性怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己墓地把1张「味美喵」魔法·陷阱卡加入手卡。同调怪兽的效果特殊召唤的场合，也能作为代替把自己的卡组·除外状态的1张「味美喵」场地魔法卡或「味美喵」永续魔法·永续陷阱卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 初始化效果函数，创建并注册三个效果：①特殊召唤效果、②回收效果（召唤成功时发动）、③回收效果（特殊召唤成功时发动）、④记录同调召唤的连续效果。
function s.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合或者只有兽族·光属性怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己墓地把1张「味美喵」魔法·陷阱卡加入手卡。同调怪兽的效果特殊召唤的场合，也能作为代替把自己的卡组·除外状态的1张「味美喵」场地魔法卡或「味美喵」永续魔法·永续陷阱卡在自己场上表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收效果"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 这个卡名的①②的效果1回合各能使用1次。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(s.checkop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上是否存在非正面表示或非光属性兽族怪兽。
function s.cfilter(c)
	return c:IsFacedown() or not (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST))
end
-- 判断条件函数，当场上不存在非正面表示或非光属性兽族怪兽时满足条件。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当场上不存在非正面表示或非光属性兽族怪兽时满足条件。
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的目标设定函数，检查是否满足特殊召唤条件。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有可用区域进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，将此卡特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 执行特殊召唤操作，将此卡以正面表示形式特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于筛选墓地中的「味美喵」魔法·陷阱卡。
function s.thfilter(c)
	return c:IsSetCard(0x1ca) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 过滤函数，用于筛选卡组或除外状态中的「味美喵」永续魔法·永续陷阱卡。
function s.pfilter(c,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1ca)
		-- 检查场上是否有可用区域放置永续魔法卡。
		and (c:IsType(TYPE_CONTINUOUS) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		or c:IsType(TYPE_FIELD))
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 回收效果的目标设定函数，检查是否满足回收条件。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在「味美喵」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查卡组或除外状态中是否存在「味美喵」永续魔法·永续陷阱卡。
		or Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,tp)
		and e:GetHandler():GetFlagEffect(id)>0 end
	if e:GetHandler():GetFlagEffect(id)>0 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	-- 设置操作信息，表示将从墓地回收一张「味美喵」魔法·陷阱卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 回收效果的处理函数，根据选择决定从墓地回收卡或从卡组/除外状态放置卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查墓地中是否存在满足条件的「味美喵」魔法·陷阱卡。
	local b1=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
	-- 检查卡组或除外状态中是否存在满足条件的「味美喵」永续魔法·永续陷阱卡。
	local b2=e:GetLabel()==1 and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,tp)
	-- 判断是否选择从墓地回收卡，若选择则不进行卡组/除外状态的卡放置。
	if b1 and (not b2 or not Duel.SelectYesNo(tp,aux.Stringid(id,2))) then  --"是否放置永续·场地卡？"
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择一张满足条件的「味美喵」魔法·陷阱卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡送入手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方查看送入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	elseif b2 then
		-- 提示玩家选择要放置到场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 选择一张满足条件的「味美喵」永续魔法·永续陷阱卡。
		local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,tp):GetFirst()
		if tc then
			if tc:IsType(TYPE_CONTINUOUS) then
				-- 将选中的永续魔法卡放置到场上。
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			else
				-- 将选中的场地魔法卡放置到场上。
				Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			end
		end
	end
end
-- 记录同调召唤的连续效果，用于判断是否可以发动②效果。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	if re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsType(TYPE_SYNCHRO) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TEMP_REMOVE,0,1)
	end
end
