--雷天気ターメル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把自己场上1张表侧表示的永续魔法·永续陷阱卡送去墓地才能发动。从卡组选1张「天气」魔法·陷阱卡在自己的魔法与陷阱区域表侧表示放置。
-- ②：场上的这张卡为让「天气」卡的效果发动而被除外的场合，下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
function c91299846.initial_effect(c)
	-- ①：把自己场上1张表侧表示的永续魔法·永续陷阱卡送去墓地才能发动。从卡组选1张「天气」魔法·陷阱卡在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91299846,0))  --"从卡组放置「天气」魔法·陷阱卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,91299846)
	e1:SetCost(c91299846.tfcost)
	e1:SetTarget(c91299846.tftg)
	e1:SetOperation(c91299846.tfop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为让「天气」卡的效果发动而被除外的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetOperation(c91299846.spreg)
	c:RegisterEffect(e2)
	-- 下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91299846,1))  --"除外的这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCondition(c91299846.spcon)
	e3:SetTarget(c91299846.sptg)
	e3:SetOperation(c91299846.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 过滤作为发动成本送去墓地的自己场上表侧表示的永续魔法·永续陷阱卡
function c91299846.cfilter(c,tp)
	-- 过滤条件：卡片必须表侧表示、是永续卡、能作为Cost送去墓地，且该卡送去墓地后能腾出至少1个魔法与陷阱区域空位
	return c:IsFaceup() and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToGraveAsCost() and Duel.GetSZoneCount(tp,c)>0
		-- 过滤条件：卡组中存在至少1张可以放置到场上的「天气」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c91299846.tffilter,tp,LOCATION_DECK,0,1,nil,c,tp)
end
-- 过滤卡组中可以放置到场上的「天气」魔法·陷阱卡
function c91299846.tffilter(c,cc,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_FIELD) and c:IsSetCard(0x109)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_ONFIELD,cc)
end
-- 效果①的发动成本处理函数
function c91299846.tfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否存在满足条件的永续魔法·永续陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c91299846.cfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张满足条件的表侧表示永续魔法·永续陷阱卡
	local g=Duel.SelectMatchingCard(tp,c91299846.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选择的卡作为发动成本送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的发动条件与目标处理函数
function c91299846.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查魔法与陷阱区域是否有可用空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>-1 end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①的效果处理函数
function c91299846.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果此时魔法与陷阱区域没有空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择1张满足条件的「天气」魔法·陷阱卡
	local tc=Duel.SelectMatchingCard(tp,c91299846.tffilter,tp,LOCATION_DECK,0,1,1,nil,nil,tp):GetFirst()
	if tc then
		-- 将选择的卡在自己的魔法与陷阱区域表侧表示放置
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
-- 用于记录这张卡是否因「天气」卡的效果发动而被除外的辅助效果处理函数
function c91299846.spreg(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsReason(REASON_COST) and rc:IsSetCard(0x109) and c:IsPreviousLocation(LOCATION_ONFIELD) and re:IsActivated() then
		-- 将标签值设置为下个回合的回合数，用于后续判断特殊召唤时点
		e:SetLabel(Duel.GetTurnCount()+1)
		c:RegisterFlagEffect(91299846,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- 效果②的发动条件处理函数
function c91299846.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合数是否为记录的下个回合，且该卡带有对应的标记
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(91299846)>0
end
-- 效果②的发动条件与目标处理函数
function c91299846.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(91299846)
end
-- 效果②的效果处理函数
function c91299846.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将除外的这张卡在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
