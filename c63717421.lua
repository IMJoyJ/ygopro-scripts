--起動指令 ギア・チャージ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的发动时，可以以自己场上的当作装备卡使用的「零件」怪兽卡任意数量为对象。那个场合，那些卡特殊召唤。
-- ②：丢弃1张手卡才能发动。从卡组把1只「起动提督 破坏旋转者」加入手卡。
function c63717421.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这张卡的发动时，可以以自己场上的当作装备卡使用的「零件」怪兽卡任意数量为对象。那个场合，那些卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,63717421+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c63717421.target)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：丢弃1张手卡才能发动。从卡组把1只「起动提督 破坏旋转者」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63717421,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,63717422)
	e2:SetCost(c63717421.thcost)
	e2:SetTarget(c63717421.thtg)
	e2:SetOperation(c63717421.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示、当作装备卡使用的「零件」怪兽卡，且可以特殊召唤
function c63717421.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x51) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备：检查是否可以以自己场上当作装备卡的「零件」怪兽为对象发动，并由玩家选择是否发动该特殊召唤效果
function c63717421.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c63717421.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 获取自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查自己魔法与陷阱区域是否存在至少1张满足条件的「零件」怪兽卡
	if Duel.IsExistingTarget(c63717421.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp)
		-- 若有可用怪兽区域，则询问玩家是否发动特殊召唤效果
		and ft>0 and Duel.SelectYesNo(tp,aux.Stringid(63717421,1)) then  --"是否以装备的「零件」怪兽卡为对象发动？"
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c63717421.activate)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择任意数量（不超过可用怪兽区域数量）的当作装备卡使用的「零件」怪兽卡作为效果对象
		local g=Duel.SelectTarget(tp,c63717421.spfilter,tp,LOCATION_SZONE,0,1,ft,nil,e,tp)
		-- 设置特殊召唤的操作信息，包含选中的卡片组和数量
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- ①效果的处理：将选中的对象卡特殊召唤到自己场上
function c63717421.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取当前连锁中仍与此效果相关的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	if g:GetCount()<=ft then
		-- 将所有对象卡以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 提示玩家选择要特殊召唤的卡（当对象数量超过可用怪兽区域时）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将玩家选择的、数量符合可用区域限制的卡特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
		-- 因规则原因，将未能特殊召唤的其余对象卡送去墓地
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
-- ②效果的消耗：丢弃1张手卡
function c63717421.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡名为「起动提督 破坏旋转者」且可以加入手卡
function c63717421.thfilter(c)
	return c:IsCode(36322312) and c:IsAbleToHand()
end
-- ②效果的发动准备：检查卡组中是否存在「起动提督 破坏旋转者」并设置检索操作信息
function c63717421.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「起动提督 破坏旋转者」
	if chk==0 then return Duel.IsExistingMatchingCard(c63717421.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手卡的操作信息，包含卡片数量和来源位置（卡组）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组将1只「起动提督 破坏旋转者」加入手卡
function c63717421.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张「起动提督 破坏旋转者」
	local g=Duel.SelectMatchingCard(tp,c63717421.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
