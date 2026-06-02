--グレイン・ブリッツクリーク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏，从手卡把1只雷族怪兽特殊召唤。这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，这张卡以外的卡被效果破坏的场合才能发动。从卡组把1张「雷盟」魔法卡或「天空城塞 库仑城寨」加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册效果①和效果②。
function s.initial_effect(c)
	-- 将「天空城塞 库仑城寨」（卡密码：37654623）登记到当前卡片的关系卡列表中。
	aux.AddCodeList(c,37654623)
	-- ①：把手卡的这张卡给对方观看，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏，从手卡把1只雷族怪兽特殊召唤。这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，这张卡以外的卡被效果破坏的场合才能发动。从卡组把1张「雷盟」魔法卡或「天空城塞 库仑城寨」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价：确认手牌中的这张卡没有处于公开状态。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 效果①中魔法·陷阱卡破坏的过滤条件：过滤场上的魔法·陷阱卡，并且该卡被破坏后己方主要怪兽区域有空位。
function s.desfilter(c,e,tp)
	-- 判断该卡是魔法或陷阱卡，并且该卡破坏后自己能腾出怪兽区域空位（由于是作为特召前置，如果对象在自己场上，该卡破坏后是否有空位需要预估判断）。
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①中特殊召唤的过滤条件：过滤手牌中的雷族怪兽且其可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_THUNDER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的目标选择与发动条件判定：需要场上有可以作为对象的魔法·陷阱卡且手牌中有可以特殊召唤的雷族怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.desfilter(chkc,e,tp) end
	-- 效果①的发动条件判定的一部分：检查场上是否存在符合破坏条件的魔法·陷阱卡对象。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e,tp)
		-- 效果①的发动条件判定的一部分：检查手牌中是否存在可以特殊召唤的雷族怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上的一张魔法·陷阱卡作为效果①的连锁对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e,tp)
	-- 设置效果①处理时的操作信息：预计将选中的卡破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果①处理时的操作信息：预计从手牌将1张怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的执行操作：破坏选中的魔法·陷阱卡，如果破坏成功则从手牌特殊召唤一只雷族怪兽，并在此之后适用特召限制效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的第一个效果对象（即要破坏的魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsOnField()
		-- 判断目标卡是否成功破坏，并检查自己场上是否有空闲的怪兽区域。
		and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手牌中选择一只雷族怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将手牌洗切。
			Duel.ShuffleHand(tp)
			-- 将选择的雷族怪兽以表侧表示特殊召唤到玩家自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。②：这张卡在怪兽区域存在的状态，这张卡以外的卡被效果破坏的场合才能发动。从卡组把1张「雷盟」魔法卡或「天空城塞 库仑城寨」加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该玩家在这个回合不能从手牌以外特殊召唤效果怪兽的限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 特召限制的过滤条件：如果是效果怪兽，且特殊召唤来源不是手牌，则限制其特殊召唤。
function s.splimit(e,c)
	return c:IsType(TYPE_EFFECT) and not c:IsLocation(LOCATION_HAND)
end
-- 效果②的破坏卡过滤条件：被效果破坏的卡。
function s.cfilter(c)
	return c:IsReason(REASON_EFFECT)
end
-- 效果②的发动条件：除这张卡以外的有卡被效果破坏。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler())
end
-- 效果②中检索加入手牌的卡片过滤条件：「雷盟」魔法卡或「天空城塞 库仑城寨」，且可以加入手牌。
function s.thfilter(c)
	return (c:IsCode(37654623) or c:IsSetCard(0x1df) and c:IsType(TYPE_SPELL)) and c:IsAbleToHand()
end
-- 效果②的靶向/发动可行性判定：检查卡组中是否存在符合过滤条件的卡，并在发动时宣告检索操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果②的判定：检查卡组中是否存在可以检索加入手牌的「雷盟」魔法卡或「天空城塞 库仑城寨」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果②处理时的操作信息：预计从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的执行操作：从卡组检索1张「雷盟」魔法卡或「天空城塞 库仑城寨」加入手牌，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张符合条件的卡加入手牌。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
