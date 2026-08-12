--クリストロン・クラスター
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的「水晶机巧」卡不能用对方的效果除外。
-- ②：以场上1张表侧表示卡为对象才能发动（自己场上有「水晶机巧」同调怪兽存在的场合，这个效果的对象可以变成2张）。「水晶机巧晶簇」以外的自己的墓地·除外状态的1张「水晶机巧」卡回到卡组，作为对象的卡破坏。
local s,id,o=GetID()
-- 注册场地魔法卡的发动与效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上的「水晶机巧」卡不能用对方的效果除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.rmlimit)
	c:RegisterEffect(e2)
	-- 以场上1张表侧表示卡为对象才能发动（自己场上有「水晶机巧」同调怪兽存在的场合，这个效果的对象可以变成2张）。「水晶机巧晶簇」以外的自己的墓地·除外状态的1张「水晶机巧」卡回到卡组，作为对象的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"破坏"
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 限制对方将自己场上的「水晶机巧」卡除外的效果
function s.rmlimit(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0xea) and c:IsFaceup()
		and r&REASON_EFFECT~=0 and r&REASON_REDIRECT==0 and rp==1-tp
end
-- 过滤场上存在的「水晶机巧」同调怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xea) and c:IsType(TYPE_SYNCHRO)
end
-- 过滤墓地或除外状态的「水晶机巧」卡
function s.tdfilter(c)
	return not c:IsCode(id) and c:IsFaceupEx() and c:IsSetCard(0xea) and c:IsAbleToDeck()
end
-- 设置效果发动时的选择目标
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	local xg=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then xg=e:GetHandler() end
	local ct=1
	-- 若自己场上存在「水晶机巧」同调怪兽，则可选择2张场上的卡作为对象
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then ct=2 end
	-- 检查是否有满足条件的场上表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,xg)
		-- 检查是否有满足条件的墓地或除外状态的「水晶机巧」卡
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上表侧表示卡作为破坏对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,xg)
	-- 设置连锁操作信息：破坏对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置连锁操作信息：将卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 处理效果的发动与执行
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的墓地或除外状态的「水晶机巧」卡
	local dg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if dg:GetCount()>0 then
		-- 显示所选卡作为对象的动画效果
		Duel.HintSelection(dg)
		-- 将选中的卡送回卡组
		if Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
			and dg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)>0
			and tg:GetCount()>0 then
			-- 破坏已选择的场上卡
			Duel.Destroy(tg,REASON_EFFECT)
		end
	end
end
