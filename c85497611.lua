--オッドアイズ・ウィザード・ドラゴン
-- 效果：
-- ①：这张卡在手卡的场合，把自己场上1只暗属性怪兽解放才能发动。从手卡·卡组以及自己场上的表侧表示怪兽之中选1只「异色眼龙」送去墓地，这张卡特殊召唤。
-- ②：这张卡被对方破坏送去墓地的场合才能发动。从自己的卡组·墓地选「异色眼魔导龙」以外的1只「异色眼」怪兽特殊召唤。那之后，可以从卡组把1张「螺旋之强袭炸裂」加入手卡。
function c85497611.initial_effect(c)
	-- ①：这张卡在手卡的场合，把自己场上1只暗属性怪兽解放才能发动。从手卡·卡组以及自己场上的表侧表示怪兽之中选1只「异色眼龙」送去墓地，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85497611,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c85497611.spcost)
	e1:SetTarget(c85497611.sptg)
	e1:SetOperation(c85497611.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏送去墓地的场合才能发动。从自己的卡组·墓地选「异色眼魔导龙」以外的1只「异色眼」怪兽特殊召唤。那之后，可以从卡组把1张「螺旋之强袭炸裂」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85497611,1))  --"特殊召唤并检索"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCost(c85497611.thcon)
	e2:SetTarget(c85497611.thtg)
	e2:SetOperation(c85497611.thop)
	c:RegisterEffect(e2)
end
-- 过滤自身场上可解放的暗属性怪兽，且该怪兽解放后必须存在可送去墓地的「异色眼龙」以及可用的怪兽区域
function c85497611.cfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK)
		-- 检查手卡、卡组、场上是否存在至少1张满足送墓和特召空间条件的「异色眼龙」（排除当前作为解放候选的怪兽）
		and Duel.IsExistingMatchingCard(c85497611.filter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,1,c,tp,c)
end
-- 过滤手卡、卡组或场上表侧表示的「异色眼龙」，并检查将其送去墓地后是否有足够的怪兽区域用于特殊召唤
function c85497611.filter1(c,tp,mc)
	local g=Group.FromCards(c)
	if mc then g:AddCard(mc) end
	-- 检查卡片是否在手卡·卡组或者是场上表侧表示、卡名是否为「异色眼龙」、是否能送去墓地，且在解放怪兽和该卡送墓后，自己场上是否有可用的怪兽区域
	return (c:IsLocation(LOCATION_HAND+LOCATION_DECK) or c:IsFaceup()) and c:IsCode(53025096) and c:IsAbleToGrave() and Duel.GetMZoneCount(tp,g)>0
end
-- 效果①的启动费用（Cost）处理函数：解放自己场上1只暗属性怪兽
function c85497611.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查自己场上是否存在至少1只满足条件的暗属性怪兽可以解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,c85497611.cfilter,1,nil,tp) end
	-- 玩家选择1只满足条件的暗属性怪兽
	local g=Duel.SelectReleaseGroup(tp,c85497611.cfilter,1,1,nil,tp)
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 效果①的发动准备（Target）处理函数
function c85497611.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：预计将手卡、卡组或场上的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK)
	-- 设置操作信息：预计将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（Operation）函数
function c85497611.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手卡、卡组或场上的表侧表示怪兽中选择1只「异色眼龙」
	local g=Duel.SelectMatchingCard(tp,c85497611.filter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,1,1,nil,tp)
	-- 成功将选中的「异色眼龙」送去墓地，且这张卡在场上（手卡）仍与效果相关联
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：这张卡在自己的控制下被对方破坏并送去墓地
function c85497611.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY) and rp==1-tp
end
-- 过滤卡组或墓地中除「异色眼魔导龙」以外的「异色眼」怪兽
function c85497611.spfilter(c,e,tp)
	return c:IsSetCard(0x99) and not c:IsCode(85497611) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（Target）处理函数
function c85497611.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检查卡组或墓地中是否存在至少1只满足特殊召唤条件的「异色眼」怪兽
		and Duel.IsExistingMatchingCard(c85497611.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：预计从卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	-- 设置操作信息：预计从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤卡组中的「螺旋之强袭炸裂」且能加入手卡
function c85497611.thfilter(c)
	return c:IsCode(82768499) and c:IsAbleToHand()
end
-- 效果②的效果处理（Operation）函数
function c85497611.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从卡组或墓地选择1只「异色眼魔导龙」以外的「异色眼」怪兽（受王家长眠之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c85497611.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 成功将选中的怪兽特殊召唤
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
			-- 且检查卡组中是否存在「螺旋之强袭炸裂」
			and Duel.IsExistingMatchingCard(c85497611.thfilter,tp,LOCATION_DECK,0,1,nil)
			-- 且玩家选择“是”（将「螺旋之强袭炸裂」加入手卡）
			and Duel.SelectYesNo(tp,aux.Stringid(85497611,2)) then  --"是否把「螺旋之强袭炸裂」加入手卡？"
			-- 中断当前效果处理，使后续的检索处理不与特殊召唤同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 玩家从卡组选择1张「螺旋之强袭炸裂」
			local tg=Duel.SelectMatchingCard(tp,c85497611.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选中的卡加入手卡
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
