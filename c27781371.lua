--天地再世
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把1只「再世」怪兽送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ②：对方回合，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。自己的手卡·墓地·除外状态的「再世」怪兽尽可能特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽在结束阶段送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果，注册永续魔陷发动效果和两个二速效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：从卡组把1只「再世」怪兽送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.poscost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	-- ②：对方回合，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。自己的手卡·墓地·除外状态的「再世」怪兽尽可能特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽在结束阶段送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查卡组中是否存在1只「再世」怪兽且为怪兽卡且可作为cost送去墓地
function s.costfilter(c)
	return c:IsSetCard(0x1c5) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果处理：检索满足条件的「再世」怪兽并将其送去墓地作为cost
function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足cost条件：卡组中是否存在至少1张满足costfilter的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足costfilter的1张卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送去墓地作为cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数，检查对方场上是否存在1只表侧表示且可变为里侧表示的怪兽
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果处理：选择对方场上1只表侧表示的怪兽并将其变为里侧守备表示
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	-- 检查是否满足效果发动条件：对方场上是否存在至少1只表侧表示且可变为里侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要变为里侧守备表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的怪兽
	local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息：将目标怪兽变为里侧守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理：将目标怪兽变为里侧守备表示
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 判断是否满足效果发动条件：当前回合为对方回合
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果处理：将此卡送去墓地作为cost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 将此卡送去墓地作为cost
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤函数，检查手卡·墓地·除外状态中是否存在1只「再世」怪兽且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1c5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：检查是否满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤条件：场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足特殊召唤条件：手卡·墓地·除外状态中是否存在至少1只「再世」怪兽且可特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置效果操作信息：特殊召唤1只「再世」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果处理：特殊召唤满足条件的「再世」怪兽，并在结束阶段将其送去墓地
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「再世」怪兽组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	-- 计算可特殊召唤的怪兽数量
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),g:GetClassCount(Card.GetCode))
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「再世」怪兽组
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,ft,ft)
	if sg then
		local fid=e:GetHandler():GetFieldID()
		-- 遍历选中的怪兽组
		for tc in aux.Next(sg) do
			-- 特殊召唤当前怪兽
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		end
		sg:KeepAlive()
		-- 注册结束阶段处理效果，用于将特殊召唤的怪兽送去墓地
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(sg)
		e1:SetCondition(s.tgcon)
		e1:SetOperation(s.tgop)
		-- 注册结束阶段处理效果
		Duel.RegisterEffect(e1,tp)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 过滤函数，检查怪兽是否为本次特殊召唤的怪兽
function s.tcfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 判断结束阶段处理条件：特殊召唤的怪兽是否仍存在
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local fid=e:GetLabel()
	if not g or g:FilterCount(s.tcfilter,nil,fid)==0 then
		if g then g:DeleteGroup() end
		e:Reset()
		return false
	else return true end
end
-- 结束阶段处理：将特殊召唤的怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local g=e:GetLabelObject()
	local sg=g:Filter(s.tcfilter,nil,fid)
	-- 将特殊召唤的怪兽送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
