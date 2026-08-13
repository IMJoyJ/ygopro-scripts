--M∀LICE＜Q＞HEARTS OF CRYPTER
-- 效果：
-- 包含「码丽丝」怪兽的怪兽3只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，以自己的除外状态的1张「码丽丝」卡为对象才能发动（这张卡所连接区有怪兽存在的场合，这个发动和这个效果不会被无效化）。那张卡回到卡组，场上1张卡除外。
-- ②：这张卡被除外的场合，支付900基本分才能发动。这张卡的攻击力变成2倍特殊召唤。
local s,id,o=GetID()
-- 注册这张卡的连接召唤手续（3只包含「码丽丝」怪兽的怪兽）以及①回卡组除外的二速效果、根据连接区有无怪兽动态调整①效果抗性的持续效果、②被除外时支付900LP特召并攻击力翻倍的诱发效果；①②效果各自1回合1次。
function s.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要3只怪兽作为素材，且素材组中至少包含1只「码丽丝」怪兽（s.lcheck）。
	aux.AddLinkProcedure(c,nil,3,3,s.lcheck)
	c:EnableReviveLimit()
	-- ①：自己·对方回合，以自己的除外状态的1张「码丽丝」卡为对象才能发动（这张卡所连接区有怪兽存在的场合，这个发动和这个效果不会被无效化）。那张卡回到卡组，场上1张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收并除外"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- （这张卡所连接区有怪兽存在的场合，这个发动和这个效果不会被无效化）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(0xff)
	e2:SetLabelObject(e1)
	e2:SetOperation(s.adjustop)
	c:RegisterEffect(e2)
	-- ②：这张卡被除外的场合，支付900基本分才能发动。这张卡的攻击力变成2倍特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 连接素材检查函数：素材组中是否存在至少1只卡名含有「码丽丝」的怪兽（0x1bf），是则允许作为连接素材。
function s.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1bf)
end
-- 调整用持续效果的操作：若这张卡的连接区存在怪兽，则给①效果附加不可无效、不可使其发动无效化等抗性（对应“这个发动和这个效果不会被无效化”）；否则仅保留取对象标志。
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	local lg=e1:GetHandler():GetLinkedGroup()
	if lg and lg:FilterCount(Card.IsType,nil,TYPE_MONSTER)>0 then
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CAN_FORBIDDEN)
	else
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	end
end
-- 对象筛选函数：用于选择除外状态表侧表示的「码丽丝」卡，且该卡可以返回卡组。
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1bf) and c:IsAbleToDeck()
end
-- ①效果的发动条件与取对象判定：确认选择的对象合法，且场上存在可除外的卡、除外区存在可返回卡组的「码丽丝」卡。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查场上是否存在至少1张可以被除外的卡，以满足“场上1张卡除外”的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 检查除外区是否存在至少1张满足条件的「码丽丝」卡，以确保有对象可取。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 给玩家显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对象：从自己除外区选择1张满足条件的「码丽丝」卡，并设为①效果的对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：将选中的对象卡返回卡组，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 获取场上所有可以除外的卡，作为后续“场上1张卡除外”的候选集合。
	local dg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：除外场上的卡，目标为候选集合dg，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,1,0,0)
	local lg=e:GetHandler():GetLinkedGroup()
end
-- ①效果处理：对象卡返回卡组洗切成功时，从场上选择1张卡除外。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡与效果仍有关联，并且已成功返回卡组（位于卡组或额外卡组），才继续处理除外。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 给玩家显示“请选择要除外的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从场上所有可除外的卡中选择1张卡。
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil):Select(tp,1,1,nil)
		if #g>0 then
			-- 显示选中动画，并将该卡记为被选为对象（用于卡片联动等）。
			Duel.HintSelection(g)
			-- 将选中的卡表侧表示除外。
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- ②效果发动代价：检查并支付900基本分。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查能否支付900基本分。
	if chk==0 then return Duel.CheckLPCost(tp,900) end
	-- 支付900基本分。
	Duel.PayLPCost(tp,900)
end
-- ②效果发动条件：自己主要怪兽区有空位，且这张卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将这张卡特殊召唤（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：将这张卡特殊召唤，若成功则使其攻击力变成当前攻击力的2倍。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡仍与效果关联，并使用SpecialSummonStep进行特殊召唤；返回真时继续赋予攻击力翻倍效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这张卡的攻击力变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤处理，结束一组SpecialSummonStep特殊召唤流程。
	Duel.SpecialSummonComplete()
end
