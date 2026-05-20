--神羊樹バロメット
-- 效果：
-- 4星怪兽×2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除，以自己墓地1张通常陷阱卡为对象才能发动。那张卡回到卡组最下面。那之后，自己抽1张。
-- ②：通常陷阱卡发动的场合才能发动。自己场上1个超量素材取除，从手卡把1只4星怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果：添加XYZ召唤手续，并注册效果①（起动效果，回收墓地通常陷阱并抽卡）和效果②（诱发效果，通常陷阱卡发动时去除素材特召手卡4星怪兽）
function s.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽2只以上（最多99只）
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以自己墓地1张通常陷阱卡为对象才能发动。那张卡回到卡组最下面。那之后，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.tdcost)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- ②：通常陷阱卡发动的场合才能发动。自己场上1个超量素材取除，从手卡把1只4星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的代价：检查并去除这张卡的1个超量素材
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的过滤函数：自己墓地可以回到卡组的陷阱卡
function s.tdfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsAbleToDeck()
end
-- 效果①的发动准备：检查是否能抽卡、墓地是否存在可回收的陷阱卡，并进行取对象和设置操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查自己墓地是否存在至少1张满足过滤条件的陷阱卡
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1张满足条件的陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的效果处理：将对象卡送回卡组最下方，成功后自己抽1张卡
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选中的对象卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与效果相关，并将其送回持有者卡组最下方，确认成功返回
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
		-- 中断当前效果处理，使后续的抽卡处理与返回卡组不视为同时进行
		Duel.BreakEffect()
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 效果②的发动条件：通常陷阱卡发动时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetActiveType()==TYPE_TRAP
end
-- 效果②的特召过滤函数：手卡中可以特殊召唤的4星怪兽
function s.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查自己场上是否有超量素材可去除、怪兽区域是否有空位、手卡是否有可特召的4星怪兽，并设置特召的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能去除至少1个超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT)
		-- 检查自己场上的主要怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足特召条件的4星怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的效果处理：去除自己场上1个超量素材，并从手卡特殊召唤1只4星怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 去除自己场上1个超量素材，并确认去除成功
	if Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)>0
		-- 再次确认自己场上的主要怪兽区域有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡选择1只满足条件的4星怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
