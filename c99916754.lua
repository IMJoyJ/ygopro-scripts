--ナチュル・エクストリオ
-- 效果：
-- 「自然兽」＋「自然木鳞龙」
-- 这张卡的融合召唤不用上记的卡不能进行。
-- ①：魔法·陷阱卡发动时，从自己墓地把1张卡除外，把卡组最上面的卡送去墓地才能发动。这张卡在场上表侧表示存在的场合，那个发动无效并破坏。
function c99916754.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材固定为「自然兽」(33198837)和「自然木鳞龙」(2956282)，不启用替代素材，对应“这张卡的融合召唤不用上记的卡不能进行”。
	aux.AddFusionProcCode2(c,33198837,2956282,false,false)
	-- ①：魔法·陷阱卡发动时，从自己墓地把1张卡除外，把卡组最上面的卡送去墓地才能发动。这张卡在场上表侧表示存在的场合，那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99916754,0))  --"魔法·陷阱卡的发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c99916754.discon)
	e2:SetCost(c99916754.discost)
	e2:SetTarget(c99916754.distg)
	e2:SetOperation(c99916754.disop)
	c:RegisterEffect(e2)
end
c99916754.material_type=TYPE_SYNCHRO
-- 效果发动条件判定：本卡未被战斗破坏确定，且当前连锁发动的效果为魔法·陷阱卡的发动，并且该发动可以被无效。
function c99916754.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 进一步确认连锁的效果是魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），且该连锁的发动可以被无效（Duel.IsChainNegatable）。
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 代价检查与执行：发动前需要确认能否从卡组最上方丢弃1张卡，且墓地存在1张能作为代价除外的卡；满足后在发动时执行除外和丢弃卡组顶的操作。
function c99916754.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认玩家能否从卡组最上方将1张卡送去墓地作为发动代价。
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1)
		-- 代价检查阶段：确认玩家墓地存在至少1张可以除外的卡，用于作为发动代价的一部分。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,nil) end
	-- 发送选择提示消息，提示玩家从墓地选择要除外的卡（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 由玩家从自己墓地选择1张可以除外的卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡片从墓地以表侧表示除外，作为发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 将卡组最上方的1张卡送去墓地，作为发动代价（REASON_COST）。
	Duel.DiscardDeck(tp,1,REASON_COST)
end
-- 效果发动目标设定：允许发动后将连锁中的那张卡设为无效对象；如果该卡可被破坏且与效果相关联，则同时设为破坏对象。
function c99916754.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：声明本次效果具有使连锁发动无效（CATEGORY_NEGATE）的效果，对象为连锁中的卡片eg。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：声明本次效果在无效后还可破坏那张卡（CATEGORY_DESTROY），对象为连锁中的卡片eg。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：先确认本卡仍表侧表示且与效果关联，若成立则无效对方魔法·陷阱卡的发动，成功后若该卡仍关联则将其破坏。
function c99916754.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 执行无效发动操作，若成功且被无效的卡在处理时仍与效果关联，则继续执行后续破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将已被无效的魔法·陷阱卡破坏，破坏原因视为效果（REASON_EFFECT）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
