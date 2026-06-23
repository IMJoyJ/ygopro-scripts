--魔救の奇跡－レオナイト
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1张「魔救」卡加入手卡。剩下的卡用喜欢的顺序回到卡组最下面。
-- ②：对方回合，自己墓地有炎属性怪兽存在的场合，以自己墓地1只岩石族怪兽为对象才能发动。那只怪兽特殊召唤。
function c47674738.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1张「魔救」卡加入手卡。剩下的卡用喜欢的顺序回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47674738,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,47674738)
	e1:SetTarget(c47674738.thtg)
	e1:SetOperation(c47674738.thop)
	c:RegisterEffect(e1)
	-- ②：对方回合，自己墓地有炎属性怪兽存在的场合，以自己墓地1只岩石族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47674738,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,47674739)
	e2:SetCondition(c47674738.spcon)
	e2:SetTarget(c47674738.sptg)
	e2:SetOperation(c47674738.spop)
	c:RegisterEffect(e2)
end
-- 判断是否满足效果发动条件，即玩家卡组中至少有5张卡
function c47674738.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若玩家卡组中少于5张卡则不满足发动条件
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 定义过滤函数，用于筛选「魔救」卡且能加入手牌的卡片
function c47674738.thfilter(c)
	return c:IsSetCard(0x140) and c:IsAbleToHand()
end
-- 处理效果的主要操作流程，包括翻开卡组顶部5张卡、选择是否将「魔救」卡加入手牌、排序并放回卡组底部
function c47674738.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 若玩家卡组中少于5张卡则不满足发动条件
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=4 then return end
	-- 确认玩家卡组最上方的5张卡
	Duel.ConfirmDecktop(tp,5)
	-- 获取玩家卡组最上方的5张卡组成的Group
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:GetCount()
	-- 判断是否有「魔救」卡且玩家选择将卡加入手牌
	if ct>0 and g:FilterCount(c47674738.thfilter,nil)>0 and Duel.SelectYesNo(tp,aux.Stringid(47674738,2)) then  --"是否选卡加入手卡？"
		-- 禁用后续操作的洗切卡组检测
		Duel.DisableShuffleCheck()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:FilterSelect(tp,c47674738.thfilter,1,1,nil)
		-- 将选中的卡加入玩家手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认玩家所选的卡
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切玩家手牌
		Duel.ShuffleHand(tp)
		ct=g:GetCount()-sg:GetCount()
	end
	if ct>0 then
		-- 对玩家卡组最上方的剩余卡进行排序
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 获取玩家卡组最上方的1张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到玩家卡组底部
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- 定义效果发动条件，判断是否为对方回合且己方墓地有炎属性怪兽
function c47674738.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前回合玩家不是自己且己方墓地存在炎属性怪兽则满足发动条件
	return Duel.GetTurnPlayer()==1-tp and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_FIRE)
end
-- 定义过滤函数，用于筛选岩石族且能特殊召唤的怪兽
function c47674738.spfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标选择流程，包括判断是否满足特殊召唤条件和选择目标怪兽
function c47674738.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47674738.spfilter(chkc,e,tp) end
	-- 判断是否满足特殊召唤条件，即己方墓地存在符合条件的岩石族怪兽且场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c47674738.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c47674738.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，确定将要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果发动后的操作流程，包括判断目标是否有效并进行特殊召唤
function c47674738.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以指定方式将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
