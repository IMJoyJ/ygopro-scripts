--DDD双暁王カリ・ユガ
-- 效果：
-- 8星「DD」怪兽×2
-- ①：这张卡超量召唤成功的回合，这张卡以外的场上的卡的效果不能发动并无效化。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。场上的魔法·陷阱卡全部破坏。这个效果在对方回合也能发动。
-- ③：把这张卡1个超量素材取除，以自己墓地1张「契约书」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
function c15939229.initial_effect(c)
	-- 为这张卡添加超量召唤手续：以2只等级8且卡名含有「DD」（0xaf）的怪兽作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xaf),8,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功的回合，这张卡以外的场上的卡的效果不能发动并无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c15939229.sumsuc)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。场上的魔法·陷阱卡全部破坏。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15939229,0))  --"场上的魔法·陷阱卡全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCost(c15939229.cost)
	e2:SetTarget(c15939229.destg)
	e2:SetOperation(c15939229.desop)
	c:RegisterEffect(e2)
	-- ③：把这张卡1个超量素材取除，以自己墓地1张「契约书」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15939229,1))  --"盖放魔法·陷阱"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c15939229.cost)
	e3:SetTarget(c15939229.settg)
	e3:SetOperation(c15939229.setop)
	c:RegisterEffect(e3)
end
-- 超量召唤成功时的处理：仅当以超量召唤方式特殊召唤成功时，给己方注册压制效果——禁止双方发动场上其他卡的效果、无效场上其他卡的效果，并在连锁处理时无效场上其他卡已发动的效果；同时给这张卡附加标志用于区分“这张卡以外”的卡，所有效果持续到结束阶段。
function c15939229.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsSummonType(SUMMON_TYPE_XYZ) then return end
	-- ①：这张卡以外的场上的卡的效果不能发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(c15939229.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(c:GetFieldID())
	-- 将禁止效果发动的效果注册给当前玩家，使双方在该回合内不能发动这张卡以外的场上卡的效果。
	Duel.RegisterEffect(e1,tp)
	-- 并无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetTarget(c15939229.disable)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetLabel(c:GetFieldID())
	-- 将场上卡片效果无效化的效果注册到全场，使场上这张卡以外的魔法·陷阱卡和效果怪兽的效果无效，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
	-- ①：这张卡超量召唤成功的回合，这张卡以外的场上的卡的效果不能发动并无效化；②：1回合1次，把这张卡1个超量素材取除才能发动。场上的魔法·陷阱卡全部破坏。这个效果在对方回合也能发动；③：把这张卡1个超量素材取除，以自己墓地1张「契约书」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetCondition(c15939229.discon)
	e3:SetOperation(c15939229.disop)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetLabel(c:GetFieldID())
	-- 将连锁无效效果注册到场上，使得在连锁处理时，若场上其他卡发动效果，则将该效果无效。
	Duel.RegisterEffect(e3,tp)
	c:RegisterFlagEffect(15939229,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,c:GetFieldID())
end
-- 判定效果来源是否为“这张卡以外的场上卡”：效果持有者在场上，且不是本卡（通过卡上标志与效果标签比较）时返回true，表示应禁止该效果的发动。
function c15939229.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return rc:IsOnField() and rc:GetFlagEffectLabel(15939229)~=e:GetLabel()
end
-- 判定需要被无效化的卡：不是本卡，且是魔法·陷阱卡或效果怪兽（原本类型包含效果怪兽）时返回true，使这些卡的效果被无效。
function c15939229.disable(e,c)
	return c:GetFlagEffectLabel(15939229)~=e:GetLabel() and (not c:IsType(TYPE_MONSTER) or (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT))
end
-- 判定连锁中的效果是否属于“这张卡以外的场上卡的效果”：效果来源卡在场上且不是本卡时返回true，作为连锁处理时发动无效的条件。
function c15939229.discon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 获取触发连锁的效果发生的位置（场上/手卡/墓地等），用于后续判断是否为场上发动的效果。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return bit.band(loc,LOCATION_ONFIELD)~=0 and rc:GetFlagEffectLabel(15939229)~=e:GetLabel()
end
-- 将当前满足条件的连锁效果无效，使该效果不处理。
function c15939229.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 直接使连锁序号为ev的那个效果无效化。
	Duel.NegateEffect(ev)
end
-- ②③共用的代价：检查这张卡是否有1个超量素材可作为代价，若有则取除1个素材。
function c15939229.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②的破坏对象筛选条件：场上的魔法·陷阱卡（不包括怪兽卡）。
function c15939229.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ②的发动条件和目标设定：检查场上是否存在魔法·陷阱卡；若存在，则获取场上全部魔法·陷阱卡并登记为将被破坏的对象信息。
function c15939229.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：场上存在至少1张魔法·陷阱卡才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c15939229.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有魔法·陷阱卡，作为本次破坏效果将要影响的卡组。
	local g=Duel.GetMatchingGroup(c15939229.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 登记操作信息：本次效果将破坏上述魔法·陷阱卡，破坏数量为获取到的卡片总数，供相关连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②的效果处理：效果处理时重新获取场上所有魔法·陷阱卡，并将其全部破坏。
function c15939229.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取场上所有魔法·陷阱卡（因为处理时场上情况可能已变化）。
	local g=Duel.GetMatchingGroup(c15939229.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 以效果原因将这些魔法·陷阱卡全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- ③的对象筛选条件：自己墓地的「契约书」魔法·陷阱卡，且可以进行盖放（Set）才能选择。
function c15939229.setfilter(c)
	return c:IsSetCard(0xae) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ③的发动条件与取对象：检查自己魔法·陷阱区是否有空位，且墓地存在符合条件的「契约书」卡；若条件满足，则提示玩家选择其中1张作为对象。
function c15939229.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c15939229.setfilter(chkc) end
	-- 发动合法性检查：自己魔法与陷阱区域存在空位，否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且墓地存在至少1张符合条件的「契约书」卡可供选择为对象，才能发动。
		and Duel.IsExistingTarget(c15939229.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出提示，让玩家选择要盖放的卡（提示文字为“请选择要盖放的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家从自己墓地选择1张符合条件的「契约书」卡作为对象，并记录为效果对象。
	local g=Duel.SelectTarget(tp,c15939229.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：该对象卡将离开墓地（被盖放到场上），数量为1，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ③的效果处理：取得对象卡，若对象卡仍与效果相关联，则将其盖放到自己场上。
function c15939229.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这个效果选择的对象卡（第一个目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡在自己的魔法·陷阱区域盖放。
		Duel.SSet(tp,tc)
	end
end
