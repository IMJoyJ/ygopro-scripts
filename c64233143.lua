--海竜神の大渦
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「龙都 亚特兰蒂斯」存在，对方把怪兽召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。那之后，自己场上有水属性连接怪兽存在的场合，可以把除水属性怪兽外的场上的怪兽全部破坏。
-- ②：把墓地的这张卡除外，把自己场上1张表侧表示的「海」送去墓地，以对方场上1只怪兽为对象才能发动。那只怪兽送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果：注册记载的卡名，并依次注册①效果（召唤之际与特殊召唤之际发动的无效并破坏效果）和②效果（墓地的诱发即时送墓效果）
function s.initial_effect(c)
	-- 记录这张卡上记载着「龙都 亚特兰蒂斯」（38391684）和「海」（22702055）的卡名
	aux.AddCodeList(c,38391684,22702055)
	-- 这个卡名的①的效果1回合只能有1次使用其中任意1个。①：自己场上有「龙都 亚特兰蒂斯」存在，对方把怪兽召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
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
	-- 这个卡名的②的效果1回合只能有1次使用其中任意1个。②：把墓地的这张卡除外，把自己场上1张表侧表示的「海」送去墓地，以对方场上1只怪兽为对象才能发动。那只怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"送去墓地"
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
-- 过滤函数：判断卡片是否为表侧表示的「龙都 亚特兰蒂斯」
function s.nsfilter(c)
	return c:IsFaceup() and c:IsCode(38391684)
end
-- ①效果的发动条件：对方把怪兽召唤·特殊召唤之际，且自己场上有「龙都 亚特兰蒂斯」存在
function s.nscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是对方进行的召唤·特殊召唤、当前不在连锁处理中，并且自己场上存在表侧表示的「龙都 亚特兰蒂斯」
	return tp~=ep and Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①效果的目标设定：设置无效召唤与破坏的操作信息
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将对方正在召唤·特殊召唤的那些怪兽作为召唤无效的处理对象
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：将对方正在召唤·特殊召唤的那些怪兽作为破坏的处理对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 过滤函数：判断卡片是否为表侧表示的水属性连接怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_LINK)
end
-- 过滤函数：判断卡片是否为水属性以外的怪兽（里侧表示也视为非水属性）
function s.desfilter(c)
	return c:IsFacedown() or not c:IsAttribute(ATTRIBUTE_WATER)
end
-- ①效果的处理：使对方的召唤·特殊召唤无效并破坏那些怪兽，之后自己场上有水属性连接怪兽存在的场合，询问玩家是否把除水属性怪兽外的场上的怪兽全部破坏
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方那些怪兽的召唤·特殊召唤无效
	Duel.NegateSummon(eg)
	-- 把那些召唤被无效的怪兽破坏；若没有破坏成功则中断后续处理
	if Duel.Destroy(eg,REASON_EFFECT)==0 then return end
	-- 检查自己场上是否存在水属性连接怪兽
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查双方场上是否存在除水属性怪兽外的怪兽
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 并且询问玩家「是否把怪兽破坏？」，选择是才执行破坏
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽破坏？"
		-- 中断当前效果处理，使之后的破坏与之前的处理视为不同时进行（错开时点）
		Duel.BreakEffect()
		-- 取得双方场上所有除水属性怪兽外的怪兽
		local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if g:GetCount()>0 then
			-- 把那些除水属性怪兽外的怪兽全部破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 过滤函数：判断卡片是否为表侧表示且能作为代价送去墓地的「海」
function s.costfilter(c)
	return c:IsCode(22702055) and c:IsAbleToGraveAsCost() and c:IsFaceup()
end
-- ②效果的代价处理：把墓地的这张卡除外，并把自己场上1张表侧表示的「海」送去墓地
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：这张卡能否被除外作为代价，且自己场上是否存在可送去墓地的表侧表示的「海」
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 把墓地的这张卡除外作为发动代价
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 提示玩家「请选择要送去墓地的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1张表侧表示的「海」
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 把选择的「海」送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的目标合法性检查：对象须为对方场上能送去墓地的怪兽
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsAbleToGrave() end
	-- 发动前检查：对方场上是否存在可以送去墓地并能成为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家「请选择要送去墓地的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 以对方场上1只能送去墓地的怪兽为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将对象怪兽作为送去墓地的处理对象
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ②效果的处理：取得对象怪兽，若其仍与本连锁相关且为怪兽，则将其送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 把那只对象怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
