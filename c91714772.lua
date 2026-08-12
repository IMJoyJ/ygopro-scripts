--GDロボ・オービタル ７
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡解放才能发动。从卡组选1只「光子」怪兽和1只「银河」怪兽，那之内的1只加入手卡，另1只送去墓地。这个回合，自己不是光属性怪兽不能特殊召唤。
-- ②：自己场上有「银河眼」怪兽特殊召唤的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：把手卡·场上的这张卡解放才能发动。从卡组选1只「光子」怪兽和1只「银河」怪兽，那之内的1只加入手卡，另1只送去墓地。这个回合，自己不是光属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「银河眼」怪兽特殊召唤的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价：检查自身是否能被解放并进行解放操作
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将手卡或场上的这张卡解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：过滤卡组中属于「光子」或「银河」系列，且可以加入手牌或送入墓地的怪兽
function s.thfilter(c)
	return c:IsSetCard(0x7b,0x55) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToGrave() or c:IsAbleToHand())
end
-- 用于过滤判断的辅助包装函数
function s.filter(c,f)
	return f(c)
end
-- 检查选出的两张卡是否分别满足一个是「光子」另一个是「银河」，且一个能加手另一个能送墓
function s.gcheck(g)
	-- 检查卡片组中是否包含1只「光子」怪兽和1只「银河」怪兽
	return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsSetCard,0x7b,0x55)
		-- 检查卡片组中是否包含1张可加入手牌的卡和1张可送去墓地的卡
		and g:CheckSubGroup(aux.gfcheck,2,2,s.filter,Card.IsAbleToHand,Card.IsAbleToGrave)
end
-- 效果①的发动靶向：检查卡组是否存在可以操作的「光子」与「银河」怪兽组合，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有符合「光子」或「银河」且能检索或送墓的怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2) end
	-- 设置操作信息：预计将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：预计将卡组中的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组中选择1只「光子」和1只「银河」怪兽，让玩家选择其中1只加入手牌，另1只送去墓地，并注册本回合不能特殊召唤非光属性怪兽的限制
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合「光子」或「银河」且能检索或送墓的怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:CheckSubGroup(s.gcheck,2,2) then
		-- 提示玩家选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tc=sg:FilterSelect(tp,Card.IsAbleToHand,1,1,nil):GetFirst()
		-- 将选定的怪兽加入玩家手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,tc)
		sg:RemoveCard(tc)
		-- 将另一只怪兽送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	-- 这个回合，自己不是光属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能特殊召唤非光属性怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果：如果是除了光属性怪兽以外的怪兽则不能特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 过滤条件：过滤自己场上表侧表示的「银河眼」怪兽
function s.cfilter(c,tp)
	return c:IsSetCard(0x107b) and c:IsControler(tp) and c:IsFaceup()
end
-- 效果②的发动条件：自己场上有「银河眼」怪兽特殊召唤的场合
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 效果②的发动靶向：检查怪兽区域空位以及墓地的这张卡自身能否被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否还有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：预计将墓地的这张卡自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将墓地的这张卡特殊召唤，并注册离开场上时除外的转移效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否依然存在于墓地中且不受墓地效果无效的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 若将这张卡成功特殊召唤到场上
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
