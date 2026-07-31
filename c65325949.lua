--蠱神の色鬼 クズハ
local s,id,o=GetID()
-- 初始化卡片效果：注册①自身手牌特召手续、②场上卡片破坏、③结束阶段墓地陷阱盖放效果
function s.initial_effect(c)
	-- ①：手牌特召手续：把自己场上1张里侧表示的卡回到手牌，此卡从手牌特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：主要阶段效果：以最多为场上里侧表示卡数量一半的卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ③：结束阶段效果：自己结束阶段，以自己墓地1张「蛇神」陷阱卡为对象才能发动。那张卡在自己场地盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 特召Cost过滤条件：里侧表示且能返回手牌/额外卡组，且空出的位置满足特召需求
function s.spcfilter(c,tp)
	return c:IsFacedown() and (c:IsAbleToHandAsCost() or c:IsAbleToExtraAsCost())
		-- 检查将该卡弹回手牌后，怪兽区域是否有可用于特殊召唤的空位
		and Duel.GetMZoneCount(tp,c)>0
end
-- ①特召手续发动条件：自己场上存在符合条件的里侧表示卡片
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在可弹回手牌的里侧表示卡
	return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
end
-- ①特召手续Cost选择：选择1张里侧表示卡弹回手牌
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足特召Cost条件的里侧表示卡
	local g=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- ①特召手续Cost执行：向对方确认选中的卡并将其返回手牌
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 向对方玩家确认选择的里侧卡片
	Duel.ConfirmCards(1-tp,g)
	-- 将选中的卡片作为特召Cost返回手牌
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- ②效果发动准备：计算破坏数量上限，选择场上的卡作为对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算场上里侧表示卡片的总数量
	local ct=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local st=math.floor(ct/2)
	if chkc then return chkc:IsOnField() end
	-- 发动条件检查：场上里侧表示卡不少于2张，且存在可选择的破坏对象
	if chk==0 then return st>0 and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1到上限数量的场上卡片作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,st,nil)
	-- 设置连锁操作信息：破坏选中的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果处理：破坏选中的对象卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取依然存在于场上的对象卡
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if g:GetCount()>0 then
		-- 破坏选中的目标卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- ③效果触发条件：当前回合玩家为自己
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 墓地盖放过滤条件：「蛇神」陷阱卡且能在场地盖放
function s.setfilter(c)
	return c:IsSetCard(0x1e4) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ③效果发动准备：选择自己墓地1张「蛇神」陷阱卡作为对象
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	-- 发动条件检查：自己墓地是否存在可盖放的「蛇神」陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择自己墓地1张满足条件的「蛇神」陷阱卡作为对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息：1张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ③效果处理：将选中的墓地陷阱卡在自己场地盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对象卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍然与连锁有效关联且不受王谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将选中的陷阱卡在自己场地盖放
		Duel.SSet(tp,tc)
	end
end
