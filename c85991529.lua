--Kozmo－ダークプラネット
-- 效果：
-- 这张卡不能通常召唤。把等级合计直到10以上的手卡的「星际仙踪」怪兽除外的场合才能特殊召唤。
-- ①：这张卡不会成为对方的效果的对象。
-- ②：魔法卡发动时，从自己墓地把1只「星际仙踪」怪兽除外才能发动。那个发动无效并破坏。
-- ③：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只9星以下的「星际仙踪」怪兽加入手卡。
function c85991529.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把等级合计直到10以上的手卡的「星际仙踪」怪兽除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c85991529.spcon)
	e2:SetTarget(c85991529.sptg)
	e2:SetOperation(c85991529.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	-- 设置不会成为对方卡的效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：魔法卡发动时，从自己墓地把1只「星际仙踪」怪兽除外才能发动。那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(85991529,0))  --"发动无效并破坏"
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(c85991529.discon)
	e4:SetCost(c85991529.discost)
	e4:SetTarget(c85991529.distg)
	e4:SetOperation(c85991529.disop)
	c:RegisterEffect(e4)
	-- ③：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只9星以下的「星际仙踪」怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(c85991529.thcon)
	e5:SetCost(c85991529.thcost)
	e5:SetTarget(c85991529.thtg)
	e5:SetOperation(c85991529.thop)
	c:RegisterEffect(e5)
end
-- 特殊召唤条件的过滤函数：手卡中可除外的「星际仙踪」怪兽
function c85991529.spfilter(c)
	return c:IsSetCard(0xd2) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判断函数
function c85991529.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家怪兽区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return false end
	-- 获取手卡中除自身以外满足特殊召唤过滤条件的卡片组
	local g=Duel.GetMatchingGroup(c85991529.spfilter,tp,LOCATION_HAND,0,c)
	return g:CheckWithSumGreater(Card.GetLevel,10)
end
-- 特殊召唤所需除外卡片的组合选择过滤函数（等级合计直到10以上）
function c85991529.fselect(g)
	-- 设置已选择的卡片，用于后续的等级合计计算
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,10)
end
-- 特殊召唤规则的卡片选择目标函数
function c85991529.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中除自身以外满足特殊召唤过滤条件的卡片组
	local g=Duel.GetMatchingGroup(c85991529.spfilter,tp,LOCATION_HAND,0,c)
	-- 给玩家发送“请选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c85991529.fselect,true,1,g:GetCount())
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的具体操作函数
function c85991529.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg=e:GetLabelObject()
	-- 将选定的手卡怪兽因特殊召唤而表侧表示除外
	Duel.Remove(mg,POS_FACEUP,REASON_SPSUMMON)
	mg:DeleteGroup()
end
-- 无效魔法卡发动效果的条件判断函数
function c85991529.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 判断发动的卡是否为魔法卡，且该连锁的发动可以被无效
		and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 无效魔法卡发动效果的消耗（Cost）处理函数
function c85991529.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己墓地是否存在至少1只可除外的「星际仙踪」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85991529.spfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送“请选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只「星际仙踪」怪兽
	local g=Duel.SelectMatchingCard(tp,c85991529.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选定的墓地怪兽因效果发动消耗而表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 无效魔法卡发动效果的目标确认与操作信息设置函数
function c85991529.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息为“使该连锁的发动无效”
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置效果处理信息为“破坏该卡”
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效魔法卡发动效果的具体效果处理函数
function c85991529.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该连锁的发动无效，且该卡在场上与效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果将该卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 被破坏送墓时检索效果的条件判断函数
function c85991529.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 被破坏送墓时检索效果的消耗（Cost）处理函数
function c85991529.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and e:GetHandler():IsLocation(LOCATION_GRAVE) end
	-- 将墓地的这张卡因效果发动消耗而表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 检索效果的过滤函数：卡组中9星以下的「星际仙踪」怪兽
function c85991529.thfilter(c)
	return c:IsSetCard(0xd2) and c:IsLevelBelow(9) and c:IsAbleToHand()
end
-- 检索效果的目标确认与操作信息设置函数
function c85991529.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85991529.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为“从卡组将1张卡加入手卡”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的具体效果处理函数
function c85991529.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送“请选择要加入手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c85991529.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 因效果将选定的卡片加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
