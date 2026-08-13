--RR－ファイナル・フォートレス・ファルコン
-- 效果：
-- 12星怪兽×3
-- ①：有「急袭猛禽」超量怪兽在作为超量素材中的这张卡不受其他卡的效果影响。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。除外的自己的「急袭猛禽」怪兽全部回到墓地。
-- ③：这张卡的攻击破坏怪兽时，把自己墓地1只「急袭猛禽」超量怪兽除外才能发动。这张卡可以继续攻击。这个效果1回合可以使用最多2次。
function c43047672.initial_effect(c)
	-- 为这张卡添加超量召唤规则：以3只等级12的怪兽作为超量素材进行超量召唤（素材无特殊限制）。
	aux.AddXyzProcedure(c,nil,12,3)
	c:EnableReviveLimit()
	-- ①：有「急袭猛禽」超量怪兽在作为超量素材中的这张卡不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c43047672.imcon)
	e1:SetValue(c43047672.efilter)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。除外的自己的「急袭猛禽」怪兽全部回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43047672,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c43047672.cost)
	e2:SetTarget(c43047672.target)
	e2:SetOperation(c43047672.operation)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击破坏怪兽时，把自己墓地1只「急袭猛禽」超量怪兽除外才能发动。这张卡可以继续攻击。这个效果1回合可以使用最多2次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43047672,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(2)
	e3:SetCondition(c43047672.atcon)
	e3:SetCost(c43047672.atcost)
	e3:SetOperation(c43047672.atop)
	c:RegisterEffect(e3)
end
-- 筛选卡片是否满足“急袭猛禽”字段且为超量怪兽，用于判断超量素材中是否存在此类卡片。
function c43047672.imfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ)
end
-- 免疫效果的条件：这张卡的超量素材中存在至少1只「急袭猛禽」超量怪兽。
function c43047672.imcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(c43047672.imfilter,1,nil)
end
-- 判定要被免疫的效果是否由其他卡发动：若效果所有者不是本卡，则本卡不受该效果影响。
function c43047672.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- ②的发动代价——取除这张卡的1个超量素材：先检查能否取除，再实际取除1个素材。
function c43047672.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选自己除外区中表侧表示且属于「急袭猛禽」字段的怪兽，用于②效果送回墓地。
function c43047672.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER)
end
-- ②的发动目标处理：确认自己除外区存在符合条件的「急袭猛禽」怪兽；获取所有此类卡并设置操作信息，声明效果处理时将其送入墓地。
function c43047672.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件检查：确认自己除外区存在至少1张符合条件的「急袭猛禽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c43047672.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 获取自己除外区所有符合条件的「急袭猛禽」怪兽，作为操作信息的目标组。
	local g=Duel.GetMatchingGroup(c43047672.filter,tp,LOCATION_REMOVED,0,nil)
	-- 设置操作信息：声明本效果将把这些卡片送去墓地，并记录预计处理数量，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- ②效果处理：重新获取自己除外区所有符合条件的「急袭猛禽」怪兽，若存在则全部送往墓地，原因标记为效果+回归。
function c43047672.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新取得自己除外区所有符合条件的「急袭猛禽」怪兽，确保使用最新状态。
	local g=Duel.GetMatchingGroup(c43047672.filter,tp,LOCATION_REMOVED,0,nil)
	if g:GetCount()>0 then
		-- 将取得的所有符合条件的「急袭猛禽」怪兽送入墓地，原因包含效果和回归。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
	end
end
-- ③的发动条件：本卡作为攻击怪兽与对方怪兽战斗并将其破坏，且本卡能够继续发动追加攻击。
function c43047672.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 发动条件判断：攻击者是本卡、本卡在战斗破坏对方怪兽的事件中满足条件、且本卡当前可继续攻击。
	return Duel.GetAttacker()==c and aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and c:IsChainAttackable(0)
end
-- 筛选墓地中属于「急袭猛禽」字段的超量怪兽且能够作为除外代价的卡片。
function c43047672.atfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ) and c:IsAbleToRemoveAsCost()
end
-- ③的发动代价——从自己墓地选择1只符合条件的「急袭猛禽」超量怪兽除外：先确认存在可选卡，再提示选择并表侧除外。
function c43047672.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己墓地存在至少1张符合条件的「急袭猛禽」超量怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c43047672.atfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1张符合条件的「急袭猛禽」超量怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c43047672.atfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡片以表侧表示除外，作为③效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ③效果处理：让这张卡获得一次追加攻击机会。
function c43047672.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前进行攻击的怪兽能够继续进行下一次攻击。
	Duel.ChainAttack()
end
