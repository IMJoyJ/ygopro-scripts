--真竜凰マリアムネ
-- 效果：
-- 「真龙凰 玛丽亚姆内」的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从这张卡以外的手卡以及自己场上的表侧表示怪兽之中把包含风属性怪兽的2只怪兽破坏，这张卡从手卡特殊召唤，把2只风属性怪兽破坏的场合，可以从对方卡组上面把4张卡除外。
-- ②：这张卡被效果破坏的场合才能发动。从卡组把1只风属性以外的幻龙族怪兽加入手卡。
function c94160895.initial_effect(c)
	-- 「真龙凰 玛丽亚姆内」的①的效果：自己主要阶段才能发动。从这张卡以外的手卡以及自己场上的表侧表示怪兽之中把包含风属性怪兽的2只怪兽破坏，这张卡从手卡特殊召唤，把2只风属性怪兽破坏的场合，可以从对方卡组上面把4张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94160895,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,94160895)
	e1:SetTarget(c94160895.sptg)
	e1:SetOperation(c94160895.spop)
	c:RegisterEffect(e1)
	-- 「真龙凰 玛丽亚姆内」的②的效果：这张卡被效果破坏的场合才能发动。从卡组把1只风属性以外的幻龙族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94160895,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,94160896)
	e2:SetCondition(c94160895.thcon)
	e2:SetTarget(c94160895.thtg)
	e2:SetOperation(c94160895.thop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中的怪兽以及场上表侧表示的怪兽（作为破坏候选）
function c94160895.desfilter(c)
	return c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 过滤自己主要怪兽区域表侧表示的怪兽（用于怪兽区域满时必须破坏自己怪兽区怪兽的情况）
function c94160895.desfilter2(c)
	return c:IsFaceup() and c:GetSequence()<5
end
-- 过滤自己主要怪兽区域的怪兽（用于判断是否能腾出怪兽区域）
function c94160895.mzfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
-- 效果①的发动准备，检查手牌和场上是否有足够的可破坏怪兽（且包含风属性），以及自身是否能特殊召唤，并设置破坏与特殊召唤的操作信息
function c94160895.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己场上可用主要怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=nil
	if ft>-1 then
		local loc=0
		-- 检查玩家是否受到特定卡片效果影响，若有则允许将对方场上的怪兽也纳入可选破坏范围
		if Duel.IsPlayerAffectedByEffect(tp,88581108) then loc=LOCATION_MZONE end
		-- 获取自己手牌、自己场上（以及可能因特定效果包含的对方场上）的可破坏怪兽组（排除自身）
		g=Duel.GetMatchingGroup(c94160895.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,loc,c)
	else
		-- 当自己场上没有可用怪兽区域时，获取自己主要怪兽区域表侧表示的可破坏怪兽组（排除自身）
		g=Duel.GetMatchingGroup(c94160895.desfilter2,tp,LOCATION_MZONE,0,c)
	end
	if chk==0 then return ft>-2 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:GetCount()>=2 and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND)
		and (ft~=0 or g:IsExists(c94160895.mzfilter,1,nil,tp)) end
	-- 设置连锁运营信息，声明此效果包含破坏2张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,LOCATION_MZONE)
	-- 设置连锁运营信息，声明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的执行函数，选择并破坏包含风属性在内的2只怪兽，将这张卡特殊召唤；若破坏的2只都是风属性，则可以选是否将对方卡组最上方4张卡除外
function c94160895.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上可用主要怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=nil
	if ft>-1 then
		local loc=0
		-- 检查玩家是否受到特定卡片效果影响，若有则允许将对方场上的怪兽也纳入可选破坏范围
		if Duel.IsPlayerAffectedByEffect(tp,88581108) then loc=LOCATION_MZONE end
		-- 获取自己手牌、自己场上（以及可能因特定效果包含的对方场上）的可破坏怪兽组（排除自身）
		g=Duel.GetMatchingGroup(c94160895.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,loc,c)
	else
		-- 当自己场上没有可用怪兽区域时，获取自己主要怪兽区域表侧表示的可破坏怪兽组（排除自身）
		g=Duel.GetMatchingGroup(c94160895.desfilter2,tp,LOCATION_MZONE,0,c)
	end
	if g:GetCount()<2 or not g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND) then return end
	local g1=nil
	-- 提示玩家选择要破坏的第一张卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	if ft==0 then
		g1=g:FilterSelect(tp,c94160895.mzfilter,1,1,nil,tp)
	else
		g1=g:Select(tp,1,1,nil)
	end
	-- 提示玩家选择要破坏的第二张卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	if g1:GetFirst():IsAttribute(ATTRIBUTE_WIND) then
		local g2=g:Select(tp,1,1,g1:GetFirst())
		g1:Merge(g2)
	else
		local g2=g:FilterSelect(tp,Card.IsAttribute,1,1,g1:GetFirst(),ATTRIBUTE_WIND)
		g1:Merge(g2)
	end
	local rm=g1:IsExists(Card.IsAttribute,2,nil,ATTRIBUTE_WIND)
	-- 尝试将选中的2只怪兽因效果破坏，若成功破坏了2只则继续执行后续处理
	if Duel.Destroy(g1,REASON_EFFECT)==2 then
		if not c:IsRelateToEffect(e) then return end
		-- 将这张卡从手牌往自己场上表侧表示特殊召唤，若特殊召唤失败则结束效果处理
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then
			return
		end
		-- 获取对方卡组最上方的4张卡
		local rg=Duel.GetDecktopGroup(1-tp,4)
		if rm and rg:GetCount()>0 and rg:FilterCount(Card.IsAbleToRemove,nil)==4
			-- 询问玩家是否发动追加效果，将对方卡组最上方的4张卡除外
			and Duel.SelectYesNo(tp,aux.Stringid(94160895,2)) then  --"是否把对方卡组的卡除外？"
			-- 禁用接下来的洗牌检测，防止在除外卡组顶端卡片时自动洗牌
			Duel.DisableShuffleCheck()
			-- 将对方卡组最上方的4张卡表侧表示除外
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 效果②的发动条件：此卡因效果被破坏
function c94160895.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤卡组中风属性以外的幻龙族怪兽（用于检索）
function c94160895.thfilter(c)
	return c:IsNonAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WYRM) and c:IsAbleToHand()
end
-- 效果②的发动准备，检查卡组中是否存在风属性以外的幻龙族怪兽，并设置检索的操作信息
function c94160895.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1只满足检索条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c94160895.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁运营信息，声明此效果包含从卡组将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的执行函数，从卡组选择1只风属性以外的幻龙族怪兽加入手牌并给对方确认
function c94160895.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c94160895.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
