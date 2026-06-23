--ウィッチクラフト・ハイネ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己场上的其他的魔法师族怪兽不会成为对方的效果的对象。
-- ②：从手卡丢弃1张魔法卡，以对方场上1张表侧表示的卡为对象才能发动。那张卡破坏。这个效果在对方回合也能发动。
function c84523092.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己场上的其他的魔法师族怪兽不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c84523092.tgtg)
	-- 设置不会成为对方卡片效果的对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ②：从手卡丢弃1张魔法卡，以对方场上1张表侧表示的卡为对象才能发动。那张卡破坏。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84523092,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,84523092)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(c84523092.descost)
	e2:SetTarget(c84523092.destg)
	e2:SetOperation(c84523092.desop)
	c:RegisterEffect(e2)
end
-- 过滤自身以外的自己场上的魔法师族怪兽
function c84523092.tgtg(e,c)
	return c~=e:GetHandler() and c:IsRace(RACE_SPELLCASTER)
end
function c84523092.costfilter(c,tp,res)
	if c:IsLocation(LOCATION_HAND) then return c:IsType(TYPE_SPELL) and c:IsDiscardable() end
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsHasEffect(83289866,tp)
		or not c:IsCode(32353566) and c:IsSetCard(0x128)
		and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
		and c:IsLocation(LOCATION_DECK) and res
end
-- 检查并执行从手卡丢弃1张魔法卡（或使用代替效果）作为发动的代价
function c84523092.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local res=Duel.IsPlayerAffectedByEffect(tp,32353566) and e:GetHandler():IsSetCard(0x128)
	if chk==0 then return Duel.IsExistingMatchingCard(c84523092.costfilter,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK,0,1,nil,tp,res) end
	local g=Duel.GetMatchingGroup(c84523092.costfilter,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK,0,nil,tp,res)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc:IsLocation(LOCATION_HAND) then
		local te=tc:IsHasEffect(83289866,tp)
		if te then
			te:UseCountLimit(tp)
			Duel.RegisterFlagEffect(tp,tc:GetCode(),RESET_PHASE+PHASE_END,0,1)
		end
		Duel.SendtoGrave(tc,REASON_COST)
	else
		-- 将选中的卡作为代价丢弃并送去墓地
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- 检查并选择对方场上1张表侧表示的卡作为效果对象，并设置破坏操作信息
function c84523092.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc:IsControler(1-tp) end
	-- 在发动阶段检查对方场上是否存在表侧表示的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送提示信息，要求选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 获取效果对象，若其仍存在于场上，则将其破坏
function c84523092.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
