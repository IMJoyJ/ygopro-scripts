--戦華の智－諸葛孔
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡用「战华」卡的效果从卡组加入手卡的场合才能发动。这张卡特殊召唤。
-- ②：魔法·陷阱卡发动时，把自己场上1张表侧表示的「战华」永续魔法·永续陷阱卡送去墓地才能发动。那个发动无效。
-- ③：自己场上有「战华之德-刘玄」存在，怪兽的效果发动时，把自己场上1张表侧表示的「战华」永续魔法·永续陷阱卡送去墓地才能发动。那个发动无效。
function c32422602.initial_effect(c)
	-- ①：这张卡用「战华」卡的效果从卡组加入手卡的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32422602,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,32422602)
	e1:SetCondition(c32422602.spcon)
	e1:SetTarget(c32422602.sptg)
	e1:SetOperation(c32422602.spop)
	c:RegisterEffect(e1)
	-- ②：魔法·陷阱卡发动时，把自己场上1张表侧表示的「战华」永续魔法·永续陷阱卡送去墓地才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32422602,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,32422603)
	e2:SetCondition(c32422602.negcon1)
	e2:SetCost(c32422602.negcost)
	e2:SetTarget(c32422602.negtg)
	e2:SetOperation(c32422602.negop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(32422602,2))
	e3:SetCountLimit(1,32422604)
	e3:SetCondition(c32422602.negcon2)
	c:RegisterEffect(e3)
end
-- ①效果发动条件：这张卡是通过「战华」卡的效果从卡组加入手卡，即触发原因为效果、效果来源卡具有「战华」字段、此卡加入手卡前位于卡组且原来的控制者为发动效果者。
function c32422602.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT)~=0 and re:GetHandler():IsSetCard(0x137)
		and c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp)
end
-- ①效果发动时点检查：自己主要怪兽区有空位，且这张卡能够被特殊召唤（满足特殊召唤手续与苏生限制）。
function c32422602.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将特殊召唤这张卡，目标为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果保持关联，就将其以表侧表示特殊召唤到自己场上。
function c32422602.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以不检查召唤条件、不检查苏生限制的方式，将这张卡以表侧表示特殊召唤到发动者/控制者的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果发动条件：正在发动的连锁是魔法·陷阱卡的发动，该连锁的发动可被无效，且此卡没有被战斗破坏确定。
function c32422602.negcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动中的效果是否为魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），且当前连锁可被无效；同时自身不处于战斗破坏确定状态。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 过滤器：表侧表示且卡号为40428851，即「战华之德-刘玄」。
function c32422602.cfilter(c)
	return c:IsFaceup() and c:IsCode(40428851)
end
-- ③效果发动条件：发动中的效果是怪兽效果且该连锁可被无效，自身不处于战斗破坏确定状态，并且自己场上有表侧表示的「战华之德-刘玄」存在。
function c32422602.negcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动中的效果是否为怪兽效果，且当前连锁可被无效；同时自身不处于战斗破坏确定状态。
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 并且自己场上存在至少1张「战华之德-刘玄」作为发动③效果的前提条件。
		and Duel.IsExistingMatchingCard(c32422602.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 代价过滤器：选择自己场上表侧表示、拥有「战华」字段、属于永续魔法或永续陷阱卡、且可以作为代价送去墓地的卡。
function c32422602.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToGraveAsCost()
end
-- ②③共用的代价处理：从自己场上选择1张符合条件的表侧表示「战华」永续魔法·永续陷阱卡，作为代价送去墓地。
function c32422602.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己场上是否存在至少1张可支付代价的符合条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c32422602.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 弹出选择提示，要求玩家选择1张要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1张满足代价条件的表侧表示「战华」永续魔法·永续陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c32422602.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡以代价原因（REASON_COST）送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②③共用的目标判定：本效果不取对象，直接指定要无效的连锁，因此发动时直接允许，并把当前连锁的触发源登记为将被无效的对象。
function c32422602.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果为无效发动，目标为触发当前连锁的卡（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果处理：无效当前连锁对应效果的发动。
function c32422602.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 对指定的连锁（ev）执行发动无效。
	Duel.NegateActivation(ev)
end
