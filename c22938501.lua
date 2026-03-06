--再世の導神 シェモース
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：场上有原本攻击力或原本守备力是2500的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：对方把卡的效果发动时，从自己的手卡·场上（表侧表示）把这张卡以外的1张「再世」卡送去墓地才能发动。那个发动无效并破坏。
-- ③：这张卡被送去墓地的对方回合的结束阶段才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，创建三个效果分别为特殊召唤、无效对方效果和墓地回收效果
function s.initial_effect(c)
	-- ①：场上有原本攻击力或原本守备力是2500的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：对方把卡的效果发动时，从自己的手卡·场上（表侧表示）把这张卡以外的1张「再世」卡送去墓地才能发动。那个发动无效并破坏。
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
	-- ③：这张卡被送去墓地的对方回合的结束阶段才能发动。这张卡加入手卡。
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
-- 用于过滤场上是否存在原本攻击力或原本守备力为2500的表侧表示怪兽
function s.cfilter(c)
	return (c:GetBaseAttack()==2500 or c:GetBaseDefense()==2500) and c:IsFaceup()
end
-- 判断是否满足特殊召唤条件，即场上有2500攻击力或守备力的怪兽且有空场
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查是否有足够的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查场上是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 判断是否为对方发动效果且该效果可被无效
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方发动效果且该效果可被无效
	return ep==1-tp and Duel.IsChainNegatable(ev)
end
-- 用于过滤手卡或场上的「再世」卡
function s.costfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1c5) and c:IsAbleToGraveAsCost()
end
-- 设置无效对方效果的费用，需要支付一张「再世」卡到墓地
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「再世」卡可支付费用
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一张满足条件的「再世」卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置无效对方效果的目标信息，包括无效和破坏
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行无效对方效果的操作，包括无效发动和破坏目标
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效发动并确认目标卡是否可破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 当卡片被送去墓地时，记录标记以触发回收效果
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否满足回收效果的发动条件，即在对方回合且标记存在
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否在对方回合且标记存在
	return Duel.GetTurnPlayer()==1-tp and e:GetHandler():GetFlagEffect(id)>0
end
-- 设置回收效果的目标信息，即将自身送回手牌
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行回收效果，将自身送回手牌并确认
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足回收效果的执行条件，即卡片与效果相关且未被王家长眠之谷影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将卡片送回手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方确认送回手牌的卡片
		Duel.ConfirmCards(1-tp,c)
	end
end
