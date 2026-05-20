--No－P.U.N.K.ライジング・スケール
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把这张卡以外的1张「朋克」卡除外才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合，支付600基本分才能发动。从自己的卡组·墓地选8星怪兽以外的1只「朋克」怪兽加入手卡或特殊召唤。
-- ③：对方场上的攻击力2500以上的怪兽把效果发动时才能发动。那只怪兽变成里侧守备表示。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手卡特召）、②效果（特召成功时检索/特召朋克怪兽）、③效果（对方大怪发动效果时变里侧）。
function s.initial_effect(c)
	-- ①：从自己的手卡·墓地把这张卡以外的1张「朋克」卡除外才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合，支付600基本分才能发动。从自己的卡组·墓地选8星怪兽以外的1只「朋克」怪兽加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡或者特殊召唤"
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH|CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES|CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：对方场上的攻击力2500以上的怪兽把效果发动时才能发动。那只怪兽变成里侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"改变表示形式"
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.poscon)
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己手卡·墓地中除这张卡以外的「朋克」卡，且可以作为cost除外。
function s.rfilter(c)
	return c:IsSetCard(0x171) and c:IsAbleToRemoveAsCost()
end
-- ①效果的发动代价：从手卡·墓地将1张除自身以外的「朋克」卡除外。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler();
	-- 检查手卡或墓地是否存在至少1张除自身以外的、可除外的「朋克」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡或墓地选择1张除自身以外的「朋克」卡。
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,c)
	-- 将选中的卡表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域，且这张卡是否可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的处理信息为特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的效果处理：将这张卡从手卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动代价：支付600基本分。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付600基本分。
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 扣除玩家600基本分。
	Duel.PayLPCost(tp,600)
end
-- 过滤条件：卡组·墓地中8星以外的「朋克」怪兽，且可以加入手卡或特殊召唤。
function s.thfilter(c,e,tp)
	if not (c:IsSetCard(0x171) and c:IsType(TYPE_MONSTER) and not c:IsLevel(8)) then return false end
	-- 获取自己场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ②效果的发动准备：检查是否存在符合条件的怪兽，并设置特殊召唤的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地是否存在至少1只8星以外的、可加入手卡或特殊召唤的「朋克」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方玩家提示当前发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置当前连锁的处理信息为从卡组或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果的效果处理：从卡组·墓地选1只8星以外的「朋克」怪兽加入手卡或特殊召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组或墓地（受王家长眠之谷影响）选择1只符合条件的「朋克」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 重新获取自己场上可用的怪兽区域数量，用于判断是否能特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否只能加入手卡，或者在可以特殊召唤的情况下让玩家选择加入手卡（选项0）还是特殊召唤（选项1）。
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的怪兽加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的怪兽表侧表示特殊召唤。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ③效果的发动条件：对方场上攻击力2500以上的怪兽在场上发动效果时。
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发效果的连锁信息，包括发动玩家、发动位置以及该怪兽的攻击力。
	local p,loc,atk=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_ATTACK)
	local rc=re:GetHandler()
	return p==1-tp and (LOCATION_ONFIELD)&loc~=0 and re:IsActiveType(TYPE_MONSTER) and atk>=2500
		and rc:IsRelateToEffect(re)
end
-- ③效果的发动准备：检查发动效果的怪兽是否能变成里侧守备表示，并设置表示形式改变的操作信息。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return rc:IsCanTurnSet() end
	-- 向对方玩家提示当前发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置当前连锁的处理信息为改变对应怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,1,0,0)
end
-- ③效果的效果处理：将发动效果的那只怪兽变成里侧守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc:IsLocation(LOCATION_MZONE) and rc:IsFaceup() then
		-- 将发动效果的怪兽改变为里侧守备表示。
		Duel.ChangePosition(rc,POS_FACEDOWN_DEFENSE)
	end
end
