--不知火流 伝承の陣
-- 效果：
-- ①：这张卡只要在魔法与陷阱区域存在，卡名当作「不知火流 转生之阵」使用。
-- ②：1回合1次，可以从以下效果选择1个发动。
-- ●从自己墓地把1只不死族怪兽除外才能发动。这个回合，自己的不死族怪兽的召唤·特殊召唤不会被无效化。
-- ●以自己场上1只不死族怪兽为对象才能发动。那只怪兽除外。那之后，可以从卡组把1只守备力0的不死族怪兽送去墓地。
function c40364916.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 为这张卡注册效果：只要在魔法与陷阱区域存在，卡名当作「不知火流 转生之阵」使用（40005099即该卡卡号）。
	aux.EnableChangeCode(c,40005099)
	-- 效果②中的第一个可选效果：从自己墓地把1只不死族怪兽除外才能发动；这个回合，自己的不死族怪兽的召唤·特殊召唤不会被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40364916,0))  --"召唤不会被无效化"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCost(c40364916.limcost)
	e3:SetOperation(c40364916.limop)
	c:RegisterEffect(e3)
	-- 效果②中的第二个可选效果：以自己场上1只不死族怪兽为对象才能发动；那只怪兽除外。那之后，可以从卡组把1只守备力0的不死族怪兽送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(40364916,1))  --"场上怪兽除外"
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetTarget(c40364916.rmtg)
	e4:SetOperation(c40364916.rmop)
	c:RegisterEffect(e4)
end
-- 定义代价筛选函数：判断怪兽是否是不死族且可作为代价除外，用于从墓地选择要除外的怪兽。
function c40364916.costfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
-- 第一个可选效果的代价函数：支付时从自己墓地选择1只满足costfilter的不死族怪兽，以表侧表示除外作为代价。
function c40364916.limcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足costfilter的不死族怪兽，以决定代价是否可支付。
	if chk==0 then return Duel.IsExistingMatchingCard(c40364916.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只不死族怪兽（满足costfilter）作为代价。
	local g=Duel.SelectMatchingCard(tp,c40364916.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽卡以表侧表示除外，原因记为代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 第一个可选效果的处理函数：给当前玩家场上的全部不死族怪兽附加“召唤/特殊召唤不会被无效化”的持续效果，持续到回合结束。
function c40364916.limop(e,tp,eg,ep,ev,re,r,rp)
	-- ②：1回合1次，可以从以下效果选择1个发动。●从自己墓地把1只不死族怪兽除外才能发动。这个回合，自己的不死族怪兽的召唤·特殊召唤不会被无效化。●以自己场上1只不死族怪兽为对象才能发动。那只怪兽除外。那之后，可以从卡组把1只守备力0的不死族怪兽送去墓地。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	-- 设置该效果的影响对象为不死族怪兽，即只有不死族怪兽能享受“召唤不会被无效化”的加成。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“通常召唤不会被无效化”效果注册到场上影响范围，使其对当前玩家生效。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	-- 将“特殊召唤不会被无效化”效果注册到场上影响范围，与前一效果共同确保不死族怪兽的召唤·特殊召唤不会被无效化。
	Duel.RegisterEffect(e2,tp)
end
-- 定义第二个可选效果取对象的筛选函数：表侧表示、不死族、且可以被除外。
function c40364916.rmfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemove()
end
-- 定义第二个可选效果后续送墓的筛选函数：不死族、守备力0、且可以被送去墓地。
function c40364916.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsDefense(0) and c:IsAbleToGrave()
end
-- 第二个可选效果的发动前目标选择函数：检查并选择自己场上1只表侧不死族怪兽作为对象，同时设置除外相关的操作信息。
function c40364916.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40364916.rmfilter(chkc) end
	-- 检查自己场上是否存在至少1只满足rmfilter（表侧不死族且可除外）的怪兽，以决定能否发动。
	if chk==0 then return Duel.IsExistingTarget(c40364916.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要除外的卡”的提示信息，用于选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上选择1只表侧不死族怪兽作为效果对象，并自动将该对象与当前连锁关联。
	local g=Duel.SelectTarget(tp,c40364916.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本连锁确定要除外的对象为已选择的那只怪兽，数量为1，方便后续检测和处理。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 第二个可选效果的处理函数：先将对象怪兽表侧除外；若对象成功除外且卡组存在满足条件的不死族怪兽，则询问玩家是否从卡组把1只守备力0的不死族怪兽送去墓地。
function c40364916.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回当前连锁中记录的对象卡（即被选为对象的自己场上那只不死族怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 从自己卡组筛选出所有满足tgfilter（不死族且守备力0且可送墓）的怪兽集合。
	local g=Duel.GetMatchingGroup(c40364916.tgfilter,tp,LOCATION_DECK,0,nil)
	-- 判断对象卡仍然与效果关联，并且该怪兽被成功表侧除外，这是后续送墓分支的前提。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0
		-- 判断卡组中存在满足条件的怪兽，并询问玩家是否将怪兽送去墓地。
		and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(40364916,2)) then  --"是否把怪兽送去墓地？"
		-- 中断当前效果链，使后续从卡组送墓的处理视为不同时处理，避免造成错误的时点丢失。
		Duel.BreakEffect()
		-- 向玩家显示“请选择要送去墓地的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将玩家选择的怪兽卡以效果原因（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
