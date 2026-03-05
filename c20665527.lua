--揚陸群艦アンブロエール
-- 效果：
-- 效果怪兽2只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的攻击力上升双方墓地的连接怪兽数量×200。
-- ②：这张卡被破坏的场合，以自己或对方的墓地1只连接3以下的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
-- ③：这张卡在墓地存在的状态，场上的连接3以下的怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。场上1张卡破坏。
function c20665527.initial_effect(c)
	-- 注册一个监听卡片进入墓地事件的单次持续效果，用于记录卡片是否已进入墓地状态
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 为卡片添加连接召唤手续，要求使用至少2个满足条件的连接怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升双方墓地的连接怪兽数量×200
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c20665527.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏的场合，以自己或对方的墓地1只连接3以下的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤
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
	-- ③：这张卡在墓地存在的状态，场上的连接3以下的怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。场上1张卡破坏
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
	-- 设置效果的发动费用为将此卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c20665527.destg)
	e3:SetOperation(c20665527.desop)
	c:RegisterEffect(e3)
end
-- 计算并返回双方墓地连接怪兽数量乘以200作为攻击力提升值
function c20665527.atkval(e,c)
	-- 获取双方墓地中的连接怪兽数量并乘以200作为攻击力提升值
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_LINK)*200
end
-- 定义特殊召唤目标的过滤函数，筛选墓地中的连接怪兽且等级不超过3
function c20665527.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsLinkBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择函数，检查是否有满足条件的墓地怪兽可被特殊召唤
function c20665527.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c20665527.spfilter(chkc,e,tp) end
	-- 检查场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c20665527.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c20665527.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置特殊召唤操作的信息，确定要处理的卡和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将目标怪兽特殊召唤到场上
function c20665527.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义破坏条件的过滤函数，筛选因战斗或效果被破坏的连接怪兽
function c20665527.cfilter(c,se)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsType(TYPE_LINK) and c:IsLinkBelow(3)
		and c:IsPreviousLocation(LOCATION_MZONE) and (se==nil or c:GetReasonEffect()~=se)
end
-- 判断是否满足效果发动条件，即是否有符合条件的连接怪兽被破坏
function c20665527.descon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c20665527.cfilter,1,e:GetHandler(),se)
end
-- 设置破坏效果的目标选择函数，检查场上是否存在可破坏的卡片
function c20665527.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可破坏的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有可破坏的卡片组
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置破坏操作的信息，确定要处理的卡和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏操作，选择并破坏场上的一张卡
function c20665527.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有可破坏的卡片组
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 向玩家提示选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 显示被选为破坏对象的卡片动画
		Duel.HintSelection(sg)
		-- 将选中的卡片以效果原因破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
