--騎士の絆
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡在墓地存在的状态，自己场上有「百夫长骑士」同调怪兽特殊召唤的场合，把这张卡除外，以自己墓地1只「百夫长骑士」怪兽为对象才能发动。那只怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 初始化「骑士的牵绊」的效果：注册①的魔法卡发动效果（从手卡·墓地选百夫长骑士放置到魔陷区）和②的墓地诱发效果（百夫长骑士同调特召时除外自身并用墓地怪兽放置到魔陷区）。
function s.initial_effect(c)
	-- 为此卡注册“已在墓地”的标记检测效果，以确保②效果只在特殊召唤发生前此卡已在墓地时才能发动，防止同一连锁中的重复判定。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：从自己的手卡·墓地把1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上有「百夫长骑士」同调怪兽特殊召唤的场合，把这张卡除外，以自己墓地1只「百夫长骑士」怪兽为对象才能发动。那只怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetLabelObject(e0)
	e2:SetCondition(s.ptcon)
	-- 设置②效果的发动代价：将墓地中的此卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.pttg)
	e2:SetOperation(s.ptop)
	c:RegisterEffect(e2)
end
-- 定义筛选条件：卡为「百夫长骑士」系列怪兽且不是禁止卡，用于从手卡·墓地或墓地中检索可放置的目标。
function s.filter(c)
	return c:IsSetCard(0x1a2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- ①效果的发动条件判定：魔陷区需有足够空位（从手牌发动本卡时需额外1个空位给本卡自身），且手卡·墓地存在至少1只符合条件的「百夫长骑士」怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():IsLocation(LOCATION_HAND) and 1 or 0
	-- 检查我方魔陷区可用空格数是否大于ft（ft为1表示本卡从手牌发动时需多占1格，因此至少需要2格；否则至少1格）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>ft
		-- 同时确认自己手卡·墓地中存在至少1张满足s.filter的「百夫长骑士」怪兽卡，作为①效果处理的候选。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
end
-- ①效果处理：从自己手卡·墓地选择1只符合条件的「百夫长骑士」怪兽，表侧表示放置到自己的魔陷区，并赋予其永续陷阱卡定义；选择时通过王家长眠之谷过滤器排除无法移动的卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认魔陷区有空位，若没有则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 弹出选择提示，告知玩家需要选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从自己手卡·墓地的可选项中（排除受王家长眠之谷影响的卡）选择1只符合条件的「百夫长骑士」怪兽，并取出该卡。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil):GetFirst()
	-- 若选中卡片，则尝试由我方将其移动到自己魔陷区并表侧表示放置，同时立即适用其效果；移动成功才继续附加永续陷阱卡化效果。
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 当作永续陷阱卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 定义②效果的触发过滤条件：特殊召唤成功的怪兽必须是表侧表示、由我方控制的「百夫长骑士」同调怪兽；se参数用于排除本次效果自身导致的特殊召唤干扰。
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsSetCard(0x1a2) and c:IsType(TYPE_SYNCHRO) and c:IsControler(tp)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- ②效果发动条件：当自己场上有表侧表示「百夫长骑士」同调怪兽被特殊召唤成功，且此卡在特殊召唤发生前已经存在于墓地时，满足发动条件。
function s.ptcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,e:GetLabelObject():GetLabelObject())
end
-- ②效果的目标选择与合法性判定：确认魔陷区有空位，并以自己墓地1只符合条件的「百夫长骑士」怪兽作为取对象目标；若已指定目标chkc则校验该目标是否合法。
function s.pttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查我方魔陷区是否有1个以上可用空格，用于容纳将要放置的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且自己墓地存在至少1只符合s.filter的「百夫长骑士」怪兽，可作为②效果的对象。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示，告知玩家需要选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从自己墓地选择1只符合条件的「百夫长骑士」怪兽，设置为该效果的对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理信息：该效果会使对象离开墓地（移动到魔陷区），供相关卡片的连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②效果处理：取得对象卡，若该卡仍与效果关联则将其移动到自己魔陷区表侧表示放置，并附加永续陷阱卡化的效果。
function s.ptop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选取的唯一对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与当前效果关联（未被无效、离场等），并尝试将其移动到自己魔陷区表侧表示放置且适用效果；成功后才继续附加永续陷阱卡化效果。
	if tc:IsRelateToEffect(e) and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 那只怪兽当作永续陷阱卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
