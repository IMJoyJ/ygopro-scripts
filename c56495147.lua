--相剣師－泰阿
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把1张「相剑」卡或者1只幻龙族怪兽除外才能发动。在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张「相剑」卡或者1只幻龙族怪兽送去墓地。
function c56495147.initial_effect(c)
	-- ①：从自己墓地把1张「相剑」卡或者1只幻龙族怪兽除外才能发动。在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56495147,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,56495147)
	e1:SetCost(c56495147.spcost)
	e1:SetTarget(c56495147.sptg)
	e1:SetOperation(c56495147.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张「相剑」卡或者1只幻龙族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,56495148)
	e2:SetCondition(c56495147.tgcon)
	e2:SetTarget(c56495147.tgtg)
	e2:SetOperation(c56495147.tgop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地的「相剑」卡或幻龙族怪兽作为除外代价
function c56495147.costfilter(c)
	return (c:IsSetCard(0x16b) or (c:IsRace(RACE_WYRM) and c:IsType(TYPE_MONSTER))) and c:IsAbleToRemoveAsCost()
end
-- 效果①的发动代价：从自己墓地把1张「相剑」卡或者1只幻龙族怪兽除外
function c56495147.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可作为代价除外的「相剑」卡或幻龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56495147.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c56495147.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果①的发动准备（检查怪兽区域空位以及是否能特殊召唤衍生物）
function c56495147.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能特殊召唤指定的「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20001444,0x16b,TYPES_TOKEN_MONSTER+TYPE_TUNER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) end
	-- 设置效果处理信息：涉及产生1张衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置效果处理信息：涉及特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果①的效果处理（特殊召唤衍生物并添加额外卡组特召限制）
function c56495147.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查自己场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果处理时，再次检查玩家是否能特殊召唤指定的「相剑衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20001444,0x16b,TYPES_TOKEN_MONSTER+TYPE_TUNER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) then
		-- 在后台创建「相剑衍生物」卡片
		local token=Duel.CreateToken(tp,56495148)
		-- 尝试将衍生物以表侧表示特殊召唤到自己场上（分步处理）
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c56495147.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
	end
end
-- 限制玩家不能从额外卡组特殊召唤同调怪兽以外的怪兽
function c56495147.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果②的发动条件：这张卡作为同调素材送去墓地的场合
function c56495147.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤卡组中可以送去墓地的「相剑」卡或幻龙族怪兽
function c56495147.tgfilter(c)
	return (c:IsSetCard(0x16b) or (c:IsRace(RACE_WYRM) and c:IsType(TYPE_MONSTER))) and c:IsAbleToGrave()
end
-- 效果②的发动准备（检查卡组中是否存在可送去墓地的卡并设置效果处理信息）
function c56495147.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可送去墓地的「相剑」卡或幻龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56495147.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（从卡组将1张「相剑」卡或者1只幻龙族怪兽送去墓地）
function c56495147.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c56495147.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
