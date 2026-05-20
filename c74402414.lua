--マジック・クロニクル
-- 效果：
-- ①：把手卡全部送去墓地才能把这张卡发动。从卡组把5张魔法·陷阱卡除外。
-- ②：每次对方把魔法卡发动，给这张卡放置1个年代记指示物。
-- ③：把这张卡2个年代记指示物取除才能发动。对方从这张卡的效果除外的卡之中选1张。自己把那张卡加入手卡。
-- ④：魔法与陷阱区域的表侧表示的这张卡从场上离开时，自己受到这张卡的效果除外中的卡数量×500伤害。
function c74402414.initial_effect(c)
	c:EnableCounterPermit(0x25)
	local g=Group.CreateGroup()
	g:KeepAlive()
	-- ①：把手卡全部送去墓地才能把这张卡发动。从卡组把5张魔法·陷阱卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c74402414.cost)
	e1:SetTarget(c74402414.target)
	e1:SetOperation(c74402414.activate)
	e1:SetLabelObject(g)
	c:RegisterEffect(e1)
	-- ②：每次对方把魔法卡发动，给这张卡放置1个年代记指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_SZONE)
	-- 注册连锁发生时该卡在场上存在的状态，用于后续判定是否放置指示物
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- ②：每次对方把魔法卡发动，给这张卡放置1个年代记指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c74402414.ctop)
	c:RegisterEffect(e2)
	-- ③：把这张卡2个年代记指示物取除才能发动。对方从这张卡的效果除外的卡之中选1张。自己把那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74402414,0))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c74402414.thcost)
	e3:SetTarget(c74402414.thtg)
	e3:SetOperation(c74402414.thop)
	e3:SetLabelObject(g)
	c:RegisterEffect(e3)
	-- ④：魔法与陷阱区域的表侧表示的这张卡从场上离开时，自己受到这张卡的效果除外中的卡数量×500伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(c74402414.checkop)
	e4:SetLabelObject(g)
	c:RegisterEffect(e4)
	-- ④：魔法与陷阱区域的表侧表示的这张卡从场上离开时，自己受到这张卡的效果除外中的卡数量×500伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetOperation(c74402414.damop)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- ①号效果的发动代价：检查并把手卡全部送去墓地
function c74402414.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己除这张卡以外的所有手卡
	local hg=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,e:GetHandler())
	if chk==0 then return hg:GetCount()>0 and hg:FilterCount(Card.IsAbleToGraveAsCost,nil)==hg:GetCount() end
	-- 将所有手卡作为发动代价送去墓地
	Duel.SendtoGrave(hg,REASON_COST)
end
-- 过滤卡组中可以被除外的魔法·陷阱卡
function c74402414.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- ①号效果的发动准备：检查卡组中是否存在至少5张魔法·陷阱卡，并设置除外操作信息
function c74402414.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少5张可以除外的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c74402414.filter,tp,LOCATION_DECK,0,5,nil) end
	-- 设置效果处理时的操作信息为“从卡组除外5张卡”
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,5,tp,LOCATION_DECK)
end
-- ①号效果的处理：从卡组选择5张魔法·陷阱卡除外，并为这些卡注册标记且存入卡片组
function c74402414.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c74402414.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()<5 then return end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:Select(tp,5,5,nil)
	-- 将选中的5张卡表侧表示除外
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	local tc=rg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(74402414,RESET_EVENT+RESETS_STANDARD,0,0)
		tc=rg:GetNext()
	end
	e:GetLabelObject():Clear()
	e:GetLabelObject():Merge(rg)
end
-- ②号效果的处理：对方发动魔法卡且连锁处理完毕时，给这张卡放置1个年代记指示物
function c74402414.ctop(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x25,1)
	end
end
-- ③号效果的发动代价：取除这张卡2个年代记指示物
function c74402414.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x25,2,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x25,2,REASON_COST)
end
-- 过滤因这张卡的效果除外且可以加入手卡的卡
function c74402414.thfilter(c)
	return c:GetFlagEffect(74402414)~=0 and c:IsAbleToHand()
end
-- ③号效果的发动准备：由对方从因该效果除外的卡中选择1张，并将其设为效果处理的对象
function c74402414.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabelObject():IsContains(chkc) and c74402414.thfilter(chkc) end
	if chk==0 then return e:GetLabelObject():IsExists(c74402414.thfilter,1,nil) end
	-- 提示对方玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local g=e:GetLabelObject():FilterSelect(1-tp,c74402414.thfilter,1,1,nil)
	e:GetLabelObject():Sub(g)
	-- 将对方选中的卡设为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置效果处理时的操作信息为“将1张除外的卡加入手卡”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
-- ③号效果的处理：将对方选中的那张卡加入自己手卡，并给对方确认
function c74402414.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方选中的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 过滤仍带有该卡标记的除外卡片
function c74402414.dfilter(c)
	return c:GetFlagEffect(74402414)~=0
end
-- ④号效果的离场前检测：若此卡未被无效且处于适用状态，记录当前因该效果除外的卡片数量
function c74402414.checkop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():FilterCount(c74402414.dfilter,nil)
	local c=e:GetHandler()
	if c:IsDisabled() or not c:IsStatus(STATUS_EFFECT_ENABLED) or ct==0 then
		e:SetLabel(0)
	else e:SetLabel(ct) end
end
-- ④号效果的离场伤害处理：根据离场前记录的卡片数量，给自己造成对应数值的伤害
function c74402414.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabelObject():GetLabel()
	if ct>0 and c:IsPreviousControler(tp) then
		-- 给予自己“除外的卡数量×500”数值的伤害
		Duel.Damage(tp,ct*500,REASON_EFFECT)
	end
end
