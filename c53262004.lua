--オッドアイズ・ボルテックス・ドラゴン
-- 效果：
-- 「异色眼」怪兽＋灵摆怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤时，以对方场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽回到手卡。
-- ②：这张卡以外的怪兽的效果·魔法·陷阱卡发动时才能发动。从自己的额外卡组（表侧）让1只灵摆怪兽回到卡组，那个发动无效并破坏。
function c53262004.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，素材为1只「异色眼」怪兽与1只灵摆怪兽。
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
-- 定义①效果可选对象的筛选条件：对方场上表侧攻击表示且能够被加入手卡的怪兽。
function c53262004.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAbleToHand()
end
-- ①效果的发动处理：特殊召唤成功时，选择对方场上1只表侧攻击表示怪兽为对象，并设置将该对象返回手牌的操作信息。
function c53262004.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c53262004.filter(chkc) end
	-- 检查是否存在满足条件的对方场上表侧攻击表示怪兽作为取对象目标。
	if chk==0 then return Duel.IsExistingTarget(c53262004.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家显示“请选择要返回手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上1只表侧攻击表示怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c53262004.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：将1张对象卡返回持有者手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：取得对象卡，若对象仍与效果关联，则将其返回持有者手牌。
function c53262004.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因返回其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件：本卡以外的怪兽效果或魔法·陷阱卡发动时，且本卡没有被战斗破坏确定，才能发动。
function c53262004.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 进一步确认该发动是怪兽效果或魔法·陷阱卡的发动，且该连锁可以被无效化。
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 定义②效果中从额外卡组返回卡组的卡的筛选条件：表侧表示的灵摆怪兽且能够返回卡组。
function c53262004.disfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToDeck()
end
-- ②效果的发动判定与操作信息设置：确认额外卡组存在符合条件的表侧灵摆怪兽，并设置回卡组、无效、破坏的操作信息。
function c53262004.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的额外卡组是否存在至少1张表侧表示的灵摆怪兽且能返回卡组。
	if chk==0 then return Duel.IsExistingMatchingCard(c53262004.disfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：预计从自己的额外卡组将1张卡返回卡组（不指定具体卡）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：将当前连锁中的那个发动无效化。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若被无效的发动卡能够被破坏且仍与连锁关联，则设置操作信息：将其破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果处理：选择1张额外卡组表侧灵摆怪兽返回卡组，若成功则无效对方的发动，并破坏那张卡。
function c53262004.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己的额外卡组选择1张表侧表示的灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c53262004.disfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 展示选中的卡并记录其为当前效果的对象，播放选中动画。
	Duel.HintSelection(g)
	-- 将选中的卡返回卡组并洗切；若实际返回数量不为0，才继续无效并破坏处理。
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 若该连锁发动被成功无效，且被无效的那张卡仍与效果关联，则继续执行破坏。
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 以效果原因破坏被无效发动的卡片。
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
