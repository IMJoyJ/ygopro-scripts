--オッドアイズ・ボルテックス・ドラゴン
-- 效果：
-- 「异色眼」怪兽＋灵摆怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤时，以对方场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽回到手卡。
-- ②：这张卡以外的怪兽的效果·魔法·陷阱卡发动时才能发动。从自己的额外卡组（表侧）让1只灵摆怪兽回到卡组，那个发动无效并破坏。
function c53262004.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足「异色眼」属性和灵摆怪兽类型的怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x99),aux.FilterBoolFunction(Card.IsFusionType,TYPE_PENDULUM),true)
	-- ①：这张卡特殊召唤时，以对方场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,53262004)
	e1:SetTarget(c53262004.thtg)
	e1:SetOperation(c53262004.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡以外的怪兽的效果·魔法·陷阱卡发动时才能发动。从自己的额外卡组（表侧）让1只灵摆怪兽回到卡组，那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,53262005)
	e2:SetCondition(c53262004.discon)
	e2:SetTarget(c53262004.distg)
	e2:SetOperation(c53262004.disop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于判断目标怪兽是否为表侧攻击表示且能送入手牌
function c53262004.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAbleToHand()
end
-- 设置效果目标选择函数，检查是否存在满足条件的对方场上的表侧攻击表示怪兽作为目标
function c53262004.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c53262004.filter(chkc) end
	-- 检查是否存在满足条件的对方场上的表侧攻击表示怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c53262004.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的对方场上的1只表侧攻击表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c53262004.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，指定将目标怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果处理函数，将选定的目标怪兽送入手牌
function c53262004.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 定义连锁无效化条件函数，判断是否满足发动条件
function c53262004.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 判断发动的卡是否为怪兽效果或魔法/陷阱卡且该连锁可被无效
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 定义过滤函数，用于判断额外卡组中的灵摆怪兽是否能返回卡组
function c53262004.disfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToDeck()
end
-- 设置连锁无效化效果的目标选择函数，检查是否存在满足条件的灵摆怪兽
function c53262004.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c53262004.disfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置效果处理信息，指定将1只灵摆怪兽送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_EXTRA)
	-- 设置效果处理信息，指定使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置效果处理信息，指定破坏发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义连锁无效化效果的处理函数，选择并返回灵摆怪兽到卡组，然后使发动无效并破坏
function c53262004.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从额外卡组中选择1只满足条件的灵摆怪兽作为对象
	local g=Duel.SelectMatchingCard(tp,c53262004.disfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 显示所选灵摆怪兽被选为对象的动画效果
	Duel.HintSelection(g)
	-- 将选中的灵摆怪兽送入卡组并洗牌
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 使连锁发动无效，并判断发动的卡是否能被破坏
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 破坏发动的卡
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
