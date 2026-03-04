--マシュマオ☆ヤミー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有兽族·光属性怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己墓地把1张「味美喵」魔法·陷阱卡加入手卡。同调怪兽的效果特殊召唤的场合，也能作为代替把自己的卡组·除外状态的1张「味美喵」场地魔法卡或「味美喵」永续魔法·永续陷阱卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合或者只有兽族·光属性怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
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
	e2:SetDescription(aux.Stringid(id,1))
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
	-- 同调怪兽的效果特殊召唤的场合，也能作为代替把自己的卡组·除外状态的1张「味美喵」场地魔法卡或「味美喵」永续魔法·永续陷阱卡在自己场上表侧表示放置。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(s.checkop)
	c:RegisterEffect(e4)
end
-- 过滤场上的怪兽，判断是否为非光属性或非兽族怪兽
function s.cfilter(c)
	return c:IsFacedown() or not (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST))
end
-- 判断是否满足①效果的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上没有非光属性或非兽族怪兽，则满足条件
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置①效果的发动目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行①效果的处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤墓地中的味美喵魔法陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x1ca) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 过滤卡组或除外状态中的味美喵场地/永续魔法陷阱卡
function s.pfilter(c,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1ca)
		-- 判断是否有足够的场地魔法区域
		and (c:IsType(TYPE_CONTINUOUS) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		or c:IsType(TYPE_FIELD))
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 设置②效果的发动目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在味美喵魔法陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查卡组或除外状态中是否存在味美喵场地/永续魔法陷阱卡
		or Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,tp)
		and e:GetHandler():GetFlagEffect(id)>0 end
	if e:GetHandler():GetFlagEffect(id)>0 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	-- 设置回手操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 执行②效果的处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查墓地中是否存在满足条件的味美喵魔法陷阱卡
	local b1=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
	-- 检查卡组或除外状态中是否存在满足条件的味美喵场地/永续魔法陷阱卡
	local b2=e:GetLabel()==1 and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,tp)
	-- 根据选择决定使用哪种效果
	if b1 and (not b2 or not Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
		-- 提示玩家选择从墓地回手或从卡组/除外状态放置
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		-- 选择墓地中的味美喵魔法陷阱卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡送入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认送入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	elseif b2 then
		-- 提示玩家选择从卡组/除外状态放置
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		-- 选择卡组或除外状态中的味美喵场地/永续魔法陷阱卡
		local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,tp):GetFirst()
		if tc then
			if tc:IsType(TYPE_CONTINUOUS) then
				-- 将选中的永续魔法卡放置到场上
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			else
				-- 将选中的场地魔法卡放置到场上
				Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			end
		end
	end
end
-- 检查是否为同调怪兽特殊召唤
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	if re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsType(TYPE_SYNCHRO) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TEMP_REMOVE,0,1)
	end
end
