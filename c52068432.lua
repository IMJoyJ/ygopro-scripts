--トリシューラの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡若非以只使用除9星以外的怪兽来作的仪式召唤则不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的「影灵衣」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个发动无效。
-- ②：这张卡仪式召唤时才能发动。对方的手卡·场上·墓地的卡各1张合计3张除外（从手卡是随机选）。
function c52068432.initial_effect(c)
	c:EnableReviveLimit()
	-- 「影灵衣」仪式魔法卡降临；这张卡若非以只使用除9星以外的怪兽来作的仪式召唤则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定函数，规定这张卡必须且只能通过仪式召唤的方式才能特殊召唤。
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上的「影灵衣」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个发动无效。
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
-- 定义仪式召唤素材筛选条件：只能使用等级不是9星的怪兽作为仪式召唤的素材。
function c52068432.mat_filter(c)
	return not c:IsLevel(9)
end
-- 定义对象筛选函数：检查卡片是否为表侧表示、属于「影灵衣」系列、控制者为效果发动方且位于主要怪兽区，即自己场上的表侧「影灵衣」怪兽。
function c52068432.tfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb4) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
-- ①效果的发动条件判定：对方发动的魔法·陷阱·怪兽效果是以自己场上的表侧「影灵衣」怪兽为对象，且该连锁可以被无效。
function c52068432.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 从当前连锁信息中取出被那个效果作为对象的所有卡片（对象卡组）。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 确认连锁对象中存在自己场上的表侧「影灵衣」怪兽，且该连锁能被无效化，两者同时满足才允许发动。
	return g and g:IsExists(c52068432.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- ①效果的发动代价：从手卡丢弃这张卡自身；合法性检查时确认这张卡可以丢弃，实际处理时将其从手卡送去墓地。
function c52068432.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡以“代价+丢弃”的原因从手卡送去墓地，完成丢弃代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- ①效果发动时无需额外选择对象，只登记要将当前连锁的发动无效化的操作信息。
function c52068432.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将操作信息登记为“无效发动”，对象为当前触发的连锁（eg），供后续无效处理及联动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ①效果处理时，将对方发动的那个魔法·陷阱·怪兽效果的发动无效化。
function c52068432.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 令指定连锁编号ev的效果发动无效，并返回是否成功。
	Duel.NegateActivation(ev)
end
-- ②效果的发动条件：这张卡是以仪式召唤方式特殊召唤成功。
function c52068432.remcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- ②效果发动前确认对方手卡、场上、墓地都各有至少1张可以被除外的卡，缺一不可。
function c52068432.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若处于发动合法性检查阶段，先检查对方手牌是否存在至少1张可以除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil)
		-- 同时检查对方场上是否存在至少1张可以除外的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
		-- 同时检查对方墓地是否存在至少1张可以除外的卡；三个区域均有可除外卡时才满足发动条件。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 登记②效果的除外操作信息：预计从对方手卡、场上、墓地各除外1张（合计3张），因具体对象在处理时才确定，所以对象传nil。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND)
end
-- ②效果处理：分别获取对方手卡、场上、墓地的可除外卡组，从手卡随机选1张、场上选1张、墓地选1张，合并后表侧表示除外。
function c52068432.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方手牌中所有当前可以除外的卡组成的集合。
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	-- 取得对方场上所有当前可以除外的卡组成的集合。
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	-- 取得对方墓地所有当前可以除外的卡组成的集合。
	local g3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	if g1:GetCount()>0 and g2:GetCount()>0 and g3:GetCount()>0 then
		-- 在选择/随机选择手牌要除外的卡之前，向玩家显示“请选择要除外的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg1=g1:RandomSelect(tp,1)
		-- 在选择场上要除外的卡之前，向玩家显示“请选择要除外的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg2=g2:Select(tp,1,1,nil)
		-- 在选择墓地要除外的卡之前，向玩家显示“请选择要除外的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg3=g3:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		sg1:Merge(sg3)
		-- 将最终选中的3张卡以被选为对象的动画效果展示出来，并记录这些卡被选为对象。
		Duel.HintSelection(sg1)
		-- 将选中的3张卡以表侧表示除外，除外的原因为效果（REASON_EFFECT）。
		Duel.Remove(sg1,POS_FACEUP,REASON_EFFECT)
	end
end
