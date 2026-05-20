--告天子竜パイレン
-- 效果：
-- 6星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要「告天子龙 百灵」以外的从墓地特殊召唤的怪兽在场上表侧表示存在，这张卡不会被战斗·效果破坏。
-- ②：自己·对方的准备阶段把这张卡1个超量素材取除，以自己墓地1只5星以下的怪兽为对象才能发动。那只怪兽特殊召唤。
function c75083197.initial_effect(c)
	-- 添加XYZ召唤手续：6星怪兽×2
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- ①：只要「告天子龙 百灵」以外的从墓地特殊召唤的怪兽在场上表侧表示存在，这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	e1:SetCondition(c75083197.indescon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：自己·对方的准备阶段把这张卡1个超量素材取除，以自己墓地1只5星以下的怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75083197,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,75083197)
	e3:SetCost(c75083197.spcost)
	e3:SetTarget(c75083197.sptg)
	e3:SetOperation(c75083197.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：从墓地特殊召唤的、且不是「告天子龙 百灵」的怪兽
function c75083197.indesfilter(c)
	return c:IsSummonLocation(LOCATION_GRAVE) and (c:IsFacedown() or not c:IsCode(75083197))
end
-- 破坏抗性效果的生效条件判定
function c75083197.indescon(e)
	-- 检查场上是否存在至少1只满足过滤条件的怪兽
	return Duel.IsExistingMatchingCard(c75083197.indesfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果②的发动代价：取除这张卡的1个超量素材
function c75083197.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：自己墓地5星以下且可以特殊召唤的怪兽
function c75083197.spfilter(c,e,tp)
	return c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（判定是否满足发动条件、选择对象并设置操作信息）
function c75083197.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c75083197.spfilter(chkc,e,tp) end
	-- 判定自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在至少1只满足条件的怪兽
		and Duel.IsExistingTarget(c75083197.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c75083197.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理（特殊召唤作为对象的怪兽）
function c75083197.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
