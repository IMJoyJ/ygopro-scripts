--TG ブレード・ガンナー
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽1只以上
-- ①：场上的这张卡为对象的魔法·陷阱卡由对方发动时，把1张手卡送去墓地才能发动。那个效果无效。
-- ②：对方回合1次，从自己墓地把1只「科技属」怪兽除外才能发动。表侧表示的这张卡除外。
-- ③：这张卡的②的效果除外的场合，下次的准备阶段发动。除外状态的这张卡特殊召唤。
function c51447164.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只以上调整以外的同调怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1)
	c:EnableReviveLimit()
	-- 场上的这张卡为对象的魔法·陷阱卡由对方发动时，把1张手卡送去墓地才能发动。那个效果无效。
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
	-- 对方回合1次，从自己墓地把1只「科技属」怪兽除外才能发动。表侧表示的这张卡除外。
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
	-- 这张卡的②的效果除外的场合，下次的准备阶段发动。除外状态的这张卡特殊召唤。
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
-- 效果发动时的条件判断，确保该卡未因战斗破坏且对方发动的是魔法或陷阱卡并可被无效
function c51447164.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 判断对方发动的连锁是否为魔法或陷阱卡类型且该连锁可被无效
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not Duel.IsChainDisablable(ev) then return false end
	-- 判断对方发动的连锁是否以这张卡为目标
	return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(c)
end
-- 支付效果cost，从手牌中选择1张卡送去墓地
function c51447164.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可送入墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的手牌卡组
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡送去墓地作为cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果目标，使对方发动的魔法或陷阱卡效果无效
function c51447164.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 执行效果，使连锁效果无效
function c51447164.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前处理的连锁效果无效
	Duel.NegateEffect(ev)
end
-- ②效果发动条件判断，确保在对方回合
function c51447164.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤器函数，用于筛选墓地中的「科技属」怪兽
function c51447164.rmfilter(c)
	return c:IsSetCard(0x27) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 支付②效果cost，从墓地中选择1只「科技属」怪兽除外
function c51447164.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在至少1只满足条件的「科技属」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c51447164.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的墓地怪兽
	local g=Duel.SelectMatchingCard(tp,c51447164.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外作为cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置②效果的目标，将自身除外
function c51447164.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 设置操作信息为除外自身
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 执行②效果的操作，将自身除外并记录flag
function c51447164.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否还在场上且成功除外
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 判断当前阶段是否为准备阶段
		if Duel.GetCurrentPhase()==PHASE_STANDBY then
			-- 注册flag，标记下次准备阶段可特殊召唤
			c:RegisterFlagEffect(51447164,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2,Duel.GetTurnCount())
		else
			c:RegisterFlagEffect(51447164,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1)
		end
	end
end
-- ③效果发动条件判断，检查flag是否满足
function c51447164.spcon(e,tp,eg,ep,ev,re,r,rp)
	local label=e:GetHandler():GetFlagEffectLabel(51447164)
	-- 判断flag标签不等于当前回合数
	return label and label~=Duel.GetTurnCount()
end
-- 设置③效果的目标，准备特殊召唤自身
function c51447164.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():ResetFlagEffect(51447164)
	-- 设置操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行③效果的操作，将自身特殊召唤
function c51447164.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身从除外区特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
