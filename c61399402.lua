--ライトドラゴン＠イグニスター
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。选最多有自己场上的「@火灵天星」怪兽数量的对方场上的表侧表示怪兽破坏。
-- ②：这张卡以外的自己的电子界族怪兽给与对方战斗伤害时才能发动。从自己墓地选1只连接怪兽特殊召唤。
-- ③：自己场上的怪兽被效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
function c61399402.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。选最多有自己场上的「@火灵天星」怪兽数量的对方场上的表侧表示怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61399402,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,61399402)
	e1:SetCost(c61399402.descost)
	e1:SetTarget(c61399402.destg)
	e1:SetOperation(c61399402.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡以外的自己的电子界族怪兽给与对方战斗伤害时才能发动。从自己墓地选1只连接怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61399402,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,61399403)
	e2:SetCondition(c61399402.spcon)
	e2:SetTarget(c61399402.sptg)
	e2:SetOperation(c61399402.spop)
	c:RegisterEffect(e2)
	-- ③：自己场上的怪兽被效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c61399402.reptg)
	e3:SetValue(c61399402.repval)
	c:RegisterEffect(e3)
end
-- 效果①的Cost：检查并取除这张卡的1个超量素材
function c61399402.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：自己场上表侧表示的「@火灵天星」怪兽
function c61399402.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x135)
end
-- 效果①的Target：检查自己场上是否存在「@火灵天星」怪兽以及对方场上是否存在表侧表示怪兽，并设置破坏操作信息
function c61399402.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的「@火灵天星」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c61399402.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且对方场上是否存在至少1只表侧表示怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示怪兽的卡片组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏操作信息，预计破坏对方场上的表侧表示怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的Operation：计算自己场上「@火灵天星」怪兽数量，选择对应数量的对方场上表侧表示怪兽破坏
function c61399402.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上表侧表示的「@火灵天星」怪兽数量
	local ct=Duel.GetMatchingGroupCount(c61399402.cfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择最多等同于「@火灵天星」怪兽数量的对方场上的表侧表示怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,ct,nil)
	if g:GetCount()>0 then
		-- 选中卡片并显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 破坏选中的怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 效果②的Condition：造成战斗伤害的怪兽是自己场上除这张卡以外的电子界族怪兽
function c61399402.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsControler(tp) and tc:IsRace(RACE_CYBERSE) and tc~=e:GetHandler()
end
-- 过滤条件：自己墓地可以特殊召唤的连接怪兽
function c61399402.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的Target：检查怪兽区域空位及墓地是否存在可特召的连接怪兽，并设置特殊召唤操作信息
function c61399402.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在至少1只可以特殊召唤的连接怪兽
		and Duel.IsExistingMatchingCard(c61399402.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息，预计从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的Operation：从自己墓地选择1只连接怪兽特殊召唤
function c61399402.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从墓地选择1只满足条件的连接怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c61399402.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 代替破坏过滤条件：自己场上因效果而被破坏的表侧表示怪兽
function c61399402.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 效果③的Target：检查是否有满足代替破坏条件的怪兽，并确认是否可以取除超量素材
function c61399402.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c61399402.repfilter,1,nil,tp)
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	end
	return false
end
-- 效果③的Value：确定需要代替破坏的怪兽是否符合过滤条件
function c61399402.repval(e,c)
	return c61399402.repfilter(c,e:GetHandlerPlayer())
end
