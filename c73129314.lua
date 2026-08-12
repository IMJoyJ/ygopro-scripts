--魂宿りし暗黒騎士ガイア
-- 效果：
-- 这个卡名在规则上也当作「千年」卡使用。这个卡名的③的效果1回合只能使用1次。
-- ①：场上有5星以上的怪兽卡存在的场合，这张卡可以不用解放作召唤。
-- ②：只要这张卡在怪兽区域存在，那个期间对方攻击表示召唤·特殊召唤的怪兽的等级上升7星。
-- ③：对方把怪兽的效果发动时，把除这张卡外的自己场上1张5星以上的表侧表示的怪兽卡送去墓地才能发动。那个发动无效并破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册不用解放召唤的效果、对方召唤·特殊召唤怪兽等级上升的效果，以及无效对方怪兽效果发动并破坏的效果
function s.initial_effect(c)
	-- ①：场上有5星以上的怪兽卡存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放召唤（宿魂的暗黑骑士 盖亚）"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，那个期间对方攻击表示召唤·特殊召唤的怪兽的等级上升7星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.lvcon)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：对方把怪兽的效果发动时，把除这张卡外的自己场上1张5星以上的表侧表示的怪兽卡送去墓地才能发动。那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"发动无效"
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.negcon)
	e4:SetCost(s.negcost)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
-- 过滤场上表侧表示的原本等级在5星以上的怪兽卡（包含在魔陷区表侧表示存在的怪兽卡）
function s.cfilter(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER
		and (c:IsLevelAbove(5) and c:IsLocation(LOCATION_MZONE)
		or c:GetOriginalLevel()>4 and not c:IsLocation(LOCATION_MZONE))
end
-- 检查是否满足不用解放召唤的条件（场上存在5星以上的怪兽卡且有可用的怪兽区域）
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查解放怪兽数量是否为0、自身是否为5星以上怪兽，以及自己场上是否有可用的怪兽区域
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查双方场上是否存在至少1张表侧表示的5星以上的怪兽卡
		and Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 过滤由对方玩家表侧攻击表示召唤·特殊召唤到场上的等级1以上的怪兽
function s.lvcfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsLevelAbove(1) and c:IsPosition(POS_FACEUP_ATTACK) and c:IsLocation(LOCATION_MZONE)
end
-- 检查召唤·特殊召唤的怪兽中是否存在对方表侧攻击表示召唤的怪兽，且不包含这张卡自身
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.lvcfilter,1,nil,1-tp) and not eg:IsContains(e:GetHandler())
end
-- 对方攻击表示召唤·特殊召唤成功时，使这些怪兽的等级上升7星
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.lvcfilter,nil,1-tp)
	if g:GetCount()>0 then
		-- 提示发动该卡的效果（显示卡片发动动画）
		Duel.Hint(HINT_CARD,0,id)
		-- 遍历所有满足条件的对方召唤·特殊召唤的怪兽
		for tc in aux.Next(g) do
			-- 等级上升7星。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(7)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
-- 检查是否满足无效效果的发动条件（对方发动怪兽效果且该发动可以被无效）
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动的效果是否为怪兽效果、是否由对方发动，以及该发动是否可以被无效
	return re:IsActiveType(TYPE_MONSTER) and rp==1-tp and Duel.IsChainNegatable(ev)
end
-- 过滤除这张卡以外的、自己场上表侧表示且可以送去墓地的5星以上的怪兽卡
function s.costfilter(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER
		and (c:IsLevelAbove(5) and c:IsLocation(LOCATION_MZONE)
		or c:GetOriginalLevel()>4 and not c:IsLocation(LOCATION_MZONE))
		and c:IsAbleToGraveAsCost()
end
-- 支付发动代价：将除这张卡外的自己场上1张5星以上的表侧表示的怪兽卡送去墓地
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除这张卡以外的、可以送去墓地的5星以上的表侧表示的怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1张满足条件的5星以上表侧表示的怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 将选择的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 确认效果发动的有效性，并设置无效与破坏的操作信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置在效果处理时将使该发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置在效果处理时将破坏该卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理：使对方怪兽效果的发动无效并破坏
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使该发动无效，并检查该卡是否仍与该效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动被无效的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
