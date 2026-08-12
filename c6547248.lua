--道化の一座『新加入』
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己·对方的准备阶段才能发动。自己的墓地·除外状态的3张「道化一座」卡回到卡组。那之后，自己抽1张。
-- ②：自己把怪兽上级召唤的场合，以最多有为那次上级召唤而解放的怪兽数量的场上的其他的魔法·陷阱卡为对象才能发动。那些卡破坏。
-- ③：这张卡从场上以外送去墓地的场合才能发动。这张卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果：①准备阶段回收抽卡；②上级召唤时破坏魔陷；③从场外送墓时在场上放置。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的准备阶段才能发动。自己的墓地·除外状态的3张「道化一座」卡回到卡组。那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"回收并抽卡"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	-- 为单张卡片注册一个合并的延迟事件监听器，用于监听怪兽召唤成功的事件。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SUMMON_SUCCESS)
	-- ②：自己把怪兽上级召唤的场合，以最多有为那次上级召唤而解放的怪兽数量的场上的其他的魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(custom_code)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- ③：这张卡从场上以外送去墓地的场合才能发动。这张卡在自己场上表侧表示放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"放置"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.stcon)
	e4:SetTarget(s.sttg)
	e4:SetOperation(s.stop)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上以外（墓地或除外状态）的「道化一座」卡片，且可以回到卡组。
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1dc) and c:IsAbleToDeck()
end
-- ①效果的发动准备，检查墓地·除外状态是否存在至少3张「道化一座」卡，且自身可以抽卡。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的墓地或除外状态是否存在至少3张满足条件的「道化一座」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
		-- 并且检查当前玩家是否可以抽卡。
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁信息：预计将自己墓地或除外状态的3张卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	-- 设置连锁信息：预计让玩家抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果的执行函数，将选中的3张「道化一座」卡送回卡组，并抽1张卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地及除外状态中所有不受「王家之谷」影响且满足条件的「道化一座」卡片。
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if sg:GetCount()<3 then return end
	-- 给玩家发送提示信息，要求选择要送回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local g=sg:Select(tp,3,3,nil)
	if g:GetCount()>0 then
		-- 手动为选中的卡片组显示被选中的动画效果。
		Duel.HintSelection(g)
		-- 尝试通过效果将选中的卡片送回卡组并洗牌，并检查是否有卡片成功回到卡组或额外卡组。
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
			and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
			-- 中断当前效果处理，使后续的抽卡处理与回卡组处理不视为同时进行（防止错时点）。
			Duel.BreakEffect()
			-- 玩家因效果抽1张卡。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 过滤条件：由当前玩家进行上级召唤成功的怪兽。
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- ②效果的发动条件：当前玩家成功上级召唤了怪兽。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤条件：魔法或陷阱卡。
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ②效果的发动准备，计算上级召唤所解放的怪兽数量，并选择对应数量的场上其他魔陷卡作为对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local sg=eg:Filter(s.cfilter,nil,tp)
	local ct=0
	-- 遍历所有本次上级召唤成功的怪兽。
	for tc in aux.Next(sg) do
		local mt=tc:GetMaterial():FilterCount(Card.IsType,nil,TYPE_MONSTER)
		if mt>ct then ct=mt end
	end
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) and e:GetHandler()~=chkc end
	-- 检查是否存在至少1张场上的其他魔法·陷阱卡可以作为破坏对象。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 给玩家发送提示信息，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择最多等同于解放怪兽数量的场上其他魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,e:GetHandler())
	-- 设置连锁信息：预计破坏选中的卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果的执行函数，破坏所有成为对象且仍存在于场上的卡片。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中成为对象且依然存在于场上的卡片。
	local sg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	-- 因效果破坏这些卡片。
	Duel.Destroy(sg,REASON_EFFECT)
end
-- ③效果的发动条件：这张卡不是从场上送去墓地的（即从场上以外送去墓地）。
function s.stcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ③效果的发动准备，检查魔法·陷阱区是否有空位，且该卡未被禁止使用、在场上唯一存在。
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查当前玩家的魔法与陷阱区域是否有空余位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and not c:IsForbidden() and c:CheckUniqueOnField(tp) end
	-- 设置连锁信息：预计将墓地的这张卡移出墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ③效果的执行函数，将墓地的这张卡在自己的魔法与陷阱区域表侧表示放置。
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与连锁相关，且不受「王家之谷」的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡在自己的魔法与陷阱区域表侧表示放置，并适用其效果。
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
