--エクソシスターズ・マニフィカ
-- 效果：
-- 4阶「救祓少女」超量怪兽×2
-- 这张卡用以上记的卡为超量素材的超量召唤才能特殊召唤。
-- ①：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ②：自己·对方回合1次，把这张卡1个超量素材取除才能发动。对方场上1张卡除外。
-- ③：对方把效果发动时才能发动（同一连锁上最多1次）。给这张卡作为超量素材中的1只自己的超量怪兽回到额外卡组。那之后，可以把那只怪兽在自己场上的这张卡上面重叠当作超量召唤作特殊召唤。
function c59242457.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加无等级限制的超量召唤手续：需要2只满足过滤条件的怪兽作为素材
	aux.AddXyzProcedureLevelFree(c,c59242457.mfilter,nil,2,2)
	-- 这张卡用以上记的卡为超量素材的超量召唤才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制，使其不能通过超量召唤以外的方式特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合1次，把这张卡1个超量素材取除才能发动。对方场上1张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(59242457,0))  --"对方卡片除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(c59242457.rmcost)
	e3:SetTarget(c59242457.rmtg)
	e3:SetOperation(c59242457.rmop)
	c:RegisterEffect(e3)
	-- ③：对方把效果发动时才能发动（同一连锁上最多1次）。给这张卡作为超量素材中的1只自己的超量怪兽回到额外卡组。那之后，可以把那只怪兽在自己场上的这张卡上面重叠当作超量召唤作特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(59242457,1))  --"超量素材回到额外卡组"
	e4:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e4:SetCondition(c59242457.spcon)
	e4:SetTarget(c59242457.sptg)
	e4:SetOperation(c59242457.spop)
	c:RegisterEffect(e4)
end
-- 超量素材过滤条件：4阶「救祓少女」怪兽
function c59242457.mfilter(c)
	return c:IsSetCard(0x172) and c:IsRank(4)
end
-- 效果②的发动代价：取除这张卡的1个超量素材
function c59242457.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动准备：检查对方场上是否存在可除外的卡，并设置除外操作信息
function c59242457.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示已选择发动该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理的操作信息：除外对方场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end
-- 效果②的效果处理：让玩家选择对方场上的1张卡并将其除外
function c59242457.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以除外的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 闪烁显示被选择的卡片
		Duel.HintSelection(sg)
		-- 将选择的卡片表侧表示除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果③的发动条件：对方把效果发动时，且这张卡没有被战斗破坏
function c59242457.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 过滤作为超量素材的、属于自己的、可以回到额外卡组的超量怪兽
function c59242457.toexfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:IsAbleToExtra() and c:GetOwner()==tp
end
-- 效果③的发动准备：检查超量素材中是否存在满足条件的超量怪兽
function c59242457.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	if chk==0 then return g:IsExists(c59242457.toexfilter,1,nil,tp) end
	-- 向对方玩家提示已选择发动该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果③的效果处理：将1只作为超量素材的超量怪兽回到额外卡组，之后可将其在自己场上的这张卡上面重叠当作超量召唤特殊召唤
function c59242457.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	if c:IsRelateToEffect(e) then
		-- 提示玩家选择要返回额外卡组的超量素材
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sc=g:FilterSelect(tp,c59242457.toexfilter,1,1,nil,tp):GetFirst()
		-- 如果成功将选择的超量素材返回到额外卡组
		if sc and Duel.SendtoDeck(sc,nil,0,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_EXTRA)
			and c:IsFaceup() and c:IsControler(tp) and not c:IsImmuneToEffect(e)
			-- 检查这张卡是否必须作为超量素材，以及是否可以作为该超量怪兽的超量素材
			and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) and c:IsCanBeXyzMaterial(sc)
			-- 检查该怪兽是否可以进行超量特殊召唤，且额外怪兽区域或可用怪兽区域有空位
			and sc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
			-- 询问玩家是否选择将那只怪兽特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(59242457,2)) then  --"是否把那只怪兽特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤处理不与返回额外卡组同时进行
			Duel.BreakEffect()
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将这张卡原本持有的其他超量素材转移重叠到新召唤的怪兽下面
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将这张卡自身作为超量素材重叠在新召唤的怪兽下面
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将该怪兽以超量召唤的形式表侧表示特殊召唤
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
