--賢者ケイローン
-- 效果：
-- 从手卡丢弃1张魔法卡。对方场上的1张魔法·陷阱卡破坏。这个效果1回合只能使用1次。
function c16956455.initial_effect(c)
	-- 从手卡丢弃1张魔法卡。对方场上的1张魔法·陷阱卡破坏。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16956455,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c16956455.descost)
	e1:SetTarget(c16956455.destg)
	e1:SetOperation(c16956455.desop)
	c:RegisterEffect(e1)
end
-- 定义代价筛选函数：只有魔法卡且满足可丢弃条件（通常指能被送去墓地）的手卡才能作为丢弃代价。
function c16956455.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 代价函数：先检查是否存在可丢弃的魔法卡，若存在则从手牌选择1张符合条件的魔法卡以代价+丢弃为原因送去墓地。
function c16956455.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查阶段：确认手牌中是否存在至少1张满足条件的魔法卡可以作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c16956455.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行代价：从手牌选择1张符合条件的魔法卡丢弃（作为发动成本）。
	Duel.DiscardHand(tp,c16956455.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义对象筛选函数：选择对方场上的魔法·陷阱卡（任一魔法或陷阱卡）。
function c16956455.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 目标选择函数：确认存在可破坏的对方魔法·陷阱卡，让玩家选择1张作为对象，并设置破坏的操作信息。
function c16956455.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c16956455.filter(chkc) end
	-- 发动前检查阶段：确认对方场上存在至少1张可作为对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c16956455.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家发出选择提示，提示文本为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张魔法·陷阱卡作为效果对象，同时将其设置为当前连锁的对象（与效果建立联系）。
	local g=Duel.SelectTarget(tp,c16956455.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 将当前连锁的处理信息设为“破坏”类别，记录要破坏的对象为g、数量为1，供其他效果进行连锁判断。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数：取得效果处理时对象，若对象仍与效果存在联系（未被离场等重置），则将其破坏。
function c16956455.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的目标卡（此效果只选1张，故为唯一对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡破坏（送去墓地）。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
