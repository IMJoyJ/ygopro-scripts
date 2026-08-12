--聖騎士の追想 イゾルデ
-- 效果：
-- 战士族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1只战士族怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤，那些怪兽效果也不能发动。
-- ②：从卡组把装备魔法卡任意数量送去墓地才能发动（同名卡最多1张）。和送去墓地的卡数量相同等级的1只战士族怪兽从卡组特殊召唤。
function c59934749.initial_effect(c)
	-- 设置连接召唤的手续，需要2只战士族怪兽作为素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从卡组把1只战士族怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤，那些怪兽效果也不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59934749,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,59934749)
	e1:SetCondition(c59934749.thcon)
	e1:SetTarget(c59934749.thtg)
	e1:SetOperation(c59934749.thop)
	c:RegisterEffect(e1)
	-- ②：从卡组把装备魔法卡任意数量送去墓地才能发动（同名卡最多1张）。和送去墓地的卡数量相同等级的1只战士族怪兽从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59934749,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,59934750)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c59934749.spcost)
	e2:SetTarget(c59934749.sptg)
	e2:SetOperation(c59934749.spop)
	c:RegisterEffect(e2)
end
-- 检查此卡是否为连接召唤成功。
function c59934749.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤卡组中可以加入手牌的战士族怪兽。
function c59934749.thfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 效果①的靶向/发动准备函数，检查卡组中是否存在可检索的战士族怪兽，并设置检索的操作信息。
function c59934749.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只可以加入手牌的战士族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c59934749.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示该效果会将卡组的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数，将选定的战士族怪兽加入手牌，并注册该回合内该卡及同名卡的召唤、特殊召唤、效果发动限制。
function c59934749.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的战士族怪兽。
	local g=Duel.SelectMatchingCard(tp,c59934749.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的怪兽加入手牌，并确认其确实已到达手牌。
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 让对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,tc)
		-- 这个回合，自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤，那些怪兽效果也不能发动。②：从卡组把装备魔法卡任意数量送去墓地才能发动（同名卡最多1张）。和送去墓地的卡数量相同等级的1只战士族怪兽从卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c59934749.sumlimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册限制通常召唤的领域效果。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		-- 注册限制特殊召唤的领域效果。
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_MSET)
		-- 注册限制通常怪兽盖放的领域效果。
		Duel.RegisterEffect(e3,tp)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_ACTIVATE)
		e4:SetValue(c59934749.aclimit)
		-- 注册限制怪兽效果发动的领域效果。
		Duel.RegisterEffect(e4,tp)
	end
end
-- 限制与检索卡同名的怪兽的通常召唤/盖放。
function c59934749.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end
-- 限制与检索卡同名的怪兽的效果发动。
function c59934749.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and re:IsActiveType(TYPE_MONSTER)
end
-- 效果②的发动代价函数，使用Label标记来处理需要根据送去墓地的卡数量决定特殊召唤怪兽等级的逻辑。
function c59934749.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤卡组中可以作为代价送去墓地的装备魔法卡。
function c59934749.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
-- 过滤卡组中等级小于等于可用装备魔法卡种类数、且可以特殊召唤的战士族怪兽。
function c59934749.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_WARRIOR) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向/发动准备函数，计算可用的装备魔法卡种类，让玩家选择要特殊召唤的怪兽等级，并选择对应数量的装备魔法卡送去墓地作为发动代价。
function c59934749.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 获取卡组中所有可以送去墓地的装备魔法卡。
		local cg=Duel.GetMatchingGroup(c59934749.cfilter,tp,LOCATION_DECK,0,nil)
		-- 检查自己场上是否有空余的怪兽区域，且卡组中存在可送去墓地的装备魔法卡。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and cg:GetCount()>0
			-- 检查卡组中是否存在等级不超过“卡组中不同卡名的装备魔法卡总数”且可以特殊召唤的战士族怪兽。
			and Duel.IsExistingMatchingCard(c59934749.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,cg:GetClassCount(Card.GetCode))
	end
	-- 获取卡组中所有可以送去墓地的装备魔法卡。
	local cg=Duel.GetMatchingGroup(c59934749.cfilter,tp,LOCATION_DECK,0,nil)
	local ct=cg:GetClassCount(Card.GetCode)
	-- 获取卡组中所有等级不超过可用装备魔法卡种类数、且可以特殊召唤的战士族怪兽。
	local tg=Duel.GetMatchingGroup(c59934749.spfilter,tp,LOCATION_DECK,0,nil,e,tp,ct)
	local lvt={}
	local tc=tg:GetFirst()
	while tc do
		local tlv=0
		tlv=tlv+tc:GetLevel()
		lvt[tlv]=tlv
		tc=tg:GetNext()
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 提示玩家选择要特殊召唤的怪兽的等级。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(59934749,2))  --"请选择要特殊召唤的怪兽的等级"
	-- 让玩家宣言一个要特殊召唤的怪兽的等级（该等级必须在卡组中存在对应的可特殊召唤怪兽）。
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 设置卡片组选择的附加检查函数，确保选择的装备魔法卡卡名各不相同。
	aux.GCheckAdditional=aux.dncheck
	-- 让玩家从可用的装备魔法卡中选择数量等于所选等级的卡（且卡名互不相同）。
	local rg=cg:SelectSubGroup(tp,aux.TRUE,false,lv,lv)
	-- 重置卡片组选择的附加检查函数。
	aux.GCheckAdditional=nil
	-- 将选中的装备魔法卡送去墓地作为发动代价。
	Duel.SendtoGrave(rg,REASON_COST)
	e:SetLabel(lv)
	-- 设置效果处理信息，表示该效果会从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤卡组中等级等于送去墓地卡片数量、且可以特殊召唤的战士族怪兽。
function c59934749.spfilter2(c,e,tp,lv)
	return c:IsRace(RACE_WARRIOR) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的处理函数，从卡组将1只等级与送去墓地的卡数量相同的战士族怪兽特殊召唤。
function c59934749.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只等级等于送去墓地卡片数量的战士族怪兽。
	local g=Duel.SelectMatchingCard(tp,c59934749.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
	if g:GetCount()>0 then
		-- 将选中的怪兽在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
