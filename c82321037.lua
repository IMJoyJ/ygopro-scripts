--真竜皇バハルストスF
-- 效果：
-- 「真龙皇 巴哈斯督·统领」的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从这张卡以外的手卡以及自己场上的表侧表示怪兽之中把包含水属性怪兽的2只怪兽破坏，这张卡从手卡特殊召唤，把2只水属性怪兽破坏的场合，可以从对方的场上·墓地选最多2张魔法·陷阱卡除外。
-- ②：这张卡被效果破坏的场合才能发动。从卡组把1只水属性以外的幻龙族怪兽守备表示特殊召唤。
function c82321037.initial_effect(c)
	-- ①：自己主要阶段才能发动。从这张卡以外的手卡以及自己场上的表侧表示怪兽之中把包含水属性怪兽的2只怪兽破坏，这张卡从手卡特殊召唤，把2只水属性怪兽破坏的场合，可以从对方的场上·墓地选最多2张魔法·陷阱卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,82321037)
	e1:SetTarget(c82321037.sptg)
	e1:SetOperation(c82321037.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果破坏的场合才能发动。从卡组把1只水属性以外的幻龙族怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,82321038)
	e2:SetCondition(c82321037.spcon2)
	e2:SetTarget(c82321037.sptg2)
	e2:SetOperation(c82321037.spop2)
	c:RegisterEffect(e2)
end
-- 过滤可以被破坏的卡：手牌中的怪兽，或者自己场上表侧表示的怪兽
function c82321037.desfilter(c)
	return c:IsType(TYPE_MONSTER) and ((c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) or c:IsLocation(LOCATION_HAND))
end
-- 过滤自己场上的怪兽，用于在怪兽区域没有空位时，强制选择自己场上的怪兽进行破坏
function c82321037.locfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 效果①的发动准备与可行性检测，判断是否能特殊召唤自身，且手牌和场上是否存在满足破坏条件的卡
function c82321037.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取玩家怪兽区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local loc=LOCATION_MZONE+LOCATION_HAND
	if ft<0 then loc=LOCATION_MZONE end
	local loc2=0
	-- 检测玩家是否受到「真龙皇的复活」等卡片效果影响，若受到影响则可以将对方场上的怪兽也作为破坏候选
	if Duel.IsPlayerAffectedByEffect(tp,88581108) then loc2=LOCATION_MZONE end
	-- 获取所有可以作为破坏候选的怪兽组（排除自身）
	local g=Duel.GetMatchingGroup(c82321037.desfilter,tp,loc,loc2,c)
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:GetCount()>=2 and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER)
		and (ft>0 or g:IsExists(c82321037.locfilter,-ft+1,nil,tp)) end
	-- 设置连锁信息，表示此效果包含破坏2张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,loc)
	-- 设置连锁信息，表示此效果包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤对方场上或墓地可以被除外的魔法·陷阱卡
function c82321037.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 效果①的处理：选择并破坏包含水属性怪兽的2只怪兽，特殊召唤自身；若破坏了2只水属性怪兽，则可以选对方场上·墓地最多2张魔陷除外
function c82321037.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家怪兽区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local loc=LOCATION_MZONE+LOCATION_HAND
	if ft<0 then loc=LOCATION_MZONE end
	local loc2=0
	-- 检测玩家是否受到「真龙皇的复活」等卡片效果影响，若受到影响则可以将对方场上的怪兽也作为破坏候选
	if Duel.IsPlayerAffectedByEffect(tp,88581108) then loc2=LOCATION_MZONE end
	-- 获取所有可以作为破坏候选的怪兽组（排除自身）
	local g=Duel.GetMatchingGroup(c82321037.desfilter,tp,loc,loc2,c)
	if g:GetCount()<2 or not g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER) then return end
	local g1=nil local g2=nil
	-- 提示玩家选择要破坏的第一张卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	if ft<1 then
		g1=g:FilterSelect(tp,c82321037.locfilter,1,1,nil,tp)
	else
		g1=g:Select(tp,1,1,nil)
	end
	g:RemoveCard(g1:GetFirst())
	-- 提示玩家选择要破坏的第二张卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	if g1:GetFirst():IsAttribute(ATTRIBUTE_WATER) then
		g2=g:Select(tp,1,1,nil)
	else
		g2=g:FilterSelect(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_WATER)
	end
	g1:Merge(g2)
	local rm=g1:IsExists(Card.IsAttribute,2,nil,ATTRIBUTE_WATER)
	-- 执行破坏操作，若成功破坏了2张卡则继续处理
	if Duel.Destroy(g1,REASON_EFFECT)==2 then
		if not c:IsRelateToEffect(e) then return end
		-- 将这张卡从手牌特殊召唤，若特殊召唤失败则结束效果处理
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then
			return
		end
		-- 获取对方场上和墓地中可以被除外的魔法·陷阱卡
		local rg=Duel.GetMatchingGroup(c82321037.rmfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
		-- 若破坏的2只怪兽都是水属性，且对方场上或墓地有可除外的魔陷，则询问玩家是否发动除外效果
		if rm and rg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(82321037,0)) then  --"是否选魔法·陷阱卡除外？"
			-- 提示玩家选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local tg=rg:Select(tp,1,2,nil)
			-- 在场上对被选择的卡片进行闪烁提示
			Duel.HintSelection(tg)
			-- 将选中的魔法·陷阱卡除外
			Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 效果②的发动条件：这张卡被效果破坏的场合
function c82321037.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤卡组中水属性以外的幻龙族怪兽，且该怪兽可以守备表示特殊召唤
function c82321037.thfilter(c,e,tp)
	return c:IsNonAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_WYRM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动准备与可行性检测，判断怪兽区域是否有空位，且卡组中是否存在满足条件的怪兽
function c82321037.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在检测阶段，判断怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c82321037.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁信息，表示此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果②的处理：从卡组将1只水属性以外的幻龙族怪兽守备表示特殊召唤
function c82321037.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断怪兽区域是否有空位，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c82321037.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
