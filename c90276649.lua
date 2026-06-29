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
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡发动效果。
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
-- 限制自己只能灵摆召唤光属性怪兽，且该效果不会被无效化。
function c90276649.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttribute(ATTRIBUTE_LIGHT) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 过滤场上表侧表示的非「幻奏」怪兽。
function c90276649.thcfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x9b)
end
-- 判断自己场上是否不存在非「幻奏」怪兽，作为灵摆效果②的发动条件。
function c90276649.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在非「幻奏」怪兽，若不存在则返回true。
	return not Duel.IsExistingMatchingCard(c90276649.thcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤卡组中可加入手牌的「幻奏」魔法·陷阱卡。
function c90276649.thfilter(c)
	return c:IsSetCard(0x9b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 灵摆效果②的靶向处理：检查卡组中是否存在可检索的「幻奏」魔陷，并设置检索的操作信息。
function c90276649.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可加入手牌的「幻奏」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c90276649.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果②的执行：从卡组选择1张「幻奏」魔法·陷阱卡加入手牌。
function c90276649.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「幻奏」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c90276649.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽效果①的发动条件：非规则原因（如抽卡阶段的通常抽卡）加入手牌。
function c90276649.spcon(e,tp,eg,ep,ev,re,r,rp)
	return r~=REASON_RULE
end
-- 怪兽效果①的代价：将手牌中的这张卡给对方观看。
function c90276649.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤手牌或墓地中可以特殊召唤的4星以下「幻奏」怪兽。
function c90276649.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x9b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果①的靶向处理：检查怪兽区域空位及手牌·墓地中是否存在可特召的怪兽，并设置特召的操作信息。
function c90276649.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手牌或墓地中是否存在满足条件的「幻奏」怪兽。
		and Duel.IsExistingMatchingCard(c90276649.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为从手牌或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 怪兽效果①的执行：从手牌或墓地选择1只4星以下的「幻奏」怪兽特殊召唤。
function c90276649.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空格，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌或墓地中选择1只满足条件的「幻奏」怪兽（受王家之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c90276649.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上特殊召唤成功的表侧表示「幻奏」融合怪兽。
function c90276649.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(0x9b) and c:IsControler(tp)
end
-- 怪兽效果②的发动条件：这张卡在额外卡组表侧表示存在，且自己场上有「幻奏」融合怪兽特殊召唤。
function c90276649.pencon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and eg:IsExists(c90276649.cfilter,1,nil,tp)
end
-- 怪兽效果②的靶向处理：检查自己的灵摆区域是否有空位。
function c90276649.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的左侧或右侧灵摆区域是否可用。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果②的执行：将这张卡在自己的灵摆区域放置。
function c90276649.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果相关，且灵摆区域是否有空位。
	if c:IsRelateToEffect(e) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
		-- 将这张卡移动到自己的灵摆区域表侧表示放置。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
