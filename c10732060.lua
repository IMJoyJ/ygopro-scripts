--HSRグライダー2
-- 效果：
-- 机械族·风属性调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，以除调整外的自己墓地1只7星以下的风属性同调怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：对方把怪兽特殊召唤的场合，若自己场上有「幻透翼」怪兽存在，把墓地的这张卡除外才能发动。对方场上的全部怪兽的等级上升5星。
local s,id,o=GetID()
-- 注册卡片的同调召唤手续并设置其为可以被特殊召唤，同时注册两个诱发效果，分别对应①②效果
function s.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求1只满足s.sfilter条件的调整，以及1只满足aux.NonTuner(nil)条件的调整以外的怪兽
	aux.AddSynchroProcedure(c,s.sfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，以除调整外的自己墓地1只7星以下的风属性同调怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽特殊召唤的场合，若自己场上有「幻透翼」怪兽存在，把墓地的这张卡除外才能发动。对方场上的全部怪兽的等级上升5星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"等级上升"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.lvcon)
	-- 为效果②设置将墓地的这张卡除外作为发动条件
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
-- 过滤满足机械族且风属性的卡
function s.sfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 判断该卡是否为同调召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足非调整、同调、7星以下、风属性且可以特殊召唤的卡
function s.spfilter(c,e,tp)
	return not c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(7)
		and c:IsAttribute(ATTRIBUTE_WIND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果①的发动时点和目标选择条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在满足条件的卡
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果①的处理信息，表示将特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果①，将选中的卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然存在于场上且未被王家长眠之谷影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤满足幻透翼卡组且表侧表示的卡
function s.cfilter(c)
	return c:IsSetCard(0xff) and c:IsFaceup()
end
-- 判断是否有对方怪兽被特殊召唤
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 过滤满足表侧表示且等级大于0的卡
function s.lvfilter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 设置效果②的发动时点和条件
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 判断自己场是否存有幻透翼怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 处理效果②，使对方场上所有怪兽等级上升5星
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有满足条件的怪兽
	local tg=Duel.GetMatchingGroup(s.lvfilter,tp,0,LOCATION_MZONE,nil)
	-- 遍历所有满足条件的怪兽
	for tc in aux.Next(tg) do
		-- 为每个怪兽设置等级上升5星的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(5)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e1)
	end
end
