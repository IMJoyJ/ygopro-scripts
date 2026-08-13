--蠱神の色鬼 クズハ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：这张卡可以把自己场上1张里侧表示卡给对方观看并回到手卡·额外卡组，从手卡特殊召唤。
-- ②：以场上的里侧表示卡每2张最多1张的场上的卡为对象才能发动。那些卡破坏。
-- ③：自己结束阶段，以自己墓地1张「艮神鬼」陷阱卡为对象才能发动。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化这张卡的三个效果：①手卡的特殊召唤规则（不可复制的效果外文本，1回合1次誓约次数限制），②场上的起动破坏效果（取对象，1回合1次），③结束阶段触发的墓地陷阱盖放效果（取对象，1回合1次）
function s.initial_effect(c)
	-- ①：这张卡可以把自己场上1张里侧表示卡给对方观看并回到手卡·额外卡组，从手卡特殊召唤。
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
	-- ②：以场上的里侧表示卡每2张最多1张的场上的卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段，以自己墓地1张「艮神鬼」陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"盖放"
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
-- 过滤函数：可以作为特殊召唤代价的里侧表示卡——需为里侧表示、能回到手卡或额外卡组，且其离场后自己场上仍有可用怪兽区
function s.spcfilter(c,tp)
	return c:IsFacedown() and (c:IsAbleToHandAsCost() or c:IsAbleToExtraAsCost())
		-- 并且该卡离场后自己场上可用的怪兽区数量大于0（保证特殊召唤有格子）
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤条件的判定：在自己场上存在至少1张满足代价过滤条件的里侧表示卡时才能特殊召唤
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1张满足代价条件的里侧表示卡
	return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
end
-- 特殊召唤的对象选择：从自己场上满足代价条件的里侧表示卡中选1张，记录为后续处理用的标签对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己场上所有满足代价条件的里侧表示卡的卡组
	local g=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	-- 向玩家提示「请选择要回到手卡的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤的处理：将选中的里侧表示卡给对方观看，然后使其回到手卡或额外卡组
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的里侧表示卡给对方玩家确认（观看）
	Duel.ConfirmCards(1-tp,g)
	-- 把该卡作为特殊召唤手续送回持有者的手卡（额外怪兽则回到额外卡组）
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 破坏效果的对象选择：计算场上里侧表示卡的数量，以每2张最多1张为上限选择场上的卡为对象，并设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 统计双方场上里侧表示卡的总数
	local ct=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local st=math.floor(ct/2)
	if chkc then return chkc:IsOnField() end
	-- 发动条件检查：可破坏张数（里侧表示卡数除以2向下取整）大于0，且场上存在至少1张可作为对象的卡
	if chk==0 then return st>0 and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示「请选择要破坏的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 以场上任意卡为对象，选择1张至最多st张（里侧表示卡每2张最多1张）作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,st,nil)
	-- 设置本次连锁的操作信息为破坏，目标为选中的那些卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理：取得仍与连锁相关且在场上的对象卡，将它们破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象中仍在场上的卡
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if g:GetCount()>0 then
		-- 以效果原因破坏那些对象卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 盖放效果的发动条件：仅在当前回合玩家是自己的结束阶段才能发动
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己（即自己的结束阶段）
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数：自己墓地中可以盖放的「艮神鬼」陷阱卡（系列号0x1e4）
function s.setfilter(c)
	return c:IsSetCard(0x1e4) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 盖放效果的对象选择：以自己墓地1张「艮神鬼」陷阱卡为对象，并设置离开墓地的操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	-- 发动条件检查：自己墓地存在至少1张可作为对象的「艮神鬼」陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示「请选择要盖放的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地选择1张「艮神鬼」陷阱卡作为对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁的操作信息为离开墓地，目标为选中的那张卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 盖放效果的处理：取得对象卡，确认其仍与连锁相关且不受王家长眠之谷影响后，在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	-- 确认该卡仍与连锁相关，并且不受王家长眠之谷的影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 把那张「艮神鬼」陷阱卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
