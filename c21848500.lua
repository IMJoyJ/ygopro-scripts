--M∀LICE＜Q＞HEARTS OF CRYPTER
-- 效果：
-- 包含「码丽丝」怪兽的怪兽3只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，以自己的除外状态的1张「码丽丝」卡为对象才能发动（这张卡所连接区有怪兽存在的场合，这个发动和这个效果不会被无效化）。那张卡回到卡组，场上1张卡除外。
-- ②：这张卡被除外的场合，支付900基本分才能发动。这张卡的攻击力变成2倍特殊召唤。
local s,id,o=GetID()
-- 初始化效果，设置连接召唤手续、启用特殊召唤限制，并注册三个效果
function s.initial_effect(c)
	-- 设置连接召唤需要3个满足条件的怪兽作为素材
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
	-- 当调整阶段时，若此卡连接区有怪兽，则使效果1不会被无效化
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
-- 连接召唤的过滤条件：连接区怪兽必须包含码丽丝卡组
function s.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1bf)
end
-- 调整阶段时，若此卡连接区有怪兽，则使效果1不会被无效化
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	local lg=e1:GetHandler():GetLinkedGroup()
	if lg and lg:FilterCount(Card.IsType,nil,TYPE_MONSTER)>0 then
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CAN_FORBIDDEN)
	else
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	end
end
-- 过滤函数：返回场上正面表示的码丽丝卡且能送入卡组
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1bf) and c:IsAbleToDeck()
end
-- 效果①的发动条件判断：场上存在可除外的卡，且自己除外区存在码丽丝卡
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 判断场上是否存在可除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 判断自己除外区是否存在码丽丝卡
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择要送回卡组的码丽丝卡
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果①的送回卡组操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 获取场上可除外的卡组
	local dg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置效果①的除外操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,1,0,0)
	local lg=e:GetHandler():GetLinkedGroup()
end
-- 效果①的处理流程：将选中的码丽丝卡送回卡组，再从场上除外一张卡
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且已送回卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择场上一张可除外的卡
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil):Select(tp,1,1,nil)
		if #g>0 then
			-- 显示选中卡作为除外对象的动画
			Duel.HintSelection(g)
			-- 将选中的卡除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 效果②的发动费用：支付900基本分
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能支付900基本分
	if chk==0 then return Duel.CheckLPCost(tp,900) end
	-- 支付900基本分
	Duel.PayLPCost(tp,900)
end
-- 效果②的发动条件判断：场上存在特殊召唤空间且此卡可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果②的特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的处理流程：支付费用后特殊召唤此卡并使其攻击力翻倍
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否有效且特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 设置此卡攻击力翻倍的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
