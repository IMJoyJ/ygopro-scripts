--海竜神の大渦
local s,id,o=GetID()
-- 初始化卡片效果：注册记述卡片、召唤/特召无效并破坏与追加清场效果、以及墓地除外送墓对方怪兽效果
function s.initial_effect(c)
	-- 注册卡片记述列表：记述「海龙神」与「海」
	aux.AddCodeList(c,38391684,22702055)
	-- 自己场上有「海龙神」存在的场合，对方把怪兽召唤·特殊召唤之际才能发动。那个召唤·特殊召唤无效，那些怪兽破坏。那之后，自己场上有水属性连接怪兽存在的场合，可以把水属性以外的怪兽以及里侧表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.nscon)
	e1:SetTarget(s.nstg)
	e1:SetOperation(s.nsop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e2)
	-- 把墓地的这张卡除外，把自己场上1张表侧表示的「海」送去墓地，以对方场上1只怪兽为对象才能发动。那只怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.tgcost)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 发动条件过滤：自己场上表侧表示存在的「海龙神」
function s.nsfilter(c)
	return c:IsFaceup() and c:IsCode(38391684)
end
-- 召唤/特召无效发动条件：对方进行召唤/特召、不在连锁中且自己场上存在「海龙神」
function s.nscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方召唤/特召、当前连锁数为0且自己场上有表侧表示的「海龙神」
	return tp~=ep and Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 召唤/特召无效发动准备：设置无效召唤及破坏卡片的操作信息
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：无效即将召唤/特召的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置连锁操作信息：破坏即将召唤/特召的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 追加破坏过滤条件：自己场上表侧表示的水属性连接怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_LINK)
end
-- 追加破坏过滤条件：场上的里侧表示怪兽或非水属性怪兽
function s.desfilter(c)
	return c:IsFacedown() or not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 召唤/特召无效效果处理：无效召唤并破坏怪兽，若符合条件可追加破坏所有非水属性及里侧怪兽
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	-- 使即将进行的召唤/特殊召唤无效
	Duel.NegateSummon(eg)
	-- 破坏召唤无效的怪兽，若未成功破坏则终止后续处理
	if Duel.Destroy(eg,REASON_EFFECT)==0 then return end
	-- 检查自己场上是否存在水属性连接怪兽
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查场上是否存在可破坏的非水属性或里侧表示怪兽
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 询问玩家是否追加发动清场破坏效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 连接效果块（分隔召唤无效破坏与追加清场效果）
		Duel.BreakEffect()
		-- 获取场上所有符合条件的非水属性怪兽及里侧表示怪兽
		local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if g:GetCount()>0 then
			-- 破坏选中的所有非水属性及里侧表示怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- Cost过滤条件：自己场上表侧表示的「海」
function s.costfilter(c)
	return c:IsCode(22702055) and c:IsAbleToGraveAsCost() and c:IsFaceup()
end
-- 墓地效果Cost：将自身从墓地除外，并将自己场上1张表侧表示的「海」送去墓地
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：自身可从墓地除外且场上存在可送去墓地的「海」
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 将墓地的此卡除外
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择1张表侧表示的「海」
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 将选中的卡作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 重检取对象条件：必须为对方怪兽区域可送去墓地的怪兽
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsAbleToGrave() end
	-- 发动条件检查：对方怪兽区域是否存在可送去墓地的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方怪兽区域1只怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：将对象怪兽1只送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 墓地效果处理：将选中的对方对象怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 将对象怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
