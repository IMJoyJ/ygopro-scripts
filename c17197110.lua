--氷結界に至る晴嵐
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上的「冰结界」怪兽任意数量解放才能发动。把解放数量的4星以下的「冰结界」怪兽从卡组特殊召唤（同名卡最多1张）。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的墓地·除外状态的1只「冰结界」怪兽为对象才能发动。那只怪兽加入手卡。
function c17197110.initial_effect(c)
	-- ①：把自己场上的「冰结界」怪兽任意数量解放才能发动。把解放数量的4星以下的「冰结界」怪兽从卡组特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17197110,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,17197110)
	e1:SetCost(c17197110.cost)
	e1:SetTarget(c17197110.target)
	e1:SetOperation(c17197110.activate)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的墓地·除外状态的1只「冰结界」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17197110,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,17197111)
	-- 效果发动时，若此卡在本回合被送去墓地则不能发动。
	e2:SetCondition(aux.exccon)
	-- 效果发动时，将此卡从游戏中除外作为费用。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c17197110.thtg)
	e2:SetOperation(c17197110.thop)
	c:RegisterEffect(e2)
end
-- 筛选场上可解放的「冰结界」怪兽。
function c17197110.rfilter(c,tp)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and (c:IsControler(tp) or c:IsFaceup())
end
-- 筛选卡组中4星以下的「冰结界」怪兽。
function c17197110.spfilter(c,e,tp)
	return c:IsSetCard(0x2f) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查所选怪兽数量是否满足召唤条件。
function c17197110.fselect(g,tp)
	-- 检查所选怪兽数量是否满足召唤条件。
	return Duel.GetMZoneCount(tp,g)>=g:GetCount() and Duel.CheckReleaseGroup(tp,aux.IsInGroup,#g,nil,g)
end
-- 效果发动时，选择场上可解放的「冰结界」怪兽并支付解放费用。
function c17197110.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 获取玩家场上可解放的「冰结界」怪兽组。
	local rg=Duel.GetReleaseGroup(tp):Filter(c17197110.rfilter,nil,tp)
	-- 获取玩家卡组中满足条件的「冰结界」怪兽组。
	local sg=Duel.GetMatchingGroup(c17197110.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	local ft=Duel.IsPlayerAffectedByEffect(tp,59822133) and 1 or 5
	-- 计算可发动的最大次数。
	local maxc=math.min(ft,rg:GetCount(),(Duel.GetMZoneCount(tp,rg)),sg:GetClassCount(Card.GetCode))
	if chk==0 then return maxc>0 and rg:CheckSubGroup(c17197110.fselect,1,maxc,tp) end
	-- 提示玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local g=rg:SelectSubGroup(tp,c17197110.fselect,false,1,maxc,tp)
	e:SetLabel(g:GetCount())
	-- 处理额外解放次数的使用。
	aux.UseExtraReleaseCount(g,tp)
	-- 将所选怪兽解放作为费用。
	Duel.Release(g,REASON_COST)
end
-- 设置效果发动时的处理信息。
function c17197110.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabel()==100 end
	-- 设置效果发动时的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,e:GetLabel(),tp,LOCATION_DECK)
end
-- 效果发动时，从卡组特殊召唤满足条件的怪兽。
function c17197110.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>0 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local ct=e:GetLabel()
	if ft<ct or ft<=0 then return end
	-- 获取玩家卡组中满足条件的「冰结界」怪兽组。
	local g=Duel.GetMatchingGroup(c17197110.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽组。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	if sg then
		-- 将所选怪兽特殊召唤到场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选墓地或除外状态的「冰结界」怪兽。
function c17197110.thfilter(c)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToHand()
end
-- 设置效果发动时的处理信息。
function c17197110.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c17197110.thfilter(chkc) end
	-- 检查是否存在满足条件的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c17197110.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽作为对象。
	local sg=Duel.SelectTarget(tp,c17197110.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果发动时的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- 效果发动时，将对象怪兽加入手牌。
function c17197110.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
