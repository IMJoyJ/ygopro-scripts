--氷結界に至る晴嵐
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上的「冰结界」怪兽任意数量解放才能发动。把解放数量的4星以下的「冰结界」怪兽从卡组特殊召唤（同名卡最多1张）。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的墓地·除外状态的1只「冰结界」怪兽为对象才能发动。那只怪兽加入手卡。
function c17197110.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把自己场上的「冰结界」怪兽任意数量解放才能发动。把解放数量的4星以下的「冰结界」怪兽从卡组特殊召唤（同名卡最多1张）。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的墓地·除外状态的1只「冰结界」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17197110,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,17197111)
	-- 设置②效果的发动条件：这张卡不是在本回合被送去墓地时才能发动（若本回合已被送去墓地则不能发动）。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：将墓地中的这张卡除外作为发动代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c17197110.thtg)
	e2:SetOperation(c17197110.thop)
	c:RegisterEffect(e2)
end
-- 定义可解放的「冰结界」怪兽的筛选条件：持有0x2f字段的怪兽卡，且是自己控制的卡或者表侧表示的卡。
function c17197110.rfilter(c,tp)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and (c:IsControler(tp) or c:IsFaceup())
end
-- 定义从卡组特殊召唤的「冰结界」怪兽的筛选条件：持有0x2f字段、等级4以下，且可以被当前效果特殊召唤。
function c17197110.spfilter(c,e,tp)
	return c:IsSetCard(0x2f) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设定解放组的合法性判定：解放这组卡后自己场上的可用怪兽区数量不少于这组卡的数量，并且该组卡均可被解放。
function c17197110.fselect(g,tp)
	-- 计算解放这组卡后自己场上可用的怪兽区数量是否不少于这组卡的数量，并确认这组卡都可以被解放。
	return Duel.GetMZoneCount(tp,g)>=g:GetCount() and Duel.CheckReleaseGroup(tp,aux.IsInGroup,#g,nil,g)
end
-- ①效果的代价处理：从可解放的「冰结界」怪兽中，结合可特殊召唤的4星以下「冰结界」怪兽数量、可用怪兽区数量、卡组中不同卡名的数量以及【青眼精灵龙】的同时特殊召唤限制，确定最多可解放的数量；玩家选择任意数量的「冰结界」怪兽解放，并记录解放数量供本次效果特殊召唤使用。
function c17197110.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 获取可解放的「冰结界」怪兽集合（自己场上或表侧表示的可解放怪兽中筛选）。
	local rg=Duel.GetReleaseGroup(tp):Filter(c17197110.rfilter,nil,tp)
	-- 获取卡组中所有可作为特殊召唤候选的4星以下「冰结界」怪兽集合。
	local sg=Duel.GetMatchingGroup(c17197110.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	local ft=Duel.IsPlayerAffectedByEffect(tp,59822133) and 1 or 5
	-- 计算最多可解放的数量：取【青眼精灵龙】限制值（1或5）、可解放怪兽数、解放后可用怪兽区数、卡组中不同卡名候选数中的最小值。
	local maxc=math.min(ft,rg:GetCount(),(Duel.GetMZoneCount(tp,rg)),sg:GetClassCount(Card.GetCode))
	if chk==0 then return maxc>0 and rg:CheckSubGroup(c17197110.fselect,1,maxc,tp) end
	-- 弹出“请选择要解放的卡”的提示，让玩家选择要解放的「冰结界」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local g=rg:SelectSubGroup(tp,c17197110.fselect,false,1,maxc,tp)
	e:SetLabel(g:GetCount())
	-- 若场上存在可代替解放的效果卡（如暗影敌托邦），消耗相应的代替解放次数。
	aux.UseExtraReleaseCount(g,tp)
	-- 将选择的一组「冰结界」怪兽作为代价解放（送入墓地）。
	Duel.Release(g,REASON_COST)
end
-- ①效果的发动确认：若代价阶段已成功设定标签为100，则把操作信息登记为从卡组特殊召唤解放数量的4星以下「冰结界」怪兽。
function c17197110.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabel()==100 end
	-- 向系统登记本次效果的操作信息：从卡组特殊召唤e:GetLabel()只（即解放数量）的「冰结界」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,e:GetLabel(),tp,LOCATION_DECK)
end
-- ①效果处理：根据实际可用怪兽区数量（若受【青眼精灵龙】影响则最多1只），从卡组选择与解放数量相同数量、且卡名互不相同的4星以下「冰结界」怪兽，表侧表示特殊召唤；若可用区域不足则效果不处理。
function c17197110.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上当前可用的主要怪兽区数量，用于限制可特殊召唤的数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>0 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local ct=e:GetLabel()
	if ft<ct or ft<=0 then return end
	-- 获取卡组中所有符合特殊召唤条件的4星以下「冰结界」怪兽集合。
	local g=Duel.GetMatchingGroup(c17197110.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 弹出“请选择要特殊召唤的卡”的提示，让玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从候选怪兽组中，由玩家选择解放数量（ct）张且卡名互不相同的「冰结界」怪兽。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	if sg then
		-- 将选中的「冰结界」怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果取对象的筛选条件：持有0x2f字段的怪兽，且位于墓地或表侧除外状态，并且能被加入手卡。
function c17197110.thfilter(c)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToHand()
end
-- ②效果的取对象处理：从自己墓地·除外状态的「冰结界」怪兽中选择1只作为对象，并登记回手牌的操作信息。
function c17197110.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c17197110.thfilter(chkc) end
	-- 发动时确认自己墓地·除外状态是否存在至少1只符合条件的「冰结界」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c17197110.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 弹出“请选择要加入手牌的卡”的提示，让玩家选择要加入手牌的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地·除外状态选择1只符合条件的「冰结界」怪兽作为效果对象。
	local sg=Duel.SelectTarget(tp,c17197110.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 向系统登记本次效果将把选择的对象怪兽加入手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- ②效果处理时：取得对象卡，若该卡仍与本次效果相关，则将其加入持有者手牌。
function c17197110.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果处理时的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象「冰结界」怪兽加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
