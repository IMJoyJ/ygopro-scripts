--夢幻転星イドリース
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的连接怪兽的连接标记合计是8以上的场合才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
-- ②：对方场上的连接怪兽数量比自己场上的连接怪兽多的状态，这张卡特殊召唤成功的场合才能发动。场上的连接怪兽全部送去墓地。
-- ③：自己场上的9星怪兽不会被效果破坏。
function c9794980.initial_effect(c)
	-- ①：场上的连接怪兽的连接标记合计是8以上的场合才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9794980,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,9794980)
	e1:SetCondition(c9794980.spcon)
	e1:SetTarget(c9794980.sptg)
	e1:SetOperation(c9794980.spop)
	c:RegisterEffect(e1)
	-- ②：对方场上的连接怪兽数量比自己场上的连接怪兽多的状态，这张卡特殊召唤成功的场合才能发动。场上的连接怪兽全部送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9794980,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,9794981)
	e2:SetCondition(c9794980.descon)
	e2:SetTarget(c9794980.destg)
	e2:SetOperation(c9794980.desop)
	c:RegisterEffect(e2)
	-- ③：自己场上的9星怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c9794980.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的连接怪兽
function c9794980.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 效果①的发动条件：检查场上连接怪兽的连接标记合计是否在8以上
function c9794980.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有的表侧表示连接怪兽
	local g=Duel.GetMatchingGroup(c9794980.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	return #g>0 and g:GetSum(Card.GetLink)>=8
end
-- 效果①的发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c9794980.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将这张卡从手卡特殊召唤
function c9794980.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：检查对方场上的连接怪兽数量是否比自己场上的连接怪兽多
function c9794980.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的表侧表示连接怪兽
	local g1=Duel.GetMatchingGroup(c9794980.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取对方场上的表侧表示连接怪兽
	local g2=Duel.GetMatchingGroup(c9794980.cfilter,tp,0,LOCATION_MZONE,nil)
	return #g2>#g1
end
-- 效果②的发动准备：检查场上是否存在连接怪兽，并设置送去墓地的操作信息
function c9794980.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上的表侧表示连接怪兽
	local g=Duel.GetMatchingGroup(c9794980.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 设置将场上所有连接怪兽送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
-- 效果②的效果处理：将场上的连接怪兽全部送去墓地
function c9794980.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方场上的表侧表示连接怪兽
	local g=Duel.GetMatchingGroup(c9794980.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 因效果将这些连接怪兽全部送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
-- 效果③的过滤条件：自己场上的9星怪兽
function c9794980.indtg(e,c)
	return c:IsLevel(9)
end
