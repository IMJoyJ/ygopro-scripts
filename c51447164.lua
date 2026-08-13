--TG ブレード・ガンナー
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽1只以上
-- ①：场上的这张卡为对象的魔法·陷阱卡由对方发动时，把1张手卡送去墓地才能发动。那个效果无效。
-- ②：对方回合1次，从自己墓地把1只「科技属」怪兽除外才能发动。表侧表示的这张卡除外。
-- ③：这张卡的②的效果除外的场合，下次的准备阶段发动。除外状态的这张卡特殊召唤。
function c51447164.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求素材为「同调怪兽调整」＋「调整以外的同调怪兽1只以上」。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1)
	c:EnableReviveLimit()
	-- ①：场上的这张卡为对象的魔法·陷阱卡由对方发动时，把1张手卡送去墓地才能发动。那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51447164,0))  --"魔法·陷阱卡的效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c51447164.discon)
	e1:SetCost(c51447164.discost)
	e1:SetTarget(c51447164.distg)
	e1:SetOperation(c51447164.disop)
	c:RegisterEffect(e1)
	-- ②：对方回合1次，从自己墓地把1只「科技属」怪兽除外才能发动。表侧表示的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51447164,1))  --"这张卡除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c51447164.rmcon)
	e2:SetCost(c51447164.rmcost)
	e2:SetTarget(c51447164.rmtg)
	e2:SetOperation(c51447164.rmop)
	c:RegisterEffect(e2)
	-- ③：这张卡的②的效果除外的场合，下次的准备阶段发动。除外状态的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51447164,2))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1)
	e3:SetCondition(c51447164.spcon)
	e3:SetTarget(c51447164.sptg)
	e3:SetOperation(c51447164.spop)
	c:RegisterEffect(e3)
end
c51447164.material_type=TYPE_SYNCHRO
-- 效果①的发动条件判定：若这张卡处于战斗破坏确定状态则不能发动；被连锁的效果必须是魔法·陷阱卡的发动且可被无效；且该效果为取对象效果，对象中包含这张卡。
function c51447164.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 确认被连锁的效果是魔法·陷阱卡的发动，且该连锁效果可以被无效，否则不满足发动条件。
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not Duel.IsChainDisablable(ev) then return false end
	-- 确认被连锁的效果是取对象效果，且当前连锁的对象中包含这张卡。
	return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(c)
end
-- 效果①的代价处理：从手卡选1张卡作为COST送去墓地；发动前检查手卡是否存在可送去墓地的卡，实际发动时提示并选择1张送入墓地。
function c51447164.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为代价检查：自己手卡中是否存在至少1张可以作为COST送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示，要求从手卡选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己手卡选择1张可以作为COST送去墓地的卡，返回所选卡组。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手卡以REASON_COST（作为代价）送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的目标处理：没有取对象的额外条件；设置本次连锁操作信息为无效效果，对象为当前发动的那张卡。
function c51447164.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：本次处理将对当前发动的那张魔法·陷阱卡进行效果无效（CATEGORY_DISABLE）。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果①的发动处理：使连锁序号ev对应的那个魔法·陷阱卡效果无效。
function c51447164.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前连锁中指定的那个效果。
	Duel.NegateEffect(ev)
end
-- 效果②的发动条件：当前回合玩家不是这张卡的控制者，即只在对方回合可以发动。
function c51447164.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不是tp，满足「对方回合」的发动条件。
	return Duel.GetTurnPlayer()~=tp
end
-- 效果②的代价过滤器：自己墓地中卡名属于「科技属」的怪兽卡，并且可以被除外作为COST。
function c51447164.rmfilter(c)
	return c:IsSetCard(0x27) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果②的代价处理：从自己墓地选1只符合条件的「科技属」怪兽除外作为COST；发动前检查是否存在，实际发动时提示选择并除外。
function c51447164.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为代价检查：自己墓地是否存在1只符合rmfilter的「科技属」怪兽可以除外作为COST。
	if chk==0 then return Duel.IsExistingMatchingCard(c51447164.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，要求从自己墓地选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只符合条件的「科技属」怪兽，作为COST除外的对象。
	local g=Duel.SelectMatchingCard(tp,c51447164.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽以表侧表示除外，作为COST。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的目标处理：目标就是这张卡自身；检查这张卡能否被除外，并设置操作信息为除外这张卡。
function c51447164.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 设置连锁操作信息：本次处理将除外这张卡自身（CATEGORY_REMOVE）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 效果②的发动处理：若这张卡仍与效果有联系且被效果成功表侧除外，则给它设置标记51447164；若当前已经是准备阶段则标记持续到下一次准备阶段并记录当前回合数，否则标记在下一个准备阶段重置，用于③在下次准备阶段发动。
function c51447164.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果e有关，并且以表侧表示除外成功（若失败则不进行处理）。
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 判断当前阶段是否已经是准备阶段，用于决定标记的持续时间，避免在当次准备阶段立即触发③。
		if Duel.GetCurrentPhase()==PHASE_STANDBY then
			-- 给这张卡注册标记51447164，重置时机为准备阶段；若当前在准备阶段则持续到第2次准备阶段并记录当前回合数，否则持续到下次准备阶段。
			c:RegisterFlagEffect(51447164,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2,Duel.GetTurnCount())
		else
			c:RegisterFlagEffect(51447164,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1)
		end
	end
end
-- 效果③的发动条件：除外状态的这张卡带有标记51447164，且标记记录的回合数不是当前回合数，即已经到达下一个准备阶段。
function c51447164.spcon(e,tp,eg,ep,ev,re,r,rp)
	local label=e:GetHandler():GetFlagEffectLabel(51447164)
	-- 确认存在标记且标记记录的回合数与当前回合数不同，确保「下次准备阶段」才发动。
	return label and label~=Duel.GetTurnCount()
end
-- 效果③的目标处理：无额外选择；发动时清除标记，并设置操作信息为特殊召唤这张卡。
function c51447164.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():ResetFlagEffect(51447164)
	-- 设置连锁操作信息：本次处理将把除外状态的这张卡特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的发动处理：若这张卡仍与该效果有联系，将其特殊召唤上场；否则不处理。
function c51447164.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到tp的场上（特殊召唤手续检查按常规进行）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
