--壱世壊に奏でる哀唱
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」存在的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效。那之后，选自己场上1只怪兽送去墓地。
-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把1只「珠泪哀歌族」怪兽加入手卡。
function c74920585.initial_effect(c)
	-- 记录卡片记载了「维萨斯-斯塔弗罗斯特」的事实。
	aux.AddCodeList(c,56099748)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」存在的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效。那之后，选自己场上1只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74920585,0))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,74920585)
	e2:SetCondition(c74920585.condition)
	e2:SetTarget(c74920585.target)
	e2:SetOperation(c74920585.activate)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把1只「珠泪哀歌族」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,74920586)
	e3:SetCondition(c74920585.thcon)
	e3:SetTarget(c74920585.thtg)
	e3:SetOperation(c74920585.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「珠泪哀歌族」怪兽或「维萨斯-斯塔弗罗斯特」。
function c74920585.actcfilter(c)
	return ((c:IsSetCard(0x181) and c:IsLocation(LOCATION_MZONE)) or c:IsCode(56099748)) and c:IsFaceup()
end
-- 效果①的发动条件函数。
function c74920585.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足条件的怪兽。
	return Duel.IsExistingMatchingCard(c74920585.actcfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①的发动准备与目标选择函数。
function c74920585.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查作为对象的目标是否仍是对方场上可无效的效果怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查对方场上是否存在至少1只可无效的效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
		-- 并且自己场上存在至少1只可以送去墓地的怪兽。
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只可无效的效果怪兽作为对象。
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为：将自己场上的1只怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
-- 效果①的处理函数。
function c74920585.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为对象的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与目标怪兽相关的连锁都无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 立即刷新场上卡片的无效状态。
		Duel.AdjustInstantly()
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 玩家选择自己场上1只怪兽。
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,1,nil)
		if #g>0 then
			-- 中断当前效果，使之后的操作不与前面的操作同时处理。
			Duel.BreakEffect()
			-- 将选中的怪兽送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 效果②的发动条件：这张卡被效果送去墓地。
function c74920585.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤条件：卡组中的「珠泪哀歌族」怪兽。
function c74920585.thfilter(c)
	return c:IsSetCard(0x181) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备与目标检查函数。
function c74920585.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可加入手牌的「珠泪哀歌族」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c74920585.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理函数。
function c74920585.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只「珠泪哀歌族」怪兽。
	local g=Duel.SelectMatchingCard(tp,c74920585.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
