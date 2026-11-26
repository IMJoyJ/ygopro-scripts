--No－P.U.N.K.ライジング・スケール
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把这张卡以外的1张「朋克」卡除外才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合，支付600基本分才能发动。从自己的卡组·墓地选8星怪兽以外的1只「朋克」怪兽加入手卡或特殊召唤。
-- ③：对方场上的攻击力2500以上的怪兽把效果发动时才能发动。那只怪兽变成里侧守备表示。
local s,id,o=GetID()
-- 初始化卡片效果，注册①②③三个效果。
function s.initial_effect(c)
	-- 这个卡名的①②③的效果1回合各能使用1次。①：从自己的手卡·墓地把这张卡以外的1张「朋克」卡除外才能发动。这张卡从手卡特殊召唤。
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
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH|CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES|CATEGORY_DECK_SPSUMMON|CATEGORY_GRAVE_SPSUMMON)
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
-- 代价过滤函数：检查卡片是否为可以作为代价除外的「朋克」卡。
function s.rfilter(c)
	return c:IsSetCard(0x171) and c:IsAbleToRemoveAsCost()
end
-- ①效果的发动代价：检查并从自己手卡·墓地选择这张卡以外的1张「朋克」卡表侧除外。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler();
	-- 发动代价检查：确认自己手卡或墓地存在至少1张这张卡以外可除外的「朋克」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c) end
	-- 发送提示信息，引导玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己手卡·墓地选择这张卡以外的1张「朋克」卡。
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,c)
	-- 将所选的「朋克」卡作为发动代价表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的目标处理函数：检查自己怪兽区空位及这张卡的特招条件，并设置特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：确认自己怪兽区至少有1个空位且这张卡可以被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：预计将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理函数：确认这张卡仍与效果保持联系后将其特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动代价：检查并支付600基本分。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检查：确认己方玩家能够支付600基本分。
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 让己方玩家支付600基本分。
	Duel.PayLPCost(tp,600)
end
-- 过滤条件：检查卡片是否为8星以外的「朋克」怪兽，且可加入手卡或在有空位时可特殊召唤。
function s.thfilter(c,e,tp)
	if not (c:IsSetCard(0x171) and c:IsType(TYPE_MONSTER) and not c:IsLevel(8)) then return false end
	-- 获取自己主要怪兽区可用于特殊召唤的空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ②效果的目标处理函数：检查卡组·墓地是否存在符合条件的「朋克」怪兽，提示对方并设置特殊召唤操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己卡组或墓地存在至少1只符合条件的「朋克」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方提示己方选择发动了②效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：预计从自己卡组或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果的处理函数：从卡组·墓地选1只不受王家长眠之谷影响的8星以外「朋克」怪兽，让玩家选择加入手卡或特殊召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送提示信息，引导玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己卡组·墓地选择1只不受王家长眠之谷影响的符合条件「朋克」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 获取自己主要怪兽区可用于特殊召唤的空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 若所选怪兽可加入手卡，且无法特殊召唤、没有怪兽区空位或玩家选择加入手卡时进入加入手卡分支。
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将所选「朋克」怪兽以效果加入自己手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 将加入手卡的「朋克」怪兽展示给对方确认。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将所选「朋克」怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ③效果的发动条件：检查是否为对方场上攻击力2500以上的怪兽发动效果且与该效果保持联系。
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 从触发连锁的信息中获取发动玩家、发动位置和怪兽攻击力。
	local p,loc,atk=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_ATTACK)
	local rc=re:GetHandler()
	return p==1-tp and (LOCATION_ONFIELD)&loc~=0 and re:IsActiveType(TYPE_MONSTER) and atk>=2500
		and rc:IsRelateToEffect(re)
end
-- ③效果的目标处理函数：检查该对方怪兽是否可以变成里侧守备表示，提示对方并设置改变表示形式的操作信息。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return rc:IsCanTurnSet() end
	-- 向对方提示己方选择发动了③效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：预计改变触发效果的怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,1,0,0)
end
-- ③效果的处理函数：确认该怪兽仍在对方怪兽区表侧表示且与效果保持联系，将其变成里侧守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc:IsLocation(LOCATION_MZONE) and rc:IsFaceup() then
		-- 将该对方怪兽变更为里侧守备表示。
		Duel.ChangePosition(rc,POS_FACEDOWN_DEFENSE)
	end
end
