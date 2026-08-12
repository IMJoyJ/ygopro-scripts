--天威龍－アシュナ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，把手卡·墓地的这张卡除外才能发动。从卡组把「天威龙-宽恕蟠龙」以外的1只「天威」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是幻龙族怪兽不能特殊召唤。
function c87052196.initial_effect(c)
	-- ①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87052196,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,87052196)
	e1:SetCondition(c87052196.spcon)
	e1:SetTarget(c87052196.sptg)
	e1:SetOperation(c87052196.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，把手卡·墓地的这张卡除外才能发动。从卡组把「天威龙-宽恕蟠龙」以外的1只「天威」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是幻龙族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87052196,1))  --"从卡组特殊召唤「天威」怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,87052197)
	e2:SetCondition(c87052196.spcon2)
	-- 把手卡·墓地的这张卡除外作为发动成本（Cost）
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c87052196.sptg2)
	e2:SetOperation(c87052196.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的效果怪兽
function c87052196.spcfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 效果①的发动条件：自己场上没有表侧表示的效果怪兽存在
function c87052196.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在表侧表示的效果怪兽
	return not Duel.IsExistingMatchingCard(c87052196.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备：检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c87052196.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将自身特殊召唤
function c87052196.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：表侧表示的效果怪兽以外的怪兽
function c87052196.spfilter1(c)
	return not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 效果②的发动条件：自己场上有效果怪兽以外的表侧表示怪兽存在
function c87052196.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在效果怪兽以外的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c87052196.spfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡组中「天威龙-宽恕蟠龙」以外的、可以特殊召唤的「天威」怪兽
function c87052196.filter(c,e,tp)
	return c:IsSetCard(0x12c) and not c:IsCode(87052196) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查怪兽区域空位及卡组中是否存在符合条件的「天威」怪兽，并设置从卡组特殊召唤的操作信息
function c87052196.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合条件的「天威」怪兽
		and Duel.IsExistingMatchingCard(c87052196.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置从卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组特殊召唤1只「天威」怪兽，并适用不能特殊召唤非幻龙族怪兽的限制
function c87052196.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只符合条件的「天威」怪兽
		local g=Duel.SelectMatchingCard(tp,c87052196.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是幻龙族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c87052196.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该不能特殊召唤非幻龙族怪兽的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能特殊召唤幻龙族怪兽（过滤非幻龙族怪兽）
function c87052196.splimit(e,c)
	return not c:IsRace(RACE_WYRM)
end
