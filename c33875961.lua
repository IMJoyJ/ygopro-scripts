--ダーク・カタパルター
-- 效果：
-- 自己的准备阶段时这张卡守备表示的场合，这张卡放置1个指示物。可以从自己墓地除外和指示物同数量的卡，破坏场上和除外的卡片数同数量的魔法·陷阱卡。之后这张卡的指示物全部取除。
function c33875961.initial_effect(c)
	c:EnableCounterPermit(0x28)
	-- 自己的准备阶段时这张卡守备表示的场合，这张卡放置1个指示物。
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
	-- 可以从自己墓地除外和指示物同数量的卡，破坏场上和除外的卡片数同数量的魔法·陷阱卡。之后这张卡的指示物全部取除。
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
-- 判定当前回合玩家是否为自己且此卡是否处于守备表示，作为准备阶段放置指示物效果的发动条件。
function c33875961.addccon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真当且仅当当前回合玩家是自己且此卡处于守备表示。
	return Duel.GetTurnPlayer()==tp and e:GetHandler():IsDefensePos()
end
-- 放置指示物效果的发动时点合法性检测：发动时始终允许，并设置本次操作信息为放置1个指示物。
function c33875961.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，宣告本效果将给此卡放置1个0x28类型的指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x28)
end
-- 效果处理时，若此卡仍与效果关联，则给它放置1个0x28类型的指示物。
function c33875961.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x28,1)
	end
end
-- 破坏效果的代价函数：从自己墓地选择和此卡指示物数量相同的卡表侧除外作为发动代价。
function c33875961.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetCounter(0x28)
	-- 代价检测：指示物数量大于0，且墓地存在至少ct张可以除外的卡时才满足支付条件。
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,ct,nil) end
	-- 弹出选择提示，让玩家从墓地选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择ct张可除外的卡作为代价。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,ct,ct,nil)
	-- 将选中的卡以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数：判定卡片是否为魔法·陷阱卡（用于选择破坏对象）。
function c33875961.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的目标指定函数：选择场上与指示物数量相同的魔法·陷阱卡作为效果对象。
function c33875961.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c33875961.filter(chkc) end
	local ct=e:GetHandler():GetCounter(0x28)
	-- 目标检测：场上存在至少ct张魔法·陷阱卡可以选择为对象时才可发动。
	if chk==0 then return Duel.IsExistingTarget(c33875961.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,nil) end
	-- 弹出选择提示，让玩家选择要破坏的魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择ct张场上的魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c33875961.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置操作信息，宣告将破坏这些对象卡，数量为ct。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- 效果处理时，获取连锁对象；若对象卡仍与效果关联则全部破坏，之后取除此卡全部指示物。
function c33875961.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被指定为对象的卡组（即选择要破坏的魔法·陷阱卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g:FilterCount(Card.IsRelateToEffect,nil,e)==g:GetCount() then
		-- 将这些对象卡以效果破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
	local ct=e:GetHandler():GetCounter(0x28)
	e:GetHandler():RemoveCounter(tp,0x28,ct,REASON_EFFECT)
end
