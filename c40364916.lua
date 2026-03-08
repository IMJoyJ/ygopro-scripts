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
	-- 使当前卡片在魔法与陷阱区域存在时，卡名视为「不知火流 转生之阵」
	aux.EnableChangeCode(c,40005099)
	-- ②：1回合1次，可以从以下效果选择1个发动。●从自己墓地把1只不死族怪兽除外才能发动。这个回合，自己的不死族怪兽的召唤·特殊召唤不会被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40364916,0))  --"召唤不会被无效化"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCost(c40364916.limcost)
	e3:SetOperation(c40364916.limop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，可以从以下效果选择1个发动。●以自己场上1只不死族怪兽为对象才能发动。那只怪兽除外。那之后，可以从卡组把1只守备力0的不死族怪兽送去墓地。
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
-- 定义costfilter函数：筛选墓地中可以作为cost除外的不死族怪兽
function c40364916.costfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
-- 处理limcost函数逻辑：检查是否存在满足cost条件的卡片，并提示玩家选择要除外的卡，然后执行除外操作
function c40364916.limcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在至少1张满足costfilter条件的卡片（即墓地中有可除外的不死族怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(c40364916.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家tp提示选择要除外的卡片的消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家tp从自己墓地中选择1张满足costfilter条件的卡
	local g=Duel.SelectMatchingCard(tp,c40364916.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡片以表侧表示形式除外，作为发动效果的cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 处理limop函数逻辑：创建一个持续到回合结束阶段的效果，使得该回合玩家的不死族怪兽召唤和特殊召唤不会被无效化
function c40364916.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建并注册两个效果：第一个防止玩家本回合的不死族怪兽召唤被无效化；第二个防止玩家本回合的不死族怪兽特殊召唤被无效化
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	-- 设置e1效果的目标限制为仅针对不死族怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将e1效果注册给玩家tp，使其生效
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	-- 将e2效果注册给玩家tp，使其生效
	Duel.RegisterEffect(e2,tp)
end
-- 定义rmfilter函数：筛选场上正面表示且可以被除外的不死族怪兽
function c40364916.rmfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemove()
end
-- 定义tgfilter函数：筛选卡组中守备力为0且可以送入墓地的不死族怪兽
function c40364916.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsDefense(0) and c:IsAbleToGrave()
end
-- 处理rmtg函数逻辑：检查是否存在满足rmfilter条件的卡片，并提示玩家选择要除外的卡，然后设置操作信息
function c40364916.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40364916.rmfilter(chkc) end
	-- 检查是否存在至少1张满足rmfilter条件的卡片（即场上有可除外的正面表示不死族怪兽）
	if chk==0 then return Duel.IsExistingTarget(c40364916.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家tp提示选择要除外的卡片的消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家tp从自己场上选择1张满足rmfilter条件的卡作为目标
	local g=Duel.SelectTarget(tp,c40364916.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息为CATEGORY_REMOVE类别，影响对象为所选卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 处理rmop函数逻辑：获取已选定的目标怪兽，将其除外，若成功则询问是否从卡组将一只守备力为0的不死族怪兽送入墓地
function c40364916.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的第一个目标卡片（即之前选定要除外的怪兽）
	local tc=Duel.GetFirstTarget()
	-- 获取卡组中所有满足tgfilter条件的卡片集合
	local g=Duel.GetMatchingGroup(c40364916.tgfilter,tp,LOCATION_DECK,0,nil)
	-- 判断目标卡片是否仍然有效并与当前效果相关联，以及能否成功除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0
		-- 判断是否存在可送入墓地的卡片，并询问玩家是否执行送入墓地的操作
		and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(40364916,2)) then  --"是否把怪兽送去墓地？"
		-- 中断当前效果处理流程，确保后续操作不在同一时点处理
		Duel.BreakEffect()
		-- 向玩家tp提示选择要送去墓地的卡片的消息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片以效果原因送入墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
