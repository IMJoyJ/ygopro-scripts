--転生炎獣フォクサー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己墓地的「转生炎兽」怪兽是3只以上的场合，把这张卡从手卡送去墓地，以自己墓地1只「转生炎兽」连接怪兽和对方的魔法与陷阱区域1张卡为对象才能发动。作为对象的墓地的怪兽回到额外卡组，作为对象的场上的卡破坏。
-- ②：这张卡在墓地存在，对方的魔法与陷阱区域的卡被破坏送去墓地的场合才能发动。这张卡守备表示特殊召唤。
function c86962245.initial_effect(c)
	-- ①：自己墓地的「转生炎兽」怪兽是3只以上的场合，把这张卡从手卡送去墓地，以自己墓地1只「转生炎兽」连接怪兽和对方的魔法与陷阱区域1张卡为对象才能发动。作为对象的墓地的怪兽回到额外卡组，作为对象的场上的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86962245,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,86962245)
	e1:SetCondition(c86962245.condition)
	e1:SetCost(c86962245.cost)
	e1:SetTarget(c86962245.target)
	e1:SetOperation(c86962245.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，对方的魔法与陷阱区域的卡被破坏送去墓地的场合才能发动。这张卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86962245,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,86962245)
	e2:SetCondition(c86962245.spcon)
	e2:SetTarget(c86962245.sptg)
	e2:SetOperation(c86962245.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地的「转生炎兽」怪兽
function c86962245.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x119)
end
-- ①效果发动条件：自己墓地存在3只以上的「转生炎兽」怪兽
function c86962245.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少3张「转生炎兽」怪兽
	return Duel.IsExistingMatchingCard(c86962245.cfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- ①效果发动代价：把手卡的这张卡送去墓地
function c86962245.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：对方魔法与陷阱区域的卡（不含场地区域）
function c86962245.filter(c)
	return c:GetSequence()<5
end
-- 过滤条件：自己墓地可以回到额外卡组的「转生炎兽」连接怪兽
function c86962245.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x119) and c:IsType(TYPE_LINK) and c:IsAbleToExtra()
end
-- ①效果发动准备：检查并选择自己墓地的1只「转生炎兽」连接怪兽和对方魔陷区的1张卡作为对象
function c86962245.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方魔法与陷阱区域是否存在至少1张可作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(c86962245.filter,tp,0,LOCATION_SZONE,1,nil)
		-- 并且自己墓地是否存在至少1只可作为对象的「转生炎兽」连接怪兽
		and Duel.IsExistingTarget(c86962245.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只「转生炎兽」连接怪兽作为对象
	local lg=Duel.SelectTarget(tp,c86962245.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方魔法与陷阱区域的1张卡作为对象
	local g=Duel.SelectTarget(tp,c86962245.filter,tp,0,LOCATION_SZONE,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	-- 设置破坏对方魔陷区卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,1-tp,LOCATION_SZONE)
	-- 设置将墓地怪兽回到额外卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,lg,1,tp,LOCATION_GRAVE)
end
-- ①效果处理：使作为对象的墓地怪兽回到额外卡组，并破坏作为对象的场上的卡
function c86962245.operation(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	-- 获取当前连锁中被选择为对象的所有卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=g:GetFirst()
	if lc==sc then lc=g:GetNext() end
	-- 检查墓地的对象卡是否仍存在且符合条件，将其送回额外卡组，若成功回到额外卡组且场上的对象卡仍存在，则继续处理
	if lc and lc:IsRelateToEffect(e) and Duel.SendtoDeck(lc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and lc:IsLocation(LOCATION_EXTRA) and sc and sc:IsRelateToEffect(e) then
		-- 破坏作为对象的场上的卡
		Duel.Destroy(sc,REASON_EFFECT)
	end
end
-- 过滤条件：对方魔法与陷阱区域（不含场地区域）被破坏送去墓地的卡
function c86962245.spfilter(c,tp)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_SZONE)
		and c:IsPreviousControler(1-tp) and c:GetPreviousSequence()<5
end
-- ②效果发动条件：对方魔法与陷阱区域的卡被破坏送去墓地的场合
function c86962245.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c86962245.spfilter,1,nil,tp)
end
-- ②效果发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c86962245.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置将墓地的这张卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- ②效果处理：将墓地的这张卡守备表示特殊召唤
function c86962245.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以守备表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
