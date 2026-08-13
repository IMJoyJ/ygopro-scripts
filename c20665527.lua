--揚陸群艦アンブロエール
-- 效果：
-- 效果怪兽2只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的攻击力上升双方墓地的连接怪兽数量×200。
-- ②：这张卡被破坏的场合，以自己或对方的墓地1只连接3以下的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
-- ③：这张卡在墓地存在的状态，场上的连接3以下的怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。场上1张卡破坏。
function c20665527.initial_effect(c)
	-- 为这张卡注册一个“已在墓地”的标记检测效果，以便③效果正确判断“这张卡在墓地存在的状态”这一发动前提。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 为这张卡设置连接召唤手续：需要2只以上效果怪兽作为连接素材，对应召唤条件“效果怪兽2只以上”。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- 对应①效果原文：“①：这张卡的攻击力上升双方墓地的连接怪兽数量×200。”该段代码创建了永续地增减攻击力的效果，并通过atkval函数计算上升数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c20665527.atkval)
	c:RegisterEffect(e1)
	-- 对应②效果原文：“②：这张卡被破坏的场合，以自己或对方的墓地1只连接3以下的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。”该段代码将该效果实现为诱发选发、取对象、特殊召唤效果，并设置1回合1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20665527,0))
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,20665527)
	e2:SetTarget(c20665527.sptg)
	e2:SetOperation(c20665527.spop)
	c:RegisterEffect(e2)
	-- 对应③效果原文：“③：这张卡在墓地存在的状态，场上的连接3以下的怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。场上1张卡破坏。”该段代码将该效果实现为墓地诱发效果，需要除外自身为代价，破坏场上1张卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20665527,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetLabelObject(e0)
	e3:SetCountLimit(1,20665528)
	e3:SetCondition(c20665527.descon)
	-- 设置③效果的发动代价为：把墓地存在的这张卡本身除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c20665527.destg)
	e3:SetOperation(c20665527.desop)
	c:RegisterEffect(e3)
end
-- 定义①效果的攻击力数值计算函数：以这张卡的控制者视角，统计双方墓地的连接怪兽数量并乘以200，作为攻击力上升值。
function c20665527.atkval(e,c)
	-- 返回双方墓地连接怪兽数量×200的数值，用于①效果攻击力上升的结算。
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_LINK)*200
end
-- 定义②效果的特殊召唤对象筛选条件：对象必须是连接怪兽、连接3以下，并且可以被当前玩家tp以效果特殊召唤。
function c20665527.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsLinkBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义②效果的发动目标判定：检查对象合法性（在墓地且满足spfilter），并判断发动时场上是否有空位、墓地是否存在满足条件的对象可供选择。
function c20665527.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c20665527.spfilter(chkc,e,tp) end
	-- ②效果发动合法性检查的第一个条件：我方主要怪兽区域存在可用的空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- ②效果发动合法性检查的第二个条件：双方墓地存在至少1只满足spfilter的怪兽可以作为取对象目标。
		and Duel.IsExistingTarget(c20665527.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 在选择特殊召唤对象前，向玩家显示提示消息“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让tp从双方墓地选择1只满足spfilter的连接3以下怪兽，并将其设为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c20665527.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：包含特殊召唤分类，对象为已选择的怪兽g，数量为1，供其他卡进行发动对应/无效等判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义②效果发动的处理：取得对象怪兽，若其仍与效果关联，则将其表侧表示特殊召唤到tp的怪兽区。
function c20665527.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁已选择的对象怪兽，即②效果从墓地选出的连接3以下怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到tp的场上，不改变控制者，且正常检查召唤条件和苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义③效果的被破坏怪兽筛选条件：被战斗或效果破坏、是连接3以下的连接怪兽、破坏前在怪兽区，且不是本卡的③效果自身造成的破坏。
function c20665527.cfilter(c,se)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsType(TYPE_LINK) and c:IsLinkBelow(3)
		and c:IsPreviousLocation(LOCATION_MZONE) and (se==nil or c:GetReasonEffect()~=se)
end
-- 定义③效果的发动条件：本次破坏事件的怪兽集合中存在满足cfilter的怪兽（排除本卡③效果自身的效果），同时借助标记确认这张卡已在墓地存在。
function c20665527.descon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c20665527.cfilter,1,e:GetHandler(),se)
end
-- 定义③效果发动时的目标判定：检查场上是否存在可破坏的卡，并将场上所有卡作为破坏候补设置操作信息；实际破坏对象在效果处理时选择。
function c20665527.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ③效果发动合法性检查：场上（双方怪兽区和魔陷区）至少存在1张可以被破坏的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 取得场上所有卡（包括双方怪兽区和魔陷区）作为破坏候补集合，用于设置③效果的操作信息。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置③效果的操作信息：属于破坏效果，候选对象为场上所有卡，预定破坏数量为1（不取对象，效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义③效果处理：从当前场上所有卡中选择1张，给予选中动画后将其破坏。
function c20665527.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新取得当前场上所有卡作为破坏选择范围，因为效果处理时场上情况可能已发生变化。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 选择要破坏的卡时，向玩家显示提示消息“请选择要破坏的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 手动显示被选为破坏对象的卡的选中动画，并记录该卡被选为（广义）对象。
		Duel.HintSelection(sg)
		-- 以效果破坏的原因将选中的卡送入墓地，完成③效果的破坏处理。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
