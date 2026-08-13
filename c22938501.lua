--再世の導神 シェモース
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：场上有原本攻击力或原本守备力是2500的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：对方把卡的效果发动时，从自己的手卡·场上（表侧表示）把这张卡以外的1张「再世」卡送去墓地才能发动。那个发动无效并破坏。
-- ③：这张卡被送去墓地的对方回合的结束阶段才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册四个效果：①手卡特殊召唤规则效果（场上存在原本攻/守2500的怪兽时），②对方发动卡的效果时以再世卡为代价无效并破坏的即时诱发效果，③去墓地后的对方结束阶段回收自身的效果，以及为③服务的送墓标记效果。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：场上有原本攻击力或原本守备力是2500的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②③的效果1回合各能使用1次。②：对方把卡的效果发动时，从自己的手卡·场上（表侧表示）把这张卡以外的1张「再世」卡送去墓地才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	-- 这张卡被送去墓地
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的对方回合的结束阶段才能发动。这张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"回收"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.thcon2)
	e4:SetTarget(s.thtg2)
	e4:SetOperation(s.thop2)
	c:RegisterEffect(e4)
end
-- 判定是否场上存在表侧表示且原本攻击力或原本守备力为2500的怪兽。
function s.cfilter(c)
	return (c:GetBaseAttack()==2500 or c:GetBaseDefense()==2500) and c:IsFaceup()
end
-- ①特殊召唤的规则条件：存在可用的主要怪兽区，且场上有满足s.cfilter的怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者场上是否有空余的主要怪兽区可特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查双方场上是否存在原本攻击力或原本守备力为2500的表侧表示怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ②的发动条件：对方发动卡的效果，且该连锁可以被无效。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动了效果，且该效果的发动处于可被无效的状态。
	return ep==1-tp and Duel.IsChainNegatable(ev)
end
-- 筛选可作为代价的卡：是「再世」卡、表侧表示（或手卡场合允许）且可作为代价送去墓地。
function s.costfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1c5) and c:IsAbleToGraveAsCost()
end
-- ②的代价：从手卡·场上表侧表示选择这张卡以外的1张「再世」卡送去墓地。
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查是否存在符合条件的「再世」卡可作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张符合条件的「再世」卡（排除自身）作为代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 将所选的卡送去墓地作为发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②的目标/操作信息设置：必定无效对方发动，并尽可能将对方发动的卡作为破坏对象。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果包含无效这次发动。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若对方发动的卡可被破坏且仍与效果关联，则设置操作信息：同时破坏该卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果处理：无效对方发动成功后，将那张卡破坏。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认发动无效处理成功且对方那张卡仍与效果关联（未离场）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对方发动的那张卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 这张卡被送去墓地时，给自己登记一个直到结束阶段重置的标记，用于③的发动条件。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ③的发动条件：当前为对方回合的结束阶段，且这张卡本回合被送去墓地过。
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 是对方回合，并且这张卡带有送墓标记（本回合被送去墓地过）。
	return Duel.GetTurnPlayer()==1-tp and e:GetHandler():GetFlagEffect(id)>0
end
-- ③的目标检查：这张卡可以加入手卡，并设置回收自身的操作信息。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将这张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ③效果处理：这张卡仍与效果关联且不受墓地向手卡移动限制时，将其加入手卡并向对方确认。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡仍未离开过相关区域（与效果保持关联），且不受王家长眠之谷等不能从墓地加入手卡的效果影响。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将这张卡加入其持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的这张卡。
		Duel.ConfirmCards(1-tp,c)
	end
end
