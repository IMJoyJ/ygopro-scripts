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
	-- 为这张卡添加灵摆怪兽属性，使其可以进行灵摆召唤以及作为灵摆卡发动
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
-- 灵摆召唤限制过滤：对灵摆召唤的非光属性怪兽禁止特殊召唤（即自己不是光属性怪兽不能灵摆召唤）
function c90276649.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttribute(ATTRIBUTE_LIGHT) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 过滤函数：表侧表示存在且不是「幻奏」系列的卡
function c90276649.thcfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x9b)
end
-- 发动条件：自己怪兽区域不存在「幻奏」以外的表侧表示怪兽
function c90276649.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上怪兽区域是否没有「幻奏」以外的表侧表示怪兽存在
	return not Duel.IsExistingMatchingCard(c90276649.thcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 检索过滤函数：可以加入手卡的「幻奏」魔法·陷阱卡
function c90276649.thfilter(c)
	return c:IsSetCard(0x9b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果目标检查：确认卡组存在可检索的「幻奏」魔法·陷阱卡，并设置从卡组将卡加入手卡的操作信息
function c90276649.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中存在至少1张可以加入手卡的「幻奏」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c90276649.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本连锁将要从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选1张「幻奏」魔法·陷阱卡加入手卡，并给对方确认
function c90276649.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1张满足条件的「幻奏」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c90276649.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡以效果处理的原因加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 发动条件：这张卡不是因规则（通常抽卡）加入手卡，即用通常抽卡以外的方法加入手卡的场合
function c90276649.spcon(e,tp,eg,ep,ev,re,r,rp)
	return r~=REASON_RULE
end
-- 发动代价检查：这张卡尚未处于公开状态，把这张卡给对方观看才能发动
function c90276649.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 特殊召唤过滤函数：可以被特殊召唤的4星以下的「幻奏」怪兽
function c90276649.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x9b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标检查：自己主要怪兽区域有空位，且手卡·墓地存在可特殊召唤的4星以下「幻奏」怪兽
function c90276649.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否还有可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡·墓地是否存在至少1只可以特殊召唤的4星以下「幻奏」怪兽
		and Duel.IsExistingMatchingCard(c90276649.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本连锁将要从手卡·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理：主要怪兽区域有空位时，从自己的手卡·墓地选1只4星以下的「幻奏」怪兽特殊召唤
function c90276649.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区域没有可用空位则中止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己手卡·墓地选择1只4星以下的「幻奏」怪兽（并排除受王家长眠之谷影响的卡）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c90276649.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 把选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：自己场上表侧表示的「幻奏」融合怪兽
function c90276649.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(0x9b) and c:IsControler(tp)
end
-- 发动条件：这张卡在额外卡组表侧存在，且自己场上有「幻奏」融合怪兽特殊召唤
function c90276649.pencon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and eg:IsExists(c90276649.cfilter,1,nil,tp)
end
-- 效果目标检查：自己的灵摆区域还有可用的空格
function c90276649.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区域的左端或右端是否有可用空格
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 效果处理：这张卡仍与效果相关且灵摆区域有空位时，把这张卡在自己的灵摆区域放置
function c90276649.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与该效果相关，并且自己的灵摆区域有可用空格
	if c:IsRelateToEffect(e) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
		-- 把这张卡以表侧表示移动到自己的灵摆区域放置
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
