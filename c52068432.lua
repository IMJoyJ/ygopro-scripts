--トリシューラの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡若非以只使用除9星以外的怪兽来作的仪式召唤则不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的「影灵衣」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个发动无效。
-- ②：这张卡仪式召唤时才能发动。对方的手卡·场上·墓地的卡各1张合计3张除外（从手卡是随机选）。
function c52068432.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡若非以只使用除9星以外的怪兽来作的仪式召唤则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置此卡的特殊召唤条件为必须通过仪式召唤且使用的素材怪兽等级不能为9。
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：自己场上的「影灵衣」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52068432,0))  --"效果无效"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,52068432)
	e2:SetCondition(c52068432.negcon)
	e2:SetCost(c52068432.negcost)
	e2:SetTarget(c52068432.negtg)
	e2:SetOperation(c52068432.negop)
	c:RegisterEffect(e2)
	-- ②：这张卡仪式召唤时才能发动。对方的手卡·场上·墓地的卡各1张合计3张除外（从手卡是随机选）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(52068432,1))  --"卡片除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,52068433)
	e3:SetCondition(c52068432.remcon)
	e3:SetTarget(c52068432.remtg)
	e3:SetOperation(c52068432.remop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断怪兽是否等级不是9。
function c52068432.mat_filter(c)
	return not c:IsLevel(9)
end
-- 过滤函数，用于判断目标怪兽是否为己方场上表侧表示的「影灵衣」怪兽。
function c52068432.tfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb4) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
-- 效果发动时的条件判断函数，检查连锁效果是否针对己方场上的「影灵衣」怪兽发动且该连锁可以被无效。
function c52068432.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果对象卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 返回值为真表示当前连锁效果的对象中存在己方场上的「影灵衣」怪兽，且该连锁可以被无效。
	return g and g:IsExists(c52068432.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 效果发动时的费用支付函数，将此卡从手卡丢弃作为费用。
function c52068432.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡从手卡送去墓地并支付丢弃费用。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 设置效果处理时的操作信息，准备使连锁效果无效。
function c52068432.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使连锁效果无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果处理函数，使当前连锁的效果无效。
function c52068432.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前正在处理的连锁发动无效。
	Duel.NegateActivation(ev)
end
-- 判断此卡是否通过仪式召唤方式特殊召唤成功。
function c52068432.remcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 设置效果处理时的操作信息，检查是否有满足条件的卡片可以除外。
function c52068432.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌中是否存在可除外的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil)
		-- 检查对方场上是否存在可除外的卡片。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查对方墓地中是否存在可除外的卡片。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 设置操作信息为除外对方手牌、场上和墓地各一张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理函数，从对方手牌、场上和墓地中各随机选择一张卡除外。
function c52068432.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌中所有可除外的卡片组。
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	-- 获取对方场上所有可除外的卡片组。
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	-- 获取对方墓地中所有可除外的卡片组。
	local g3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	if g1:GetCount()>0 and g2:GetCount()>0 and g3:GetCount()>0 then
		-- 提示玩家选择要除外的卡（手牌部分）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg1=g1:RandomSelect(tp,1)
		-- 提示玩家选择要除外的卡（场上部分）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg2=g2:Select(tp,1,1,nil)
		-- 提示玩家选择要除外的卡（墓地部分）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg3=g3:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		sg1:Merge(sg3)
		-- 显示所选卡片被作为对象的动画效果。
		Duel.HintSelection(sg1)
		-- 将选定的卡片以除外方式处理，原因设为效果。
		Duel.Remove(sg1,POS_FACEUP,REASON_EFFECT)
	end
end
