--六世壊根清浄
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上有「俱舍怒威族」超量怪兽存在的场合才能发动。双方直到自身场上的怪兽变成1只为止必须里侧表示除外。
-- ②：这张卡被除外的场合，以自己场上1只「俱舍怒威族」超量怪兽为对象才能发动。那只怪兽作为超量素材中的1只自己的「俱舍怒威族」怪兽加入手卡。那之后，可以把那只怪兽从手卡特殊召唤。
local s,id,o=GetID()
-- 为「六世坏根清净」注册两个效果：①魔法卡发动效果（场上有俱舍怒威族超量怪兽时可发动，双方各自里侧表示除外场上怪兽直到只剩1只），②被除外时触发的回收·特殊召唤效果；两个效果均通过SetCountLimit实现‘这个卡名的①②的效果1回合各能使用1次’。
function s.initial_effect(c)
	-- ①：场上有「俱舍怒威族」超量怪兽存在的场合才能发动。双方直到自身场上的怪兽变成1只为止必须里侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以自己场上1只「俱舍怒威族」超量怪兽为对象才能发动。那只怪兽作为超量素材中的1只自己的「俱舍怒威族」怪兽加入手卡。那之后，可以把那只怪兽从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 定义筛选条件：怪兽须为表侧表示、属于「俱舍怒威族」系列（0x189）、且为超量怪兽，用于判断场上是否存在满足①发动条件的超量怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x189) and c:IsType(TYPE_XYZ)
end
-- ①效果的发动条件：双方场上（主要怪兽区）存在至少1只表侧表示的「俱舍怒威族」超量怪兽。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 从双方场上检索是否存在满足s.cfilter条件的超量怪兽，存在1只即可发动。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ①效果发动时的目标合法性处理：分别获取自己和对方场上的怪兽组，记录‘自己怪兽数>1且自己可除外’和‘对方怪兽数>1且对方可除外’的标记；只要有一方满足条件即可发动，并将双方场上所有怪兽设为效果处理时的涉及卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上的所有怪兽（用于①效果发动时判断自己是否需要除外）。
	local g1=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 获取对方场上的所有怪兽（用于①效果发动时判断对方是否需要除外）。
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 计算b1：自己场上的怪兽数量大于1，且自己允许进行除外操作。
	local b1=#g1>1 and Duel.IsPlayerCanRemove(tp)
		and g1:IsExists(Card.IsAbleToRemove,1,nil,tp,POS_FACEDOWN,REASON_RULE)
	-- 计算b2：对方场上的怪兽数量大于1，且对方允许进行除外操作。
	local b2=#g2>1 and Duel.IsPlayerCanRemove(1-tp)
		and g2:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN,REASON_RULE)
	if chk==0 then return b1 or b2 end
	local g3=g1+g2
	-- 设置操作信息：声明本效果涉及除外，相关目标为双方场上所有怪兽，预计处理数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g3,1,0,0)
end
-- ①效果的实际处理：重新获取双方场上的怪兽，若自己场上怪兽数>1且可除外，则让自己选择保留1只以外的所有怪兽里侧表示除外；对对方也执行同样处理（若对方场上怪兽>1且可除外）。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，获取自己场上的所有怪兽。
	local g1=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 效果处理时，获取对方场上的所有怪兽。
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 效果处理时，重新判断自己场上怪兽数是否大于1且自己可除外。
	local b1=#g1>1 and Duel.IsPlayerCanRemove(tp)
		and g1:IsExists(Card.IsAbleToRemove,1,nil,tp,POS_FACEDOWN,REASON_RULE)
	-- 效果处理时，重新判断对方场上怪兽数是否大于1且对方可除外。
	local b2=#g2>1 and Duel.IsPlayerCanRemove(1-tp)
		and g2:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN,REASON_RULE)
	if b1 then
		local ct=#g1-1
		-- 向当前玩家显示‘请选择要除外的卡’的提示，并进入卡牌选择界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g1:FilterSelect(tp,Card.IsAbleToRemove,ct,ct,nil,tp,POS_FACEDOWN,REASON_RULE)
		-- 将当前玩家选择的一组怪兽以里侧表示除外，除外原因为规则原因（REASON_RULE）。
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE)
	end
	if b2 then
		local ct=#g2-1
		-- 向对方玩家显示‘请选择要除外的卡’的提示，并进入卡牌选择界面。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g2:FilterSelect(1-tp,Card.IsAbleToRemove,ct,ct,nil,1-tp,POS_FACEDOWN,REASON_RULE)
		-- 将对方玩家选择的一组怪兽以里侧表示除外，由对方作为执行方（1-tp），原因为规则原因。
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,1-tp)
	end
end
-- 定义可回收的超量素材条件：必须是「俱舍怒威族」怪兽、能够加入手卡、且持有者为发动玩家自己。
function s.thfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x189)
		and c:IsAbleToHand() and c:GetOwner()==tp
end
-- 定义②效果可选取对象的条件：表侧表示的「俱舍怒威族」超量怪兽，并且其超量素材中存在满足s.thfilter的可回收怪兽。
function s.xfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x189)
		and c:GetOverlayGroup():IsExists(s.thfilter,1,nil,tp)
end
-- ②效果发动时的目标选择处理：验证指定对象是否合法；发动时检查是否存在合法对象；然后让玩家选择1只符合条件的「俱舍怒威族」超量怪兽作为对象，并设置操作信息：预期将1张超量素材加入手牌。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xfilter(chkc,tp) end
	-- 效果发动时检查：自己场上是否存在至少1只可作为对象的「俱舍怒威族」超量怪兽（满足s.xfilter）。
	if chk==0 then return Duel.IsExistingTarget(s.xfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向当前玩家显示‘请选择效果的对象’的提示，进入选择效果对象界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只符合条件的「俱舍怒威族」超量怪兽，并将其登记为效果处理时的对象。
	Duel.SelectTarget(tp,s.xfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：本效果预计会将1张位于超量素材区的卡加入手牌（具体是哪张在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_OVERLAY)
end
-- ②效果的实际处理：取得对象超量怪兽；若对象仍与效果相关且其超量素材中有符合条件可回收的怪兽，则让玩家选择1张加入手牌；加入成功后向对方展示并洗切手牌；随后若玩家选择特殊召唤且场上怪兽区有空位、该卡可特殊召唤，则将其特殊召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果所选对象的超量怪兽（第一步）。
	local tc=Duel.GetFirstTarget()
	local mg=tc:GetOverlayGroup():Filter(s.thfilter,nil,tp)
	if tc:IsRelateToEffect(e) and #mg>0 then
		-- 向当前玩家显示‘请选择要加入手牌的卡’的提示，从超量素材中选择卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local bc=mg:Select(tp,1,1,nil):GetFirst()
		-- 将选中的超量素材送去其持有者的手卡；若实际加入手卡成功（返回值>0）才继续后续处理。
		if Duel.SendtoHand(bc,nil,REASON_EFFECT)>0
			and bc:IsLocation(LOCATION_HAND) then
			-- 将刚刚加入手卡的卡片展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,bc)
			-- 洗切手卡，避免对方得知手卡顺序（由于已展示加入的卡）。
			Duel.ShuffleHand(tp)
			-- 检查自己场上是否有空闲的怪兽区域用于后续特殊召唤。
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and bc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 询问玩家是否选择将那只怪兽从手卡特殊召唤（提示消息为‘是否特殊召唤？’）。
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
				-- 中断当前效果处理，使后续特殊召唤单独作为一个时间点处理，防止错过时点。
				Duel.BreakEffect()
				-- 将选择的怪兽以表侧攻击表示特殊召唤到自己的场上（sumtype为0，检查召唤条件和苏生限制，位置为正面表示）。
				Duel.SpecialSummon(bc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
