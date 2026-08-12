--曇天気スレット
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在自己场上存在，这张卡以外的自己场上的表侧表示的「天气」卡被送去墓地的场合，以自己墓地最多2张「天气」魔法·陷阱卡为对象才能发动。那些卡在自己的魔法与陷阱区域表侧表示放置。
-- ②：场上的这张卡为让「天气」卡的效果发动而被除外的场合，下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
function c28806532.initial_effect(c)
	-- ①：这张卡在自己场上存在，这张卡以外的自己场上的表侧表示的「天气」卡被送去墓地的场合，以自己墓地最多2张「天气」魔法·陷阱卡为对象才能发动。那些卡在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28806532,0))  --"从墓地放置「天气」魔法·陷阱卡"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,28806532)
	e1:SetCondition(c28806532.tfcon)
	e1:SetTarget(c28806532.tftg)
	e1:SetOperation(c28806532.tfop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为让「天气」卡的效果发动而被除外的场合，下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetOperation(c28806532.spreg)
	c:RegisterEffect(e2)
	-- 从墓地放置「天气」魔法·陷阱卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28806532,1))  --"除外的这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c28806532.spcon)
	e3:SetTarget(c28806532.sptg)
	e3:SetOperation(c28806532.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 判断被送去墓地的卡是否为表侧表示的「天气」卡且在自己场上
function c28806532.tfcfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x109) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 判断是否有满足条件的「天气」卡被送去墓地
function c28806532.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28806532.tfcfilter,1,e:GetHandler(),tp)
end
-- 判断墓地中的卡是否为「天气」魔法·陷阱卡且未被禁止
function c28806532.tffilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_FIELD) and c:IsSetCard(0x109)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 设置选择目标的条件为墓地中的「天气」魔法·陷阱卡
function c28806532.tftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28806532.tffilter(chkc,tp) end
	-- 判断场上是否有足够的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断墓地中是否存在满足条件的「天气」魔法·陷阱卡
		and Duel.IsExistingTarget(c28806532.tffilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 向对方提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 计算可放置的「天气」魔法·陷阱卡数量
	local ct=math.min((Duel.GetLocationCount(tp,LOCATION_SZONE)),2)
	-- 提示选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择要放置到场上的「天气」魔法·陷阱卡
	local g=Duel.SelectTarget(tp,c28806532.tffilter,tp,LOCATION_GRAVE,0,1,ct,nil,tp)
	-- 设置操作信息为将卡从墓地移除
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,g:GetCount(),0,0)
end
-- 处理效果的执行，将选中的卡移至魔法与陷阱区域
function c28806532.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()<=0 then return end
	-- 计算可放置的「天气」魔法·陷阱卡数量
	local ct=math.min(2,(Duel.GetLocationCount(tp,LOCATION_SZONE)))
	if ct<1 then return end
	if g:GetCount()>ct then
		-- 提示选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		g=g:Select(tp,1,ct,nil)
	end
	-- 遍历选中的卡组并进行处理
	for tc in aux.Next(g) do
		-- 将卡移至魔法与陷阱区域
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
-- 记录该卡因「天气」卡效果被除外的回合数
function c28806532.spreg(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsReason(REASON_COST) and rc:IsSetCard(0x109) and c:IsPreviousLocation(LOCATION_ONFIELD) and re:IsActivated() then
		-- 设置标记为下个回合
		e:SetLabel(Duel.GetTurnCount()+1)
		c:RegisterFlagEffect(28806532,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- 判断是否为下个回合且该卡被除外
function c28806532.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为下个回合且该卡被除外
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(28806532)>0
end
-- 设置特殊召唤的条件
function c28806532.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(28806532)
end
-- 处理特殊召唤效果
function c28806532.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
