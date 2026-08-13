--カオス・ネフティス
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，场上的卡被效果破坏的场合，从自己墓地把「混沌奈芙提斯」以外的光属性和暗属性的怪兽各1只除外才能发动。这张卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合，以对方场上1张卡和对方墓地2张卡为对象才能发动。那些卡除外。
function c24226942.initial_effect(c)
	c:EnableReviveLimit()
	-- 对应效果原文“这张卡不能通常召唤，用这张卡的效果才能特殊召唤。”中的“用这张卡的效果才能特殊召唤”限制，以不可无效、不可复制的特殊召唤条件实现。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 对应效果原文“这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在，场上的卡被效果破坏的场合，从自己墓地把「混沌奈芙提斯」以外的光属性和暗属性的怪兽各1只除外才能发动。这张卡特殊召唤。”该段代码整体实现①效果的诱发条件、代价、目标与处理。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,24226942)
	e2:SetCondition(c24226942.spcon)
	e2:SetCost(c24226942.spcost)
	e2:SetTarget(c24226942.sptg)
	e2:SetOperation(c24226942.spop)
	c:RegisterEffect(e2)
	-- 对应效果原文“②：这张卡特殊召唤成功的场合，以对方场上1张卡和对方墓地2张卡为对象才能发动。那些卡除外。”该段代码整体实现②效果的诱发条件、取对象与除外处理。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c24226942.rmtg)
	e3:SetOperation(c24226942.rmop)
	c:RegisterEffect(e3)
end
-- 判定被破坏的卡是否为“场上的卡被效果破坏”：该卡此前位于场上，且破坏原因为效果。
function c24226942.cfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
-- ①的诱发条件：本次破坏集合中存在至少1张满足“场上被效果破坏”的卡；并且若本卡不在手牌（即在墓地），本卡不能是这次被破坏的卡之一。
function c24226942.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(c24226942.cfilter,1,nil) and (c:IsLocation(LOCATION_HAND) or not eg:IsContains(c))
end
-- ①代价的卡片过滤器：从自己墓地选出可作为代价除外的卡，要求属性为光属性或暗属性，且卡名不是「混沌奈芙提斯」。
function c24226942.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and not c:IsCode(24226942)
end
-- ①的代价处理：从自己墓地中选出「混沌奈芙提斯」以外的光属性与暗属性怪兽各1只，表侧表示除外作为发动代价。
function c24226942.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中满足①代价条件的候选卡集合。
	local g=Duel.GetMatchingGroup(c24226942.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 发动时合法检查：候选卡组中能否选出2张卡，其中1张为光属性、另1张为暗属性（即光、暗怪兽各1只）。
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK) end
	-- 向玩家显示“请选择要除外的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从候选卡组中选择2张卡，须为光属性与暗属性各1只，作为除外的代价。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	-- 将选出的代价卡表侧表示除外，除外原因记为发动代价（REASON_COST）。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- ①特殊召唤的目标判断：确认自己怪兽区域有空位且这张卡可以进行特殊召唤；并在合法时设置特殊召唤的操作信息。
function c24226942.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方怪兽区域是否存在可用空格，以决定能否特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	-- 设置当前连锁的操作信息为“特殊召唤”，处理对象为本卡，供其他连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的特殊召唤处理：若本卡仍与效果关联，则将其表侧表示特殊召唤到自己场上，成功后调用CompleteProcedure完成特殊召唤手续。
function c24226942.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认本卡仍与效果关联，并以表侧表示将其特殊召唤；如果特殊召唤成功，则继续执行后续完成手续。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- ②的取对象目标判断：选择对方场上1张卡和对方墓地2张卡作为除外对象，要求这些卡可以被除外。
function c24226942.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方场上是否存在1张可以被除外的卡，作为②的对象候选。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查对方墓地是否存在2张可以被除外的卡，作为②的对象候选。
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,2,nil) end
	-- 向玩家显示“请选择要除外的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上的1张卡作为②的对象，并将其记录为当前连锁的对象。
	local g1=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 向玩家显示“请选择要除外的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地的2张卡作为②的对象，并将其记录为当前连锁的对象。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,2,2,nil)
	g1:Merge(g2)
	-- 设置操作信息为除外，目标为已选的对象卡组，数量为已选择的对象数。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
end
-- ②的除外处理：取得当前连锁记录的全部对象卡，过滤出仍与效果关联的卡，将它们表侧表示除外。
function c24226942.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的全部对象卡（包括对方场上选中的1张和对方墓地选中的2张）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将与效果仍有关联的对象卡表侧表示除外，除外原因记为效果（REASON_EFFECT）。
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
