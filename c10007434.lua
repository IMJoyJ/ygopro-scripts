--セネトの啓示者－アメンホテプ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，把这张卡送去墓地才能发动。选自己的手卡·卡组·场上（表侧表示）·墓地最多2张通常怪兽卡，给双方确认。那之后，那个数量的「塞尼特」陷阱卡从卡组到自己场上盖放。
-- ②：把墓地的这张卡除外，以自己墓地最多3只通常怪兽为对象才能发动。那些怪兽回到卡组。
local s,id,o=GetID()
-- 初始化卡片效果，注册效果①（召唤·特殊召唤时送墓从卡组盖放）与效果②（墓地起动除外回收怪兽）
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的场合，把这张卡送去墓地才能发动。选自己的手卡·卡组·场上（表侧表示）·墓地最多2张通常怪兽卡，给双方确认。那之后，那个数量的「塞尼特」陷阱卡从卡组到自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己墓地最多3只通常怪兽为对象才能发动。那些怪兽回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回收"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	-- 效果②发动Cost：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 效果①发动Cost：把场上的这张卡送去墓地
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把这张卡送去墓地作为Cost
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：手卡·卡组·墓地或场上表侧表示的通常怪兽卡
function s.chkfilter(c)
	return c:IsFaceupEx() and c:IsAllCardTypes(TYPE_NORMAL+TYPE_MONSTER)
end
-- 过滤条件：「塞尼特」陷阱卡且可以盖放
function s.setfilter(c)
	return c:IsSetCard(0x1eb) and c:IsSSetable() and c:IsType(TYPE_TRAP)
end
-- 效果①发动条件判断：检查是否存在通常怪兽卡以及卡组是否存在可盖放的「塞尼特」陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡·卡组·场上·墓地是否存在至少1张通常怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_DECK,0,1,nil)
		-- 检查卡组是否存在至少1张可以盖放的「塞尼特」陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 组检查条件：所选卡片数量不超过空置的魔法与陷阱区域数量
function s.gcheck(g,ft)
	return g:GetCount()<=ft
end
-- 效果①处理：确认最多2张通常怪兽卡，并从卡组盖放对应数量的「塞尼特」陷阱卡
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上可用的魔法与陷阱区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	if ft>=2 then ft=2 end
	-- 获取卡组中所有可以盖放的「塞尼特」陷阱卡
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	-- 获取手卡·墓地·场上·卡组中所有符合条件的通常怪兽卡
	local cg=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_DECK,0,nil)
	local ct=math.min(ft,g:GetCount(),cg:GetCount())
	if ct==0 then return end
	-- 提示玩家选择给双方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local rg=cg:Select(tp,1,ct,nil)
	if rg:GetCount()>0 then
		local hg=rg:Filter(Card.IsLocation,nil,LOCATION_HAND+LOCATION_DECK)
		local og=rg-hg
		-- 向对方玩家展示确认选中的手卡与卡组中的卡
		Duel.ConfirmCards(1-tp,hg)
		-- 为场上或墓地选中的卡显示被选择的动画提示
		Duel.HintSelection(og)
		if hg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)>0 then
			-- 洗切己方手牌
			Duel.ShuffleHand(tp)
		end
		if g:GetCount()>0 then
			-- 提示玩家选择要盖放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:SelectSubGroup(tp,s.gcheck,false,rg:GetCount(),rg:GetCount(),ft)
			if sg:GetCount()>0 then
				-- 将选中的「塞尼特」陷阱卡盖放到自己场上
				Duel.SSet(tp,sg)
			end
		end
	end
end
-- 过滤条件：墓地中可以回到卡组的通常怪兽
function s.tdfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToDeck()
end
-- 效果②目标选择及操作信息设置：以自己墓地最多3只通常怪兽为对象
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查自己墓地是否存在可以回到卡组的通常怪兽作为发动对象
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的怪兽作为对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1到3只通常怪兽作为对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设置操作信息：将选中的对象怪兽回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果②处理：将作为对象的墓地通常怪兽返回卡组并洗切
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与该连锁相关且不受王家长眠之谷影响的对象卡片组
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(aux.TRUE),nil)
	if g:GetCount()>0 then
		-- 将目标怪兽返回持有者卡组并洗切
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
