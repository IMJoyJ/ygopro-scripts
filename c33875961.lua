--ダーク・カタパルター
-- 效果：
-- 自己的准备阶段时这张卡守备表示的场合，这张卡放置1个指示物。可以从自己墓地除外和指示物同数量的卡，破坏场上和除外的卡片数同数量的魔法·陷阱卡。之后这张卡的指示物全部取除。
function c33875961.initial_effect(c)
	c:EnableCounterPermit(0x28)
	-- 诱发效果：自己的准备阶段时这张卡守备表示的场合，这张卡放置1个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33875961,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c33875961.addccon)
	e1:SetTarget(c33875961.addct)
	e1:SetOperation(c33875961.addc)
	c:RegisterEffect(e1)
	-- 起动效果：可以从自己墓地除外和指示物同数量的卡，破坏场上和除外的卡片数同数量的魔法·陷阱卡。之后这张卡的指示物全部取除。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33875961,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(c33875961.descost)
	e2:SetTarget(c33875961.destg)
	e2:SetOperation(c33875961.desop)
	c:RegisterEffect(e2)
end
-- 条件函数：判断是否为自己的准备阶段且此卡为守备表示。
function c33875961.addccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的准备阶段且此卡为守备表示。
	return Duel.GetTurnPlayer()==tp and e:GetHandler():IsDefensePos()
end
-- 设置效果处理信息：准备放置1个指示物。
function c33875961.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：准备放置1个指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x28)
end
-- 效果处理：若此卡有效则放置1个指示物。
function c33875961.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x28,1)
	end
end
-- 效果处理：支付代价，从墓地除外与指示物数量相同的卡。
function c33875961.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetCounter(0x28)
	-- 判断是否满足支付代价条件：指示物数量大于0且墓地存在与指示物数量相同的可除外卡。
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,ct,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择与指示物数量相同的卡从墓地除外。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,ct,ct,nil)
	-- 将选中的卡除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数：判断卡片是否为魔法或陷阱类型。
function c33875961.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果处理信息：选择场上与指示物数量相同的魔法或陷阱卡进行破坏。
function c33875961.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c33875961.filter(chkc) end
	local ct=e:GetHandler():GetCounter(0x28)
	-- 判断是否满足破坏效果的发动条件：场上存在与指示物数量相同的魔法或陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c33875961.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择与指示物数量相同的场上魔法或陷阱卡。
	local g=Duel.SelectTarget(tp,c33875961.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置效果处理信息：准备破坏选中的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- 效果处理：破坏选中的卡并取除所有指示物。
function c33875961.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g:FilterCount(Card.IsRelateToEffect,nil,e)==g:GetCount() then
		-- 破坏目标卡组中的卡。
		Duel.Destroy(g,REASON_EFFECT)
	end
	local ct=e:GetHandler():GetCounter(0x28)
	e:GetHandler():RemoveCounter(tp,0x28,ct,REASON_EFFECT)
end
