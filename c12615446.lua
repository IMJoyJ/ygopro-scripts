--電子光虫－スカラジエータ
-- 效果：
-- 昆虫族·光属性3星怪兽×2只以上
-- ①：1回合1次，把这张卡2个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽的表示形式变更，那个效果直到回合结束时无效。这个效果在对方回合也能发动。
-- ②：1回合1次，这张卡战斗破坏对方怪兽送去墓地时才能发动。破坏的那只怪兽在这张卡下面重叠作为超量素材。
function c12615446.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：可用2只以上（最多99只）的昆虫族·光属性3星怪兽作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,c12615446.matfilter,3,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡2个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽的表示形式变更，那个效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12615446,0))  --"效果无效"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DISABLE)
	e1:SetCountLimit(1)
	e1:SetCost(c12615446.poscost)
	e1:SetTarget(c12615446.postg)
	e1:SetOperation(c12615446.posop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡战斗破坏对方怪兽送去墓地时才能发动。破坏的那只怪兽在这张卡下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12615446,1))  --"增加素材"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1)
	e2:SetCondition(c12615446.xyzcon)
	e2:SetTarget(c12615446.xyztg)
	e2:SetOperation(c12615446.xyzop)
	c:RegisterEffect(e2)
end
-- 素材过滤函数：判断作为XYZ素材的怪兽是否满足昆虫族且光属性的要求。
function c12615446.matfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- ①效果的发动代价：从这张卡取除2个超量素材（作为COST）。
function c12615446.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- ①效果的目标选择函数：选择对方场上1只可以变更表示形式的怪兽作为对象，并检查发动时是否满足条件。
function c12615446.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanChangePosition() end
	-- 效果发动时检查：对方场上是否存在至少1只可以变更表示形式的怪兽，作为能否发动的条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家显示选择提示，提示内容为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从对方场上选择1只可以变更表示形式的怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ①效果处理：变更对象怪兽的表示形式，若变更成功且对象怪兽表侧表示并能被此效果无效，则将其效果无效直到回合结束时。
function c12615446.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出当前连锁中登记的第一次对象卡（即①效果选择的对象怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果有联系后，令其变更表示形式（表侧守备/里侧守备/表侧攻击），并判定是否满足无效条件。
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)>0 and (tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e)) then
		-- 使与对象怪兽相关的连锁效果全部无效化，该无效状态在怪兽变里侧表示时重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那个效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那个效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- ②效果的发动条件：这张卡战斗破坏对方怪兽并把它送去墓地时，且这张卡仍与战斗有关，被破坏的怪兽在墓地且可以作为超量素材。
function c12615446.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if not c:IsRelateToBattle() then return false end
	e:SetLabelObject(tc)
	return tc:IsLocation(LOCATION_GRAVE) and tc:IsType(TYPE_MONSTER) and tc:IsReason(REASON_BATTLE) and tc:IsCanOverlay()
end
-- ②效果发动时：将战斗破坏的对方怪兽设为对象，并设定操作信息，以便处理时将其从墓地叠放。
function c12615446.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
	local tc=e:GetLabelObject()
	-- 将战斗破坏的对方怪兽登记为当前连锁操作的对象卡。
	Duel.SetTargetCard(tc)
	-- 设定操作信息：预计将对象卡从墓地移出（作为超量素材叠放），处理数量为1。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
-- ②效果处理：若这张卡与对象卡仍与效果有联系，且对象卡可以作为超量素材，则将对象卡叠放在这张卡下面作为超量素材。
function c12615446.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出②效果的对象卡（战斗破坏的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsCanOverlay() then
		-- 将对象卡作为这张卡的超量素材叠放。
		Duel.Overlay(c,tc)
	end
end
