--ダーク・クリエイター
-- 效果：
-- 这张卡不能通常召唤。自己墓地暗属性怪兽有5只以上存在，自己场上没有怪兽存在的场合可以特殊召唤。可以把自己墓地1只暗属性怪兽从游戏中除外，自己墓地1只暗属性怪兽特殊召唤。这个效果1回合只能使用1次。
function c92719314.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己墓地暗属性怪兽有5只以上存在，自己场上没有怪兽存在的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c92719314.spcon)
	c:RegisterEffect(e1)
	-- 可以把自己墓地1只暗属性怪兽从游戏中除外，自己墓地1只暗属性怪兽特殊召唤。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92719314,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c92719314.cost)
	e2:SetTarget(c92719314.target)
	e2:SetOperation(c92719314.operation)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件判定函数
function c92719314.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在怪兽（必须为0）
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查自己墓地是否存在至少5只暗属性怪兽
		and Duel.IsExistingMatchingCard(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,5,nil,ATTRIBUTE_DARK)
end
-- 过滤作为除外代价的暗属性怪兽，且除外该卡后墓地仍有可作为特殊召唤目标的怪兽
function c92719314.costfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
		-- 检查除外该卡后，墓地是否存在至少1只其他可作为特殊召唤目标的暗属性怪兽
		and Duel.IsExistingTarget(c92719314.tgfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
-- 过滤可以特殊召唤的暗属性怪兽
function c92719314.tgfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动代价函数，由于涉及在target中选择代价，此处仅设置标志并返回true
function c92719314.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 效果发动时的目标选择与合法性检查函数
function c92719314.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c92719314.tgfilter(chkc,e,tp) end
	if chk==0 then
		-- 检查自己场上是否有可用的怪兽区域，若无则无法发动效果
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查墓地是否存在满足代价过滤条件的卡片
			return Duel.IsExistingMatchingCard(c92719314.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		else
			-- 检查墓地是否存在可作为特殊召唤目标的卡片
			return Duel.IsExistingTarget(c92719314.tgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		end
	end
	if e:GetLabel()==1 then
		-- 提示玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择1张满足代价过滤条件的卡片
		local cg=Duel.SelectMatchingCard(tp,c92719314.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选择的卡片作为发动代价表侧表示除外
		Duel.Remove(cg,POS_FACEUP,REASON_COST)
		e:SetLabel(0)
	end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只暗属性怪兽作为特殊召唤的对象
	local g=Duel.SelectTarget(tp,c92719314.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含特殊召唤1个目标的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理（操作）函数
function c92719314.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取在发动时选择的特殊召唤目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
