--ティスティナの歩哨
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上有光属性「提斯蒂娜」怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：以自己场上1只「提斯蒂娜」怪兽或1张里侧表示卡为对象才能发动。那张卡破坏。那之后，从卡组把1张「提斯蒂娜」卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手卡·墓地特召）和②效果（破坏场上卡检索卡组）的注册
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己场上有光属性「提斯蒂娜」怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只「提斯蒂娜」怪兽或1张里侧表示卡为对象才能发动。那张卡破坏。那之后，从卡组把1张「提斯蒂娜」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的光属性「提斯蒂娜」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsSetCard(0x1a4)
end
-- ①效果的发动条件：自己场上存在光属性「提斯蒂娜」怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足过滤条件（表侧表示、光属性、「提斯蒂娜」）的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动准备（Target函数）：检查怪兽区域空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的效果处理（Operation函数）：将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关联，则将其以表侧表示特殊召唤到自己场上
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 过滤条件：里侧表示的卡，或者「提斯蒂娜」怪兽
function s.dfilter(c)
	return c:IsFacedown() or c:IsSetCard(0x1a4) and c:IsType(TYPE_MONSTER)
end
-- 过滤条件：卡组中可加入手牌的「提斯蒂娜」卡片
function s.filter(c)
	return c:IsSetCard(0x1a4) and c:IsAbleToHand()
end
-- ②效果的发动准备（Target函数）：处理取对象判定，检查场上是否有可破坏的卡以及卡组中是否有可检索的卡，并设置破坏与检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.dfilter(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的、满足破坏过滤条件的卡
	if chk==0 then return Duel.IsExistingTarget(s.dfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 并且检查卡组中是否存在至少1张可加入手牌的「提斯蒂娜」卡
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择自己场上1张满足条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,s.dfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置连锁处理中的操作信息：破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁处理中的操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理（Operation函数）：破坏对象卡，若破坏成功则从卡组检索1张「提斯蒂娜」卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡已不与效果关联，或未能成功破坏，则效果处理终止
	if not tc:IsRelateToEffect(e) or Duel.Destroy(tc,REASON_EFFECT)<1 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足过滤条件的「提斯蒂娜」卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 中断当前效果处理，使后续的加入手牌处理与破坏处理不视为同时进行（造成错时点）
		Duel.BreakEffect()
		-- 将选择的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
