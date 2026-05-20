--刻まれし魔ディエスイレ
-- 效果：
-- 「刻印群魔的刻魔锻冶师」＋恶魔族·光属性怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合可以发动。选最多有给这张卡装备的连接怪兽的连接标记合计数量的场上的表侧表示卡，那些效果直到回合结束时无效。
-- ②：这张卡被送去墓地的场合，从自己墓地让1只其他的恶魔族·光属性怪兽回到卡组·额外卡组，以场上1张卡为对象才能发动。那张卡送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤手续、①效果（自由时点无效场上卡片）和②效果（送墓时回收墓地怪兽并送墓场上卡片）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为「刻印群魔的刻魔锻冶师」加上2只满足条件的恶魔族·光属性怪兽。
	aux.AddFusionProcCodeFun(c,60764609,s.ffilter,2,true,true)
	-- ①：自己·对方回合可以发动。选最多有给这张卡装备的连接怪兽的连接标记合计数量的场上的表侧表示卡，那些效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"无效效果"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，从自己墓地让1只其他的恶魔族·光属性怪兽回到卡组·额外卡组，以场上1张卡为对象才能发动。那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.tgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤函数：作为融合素材的恶魔族·光属性怪兽。
function s.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FIEND)
end
-- 过滤函数：作为装备卡且表侧表示的连接怪兽。
function s.cfilter(c)
	return c:IsLinkAbove(1) and c:IsFaceup()
end
-- ①效果的发动准备与合法性检查，计算装备的连接怪兽连接标记合计数量，并设置无效效果的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(s.cfilter,nil)
	local ct=g:GetSum(Card.GetLink)
	-- 检查场上是否存在至少1张可以被无效的表侧表示卡，且自身装备的连接怪兽连接标记合计数量大于0。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and ct>0 end
	-- 获取双方场上的所有卡片。
	local tg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 设置连锁处理中的操作信息：无效场上的卡片。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tg,1,0,0)
end
-- ①效果的实际处理，选择并无效场上最多等同于装备连接怪兽连接标记合计数量的表侧表示卡。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(s.cfilter,nil)
	local ct=g:GetSum(Card.GetLink)
	-- 提示玩家选择要无效的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择最多等同于装备连接怪兽连接标记合计数量的场上表侧表示卡。
	local tg=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	if not c:IsRelateToEffect(e) or tg:GetCount()<1 then return end
	-- 遍历所有被选中的卡片。
	for tc in aux.Next(tg) do
		if tc:IsCanBeDisabledByEffect(e,false) then
			-- 使与目标卡片相关的连锁中已发动的效果无效化。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 那些效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 那些效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 那些效果直到回合结束时无效。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
-- 过滤函数：用于作为发动代价回到卡组或额外卡组的、自己墓地的恶魔族·光属性怪兽。
function s.costfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeckOrExtraAsCost()
end
-- ②效果的发动代价处理，从自己墓地选择1只其他的恶魔族·光属性怪兽回到卡组或额外卡组。
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己墓地是否存在除自身以外、满足条件的恶魔族·光属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 提示玩家选择要回到卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家从墓地选择1只其他的恶魔族·光属性怪兽。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,c)
	-- 手动为选中的卡片显示被选为对象的动画效果。
	Duel.HintSelection(g)
	-- 将选中的怪兽作为发动代价回到持有者的卡组或额外卡组并洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- ②效果的目标选择与合法性检查，选择场上1张卡作为对象，并设置送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以送去墓地的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择场上1张可以送去墓地的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁处理中的操作信息：将选中的对象卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ②效果的实际处理，将选中的对象卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
