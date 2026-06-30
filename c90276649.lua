--幻奏の歌姫クープレ
-- 效果：
-- ←9 【灵摆】 9→
-- 这个卡名的②的灵摆效果1回合只能使用1次。
-- ①：自己不是光属性怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：自己场上没有「幻奏」怪兽以外的表侧表示怪兽存在的场合才能发动。从卡组把1张「幻奏」魔法·陷阱卡加入手卡。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡用通常抽卡以外的方法加入手卡的场合，把这张卡给对方观看才能发动。从自己的手卡·墓地把1只4星以下的「幻奏」怪兽特殊召唤。
-- ②：这张卡在额外卡组表侧存在的状态，自己场上有「幻奏」融合怪兽特殊召唤的场合才能发动。这张卡在自己的灵摆区域放置。
function c90276649.initial_effect(c)
	-- 初始化灵摆怪兽的灵摆属性
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是光属性怪兽不能灵摆召唤。这个效果不会被无效化。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetTargetRange(1,0)
	e0:SetTarget(c90276649.splimit)
	c:RegisterEffect(e0)
	-- ②：自己场上没有「幻奏」怪兽以外的表侧表示怪兽存在的场合才能发动。从卡组把1张「幻奏」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90276649,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,90276649)
	e1:SetCondition(c90276649.thcon)
	e1:SetTarget(c90276649.thtg)
	e1:SetOperation(c90276649.thop)
	c:RegisterEffect(e1)
	-- ①：这张卡用通常抽卡以外的方法加入手卡的场合，把这张卡给对方观看才能发动。从自己的手卡·墓地把1只4星以下的「幻奏」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90276649,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCountLimit(1,90276650)
	e2:SetCondition(c90276649.spcon)
	e2:SetCost(c90276649.spcost)
	e2:SetTarget(c90276649.sptg)
	e2:SetOperation(c90276649.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡在额外卡组表侧存在的状态，自己场上有「幻奏」融合怪兽特殊召唤的场合才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(90276649,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCountLimit(1,90276651)
	e3:SetCondition(c90276649.pencon)
	e3:SetTarget(c90276649.pentg)
	e3:SetOperation(c90276649.penop)
	c:RegisterEffect(e3)
end
-- 限制自己只能灵摆召唤光属性怪兽
function c90276649.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttribute(ATTRIBUTE_LIGHT) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 过滤自己场上非「幻奏」的表侧表示怪兽
function c90276649.thcfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x9b)
end
-- 检查自己场上是否没有「幻奏」怪兽以外的表侧表示怪兽作为效果发动条件
function c90276649.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否没有「幻奏」怪兽以外的表侧表示怪兽
	return not Duel.IsExistingMatchingCard(c90276649.thcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤卡组中的「幻奏」魔法·陷阱卡
function c90276649.thfilter(c)
	return c:IsSetCard(0x9b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 检查卡组中是否存在可检索的「幻奏」魔法·陷阱卡并注册检索操作信息
function c90276649.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时检查卡组中是否存在可检索的「幻奏」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c90276649.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理的操作信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 从卡组将1张「幻奏」魔法·陷阱卡加入手卡的效果处理
function c90276649.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「幻奏」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c90276649.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检查是否通过规则以外的方式加入手牌
function c90276649.spcon(e,tp,eg,ep,ev,re,r,rp)
	return r~=REASON_RULE
end
-- 将手牌的这张卡向对方展示作为发动的代价
function c90276649.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤手牌或墓地中可以特殊召唤的4星以下「幻奏」怪兽
function c90276649.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x9b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查场上空位和手牌或墓地是否有符合条件的怪兽，并注册特殊召唤操作信息
function c90276649.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动检测时检查自己手牌或墓地中是否存在可以特殊召唤的符合条件的怪兽
		and Duel.IsExistingMatchingCard(c90276649.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理的操作信息为：从手牌或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 从手牌或墓地特殊召唤1只4星以下「幻奏」怪兽的效果处理
function c90276649.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果场上没有可用的怪兽区域则无法处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或墓地选择1张符合条件的「幻奏」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c90276649.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将所选怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上表侧表示的「幻奏」融合怪兽
function c90276649.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(0x9b) and c:IsControler(tp)
end
-- 检查此卡是否表侧存在于额外卡组且自己场上有「幻奏」融合怪兽特殊召唤
function c90276649.pencon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and eg:IsExists(c90276649.cfilter,1,nil,tp)
end
-- 检查自己的灵摆区域是否有空位
function c90276649.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时检查自己的灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 将此卡放置在灵摆区域的效果处理
function c90276649.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否在场且灵摆区域是否有空位
	if c:IsRelateToEffect(e) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
		-- 将此卡放置到自己的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
