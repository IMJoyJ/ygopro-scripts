--真竜皇アグニマズドV
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。这张卡以外的自己的手卡·场上（表侧表示）的包含炎属性怪兽的2只怪兽破坏，这张卡特殊召唤，把2只炎属性怪兽破坏的场合，可以从对方的场上·墓地把1只怪兽除外。
-- ②：这张卡被效果破坏的场合才能发动。从自己墓地把1只炎属性以外的幻龙族怪兽加入手卡。
function c96746083.initial_effect(c)
	-- ①：这张卡在手卡存在的场合才能发动。这张卡以外的自己的手卡·场上（表侧表示）的包含炎属性怪兽的2只怪兽破坏，这张卡特殊召唤，把2只炎属性怪兽破坏的场合，可以从对方的场上·墓地把1只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,96746083)
	e1:SetTarget(c96746083.sptg)
	e1:SetOperation(c96746083.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果破坏的场合才能发动。从自己墓地把1只炎属性以外的幻龙族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,96746084)
	e2:SetCondition(c96746083.thcon)
	e2:SetTarget(c96746083.thtg)
	e2:SetOperation(c96746083.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：手卡中的怪兽，或者场上表侧表示的怪兽
function c96746083.desfilter(c)
	return c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 过滤函数：自己主要怪兽区域表侧表示的怪兽
function c96746083.desfilter2(c)
	return c:IsFaceup() and c:GetSequence()<5
end
-- 过滤函数：自己主要怪兽区域的怪兽
function c96746083.mzfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
-- ①号效果的靶指向/发动准备函数：检查手卡中这张卡是否能特殊召唤，以及是否存在可破坏的满足条件的怪兽
function c96746083.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=nil
	if ft>-1 then
		local loc=0
		-- 若受到特定卡片效果影响，则允许将对方场上的怪兽作为破坏代替
		if Duel.IsPlayerAffectedByEffect(tp,88581108) then loc=LOCATION_MZONE end
		-- 获取自己手卡和场上可破坏的怪兽卡组
		g=Duel.GetMatchingGroup(c96746083.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,loc,c)
	else
		-- 若怪兽区域已满，则只能选择自己主要怪兽区域的怪兽作为破坏对象
		g=Duel.GetMatchingGroup(c96746083.desfilter2,tp,LOCATION_MZONE,0,c)
	end
	if chk==0 then return ft>-2 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:GetCount()>=2 and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE)
		and (ft~=0 or g:IsExists(c96746083.mzfilter,1,nil,tp)) end
	-- 设置当前处理的连锁的操作信息：破坏2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,LOCATION_MZONE)
	-- 设置当前处理的连锁的操作信息：特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤函数：墓地或场上可以被除外的怪兽
function c96746083.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- ①号效果的执行函数：执行破坏、特殊召唤以及后续的除外效果
function c96746083.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=nil
	if ft>-1 then
		local loc=0
		-- 若受到特定卡片效果影响，则允许将对方场上的怪兽作为破坏代替
		if Duel.IsPlayerAffectedByEffect(tp,88581108) then loc=LOCATION_MZONE end
		-- 获取自己手卡和场上可破坏的怪兽卡组
		g=Duel.GetMatchingGroup(c96746083.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,loc,c)
	else
		-- 若怪兽区域已满，则只能选择自己主要怪兽区域的怪兽作为破坏对象
		g=Duel.GetMatchingGroup(c96746083.desfilter2,tp,LOCATION_MZONE,0,c)
	end
	if g:GetCount()<2 or not g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE) then return end
	local g1=nil
	-- 提示玩家选择第1张要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	if ft==0 then
		g1=g:FilterSelect(tp,c96746083.mzfilter,1,1,nil,tp)
	else
		g1=g:Select(tp,1,1,nil)
	end
	-- 提示玩家选择第2张要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	if g1:GetFirst():IsAttribute(ATTRIBUTE_FIRE) then
		local g2=g:Select(tp,1,1,g1:GetFirst())
		g1:Merge(g2)
	else
		local g2=g:FilterSelect(tp,Card.IsAttribute,1,1,g1:GetFirst(),ATTRIBUTE_FIRE)
		g1:Merge(g2)
	end
	local rm=g1:IsExists(Card.IsAttribute,2,nil,ATTRIBUTE_FIRE)
	-- 若成功破坏了2张卡
	if Duel.Destroy(g1,REASON_EFFECT)==2 then
		if not c:IsRelateToEffect(e) then return end
		-- 若特殊召唤成功
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then
			return
		end
		-- 获取对方场上和墓地可以被除外的怪兽卡组
		local rg=Duel.GetMatchingGroup(c96746083.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil)
		-- 若破坏的2只怪兽都是炎属性，且对方场上或墓地有可除外的怪兽，询问玩家是否发动除外效果
		if rm and rg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(96746083,0)) then  --"是否选怪兽除外？"
			-- 提示玩家选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local tg=rg:Select(tp,1,1,nil)
			-- 为选中的除外目标卡片显示被选为对象的动画效果
			Duel.HintSelection(tg)
			-- 将选中的怪兽表侧表示除外
			Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- ②号效果的发动条件：这张卡被效果破坏的场合
function c96746083.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数：自己墓地中炎属性以外的幻龙族怪兽
function c96746083.thfilter(c)
	return c:IsNonAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WYRM) and c:IsAbleToHand()
end
-- ②号效果的靶指向/发动准备函数：检查自己墓地是否存在炎属性以外的幻龙族怪兽并设置操作信息
function c96746083.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96746083.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置当前处理的连锁的操作信息：将1张卡从墓地加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ②号效果的执行函数：从墓地将1只炎属性以外的幻龙族怪兽加入手卡
function c96746083.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c96746083.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
