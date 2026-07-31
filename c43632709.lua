--Cerynemesia, Mystical Beast of the Forest
local s,id,o=GetID()
-- 此效果为卡片的初始效果设置，包括触发条件、处理方式和特殊召唤类别等
function s.initial_effect(c)
	-- 通常召唤成功时，可以除外自己场上或手牌中的一张 Beast族卡，将一张等级不超过该卡原本等级的Earth属性Beast族怪兽从卡组或墓地特殊召唤到自己场上
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 当己方场上有表侧表示的怪兽存在时，己方玩家必须攻击
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_MUST_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.macon)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e4:SetValue(s.atklimit)
	c:RegisterEffect(e4)
end
-- 此函数用于判断是否可以作为除外的代价，需满足：卡为表侧表示、种族为Beast族、可以除外、场上怪兽区有空位、满足特殊召唤条件
function s.rmfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_BEAST) and c:IsAbleToRemoveAsCost()
		-- 确保该卡在场上的怪兽区有空位可供特殊召唤使用
		and Duel.GetMZoneCount(tp,c)>0 and (not c:IsLocation(LOCATION_MZONE) or aux.covcheck(c))
		-- 确保在卡组或墓地中存在满足条件的怪兽可用于特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c:GetOriginalLevel())
end
-- 此函数用于筛选可特殊召唤的怪兽，需满足：等级不超过指定值、属性为Earth、种族为Beast族、可以被特殊召唤
function s.spfilter(c,e,tp,olv)
	return c:GetOriginalLevel()<=olv and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 此函数为效果的费用处理，检查是否有符合条件的卡可除外，并选择一张进行除外操作，同时设置后续返回机制
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或场上是否存在符合条件的卡作为除外费用
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张符合条件的卡作为除外费用
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将选中的卡以临时除外形式移除
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_TEMPORARY)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetOriginalLevel())
	local fid=c:GetFieldID()
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,2))
	-- 创建一个在回合结束时自动处理除外卡返回的持续效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabelObject(tc)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	-- 注册该持续效果到游戏环境
	Duel.RegisterEffect(e1,tp)
end
-- 此函数为效果的目标设定，用于确定特殊召唤的怪兽数量和来源位置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置操作信息，表示将要特殊召唤一张来自卡组或墓地的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 此函数为效果的处理函数，执行特殊召唤操作并可能触发额外的特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 检查己方场上是否有空位进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组或墓地中选择一张符合条件的怪兽进行特殊召唤
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	-- 若成功特殊召唤，则尝试让对方选择是否再特殊召唤一张手牌中的怪兽
	if sg:GetCount()>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取对方可以特殊召唤的手牌怪兽列表
		local tg=Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,0,LOCATION_HAND,nil,e,0,1-tp,false,false)
		-- 检查对方场上是否有空位进行特殊召唤
		if tg:GetCount()>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			-- 询问对方是否发动额外的特殊召唤效果
			and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
			-- 中断当前连锁处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 提示对方玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local ssg=tg:Select(1-tp,1,1,nil)
			-- 将选中的手牌怪兽特殊召唤到对方场上
			Duel.SpecialSummon(ssg,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
-- 此函数用于判断是否满足除外卡返回条件，通过标记ID进行比对确认
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 此函数用于处理除外卡的返回逻辑，根据其原本位置决定是返回场上还是送回手牌
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsPreviousLocation(LOCATION_MZONE) then
		-- 将卡以原表示形式返回场上
		Duel.ReturnToField(tc)
	else
		-- 将卡送回玩家手牌
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
	end
end
-- 此函数用于判断是否满足必须攻击的条件，即己方场上有表侧表示的怪兽
function s.macon(e)
	-- 检查己方场上是否存在至少一张表侧表示的怪兽
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 此函数用于设定必须攻击的怪兽，即攻击力最高的那张怪兽
function s.atklimit(e,c)
	-- 获取己方场上所有表侧表示怪兽中攻击力最高的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil):GetMaxGroup(Card.GetAttack)
	return g and g:IsContains(c)
end
