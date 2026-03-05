--白き乙女
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡送去墓地才能发动。从自己的手卡·卡组·墓地把1张「真正之光」在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡在墓地存在的状态，自己把「青眼白龙」特殊召唤的场合才能发动。这张卡特殊召唤。
-- ③：场上的这张卡成为攻击·效果的对象时才能发动。从自己墓地把1只「青眼白龙」或光属性·1星调整特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果，分别对应①②③效果
function s.initial_effect(c)
	-- 记录该卡拥有「青眼白龙」和「真正之光」的卡名
	aux.AddCodeList(c,89631139,62089826)
	-- 注册一个监听该卡进入墓地的单次持续效果，用于②效果判断
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①效果：把手卡·场上的这张卡送去墓地才能发动。从自己的手卡·卡组·墓地把1张「真正之光」在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"表侧放置"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.pcost)
	e1:SetTarget(s.ptg)
	e1:SetOperation(s.pop)
	c:RegisterEffect(e1)
	-- ②效果：这张卡在墓地存在的状态，自己把「青眼白龙」特殊召唤的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetLabelObject(e0)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③效果：场上的这张卡成为攻击·效果的对象时才能发动。从自己墓地把1只「青眼白龙」或光属性·1星调整特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_BECOME_TARGET)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e4)
end
-- ①效果的费用：将此卡送去墓地
function s.pcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() and e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ①效果的过滤函数：筛选「真正之光」卡
function s.pfilter(c,tp)
	return c:IsCode(62089826)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ①效果的发动条件判断：判断场上是否有魔法与陷阱区域的空位，以及手卡·卡组·墓地是否有「真正之光」
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有魔法与陷阱区域的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断手卡·卡组·墓地是否有「真正之光」
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp) end
end
-- ①效果的处理：选择一张「真正之光」放置到魔法与陷阱区域
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有魔法与陷阱区域的空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的「真正之光」卡
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	-- 将选中的卡放置到魔法与陷阱区域
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
-- ②效果的过滤函数：筛选「青眼白龙」
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsCode(89631139)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- ②效果的发动条件判断：判断是否有「青眼白龙」被特殊召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
-- ②效果的发动条件判断：判断是否有魔法与陷阱区域的空位，以及此卡是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有主要怪兽区域的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：准备特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：将此卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否还在场上且未被王家长眠之谷影响
	if not c:IsRelateToEffect(e) or not aux.NecroValleyFilter()(c) then return end
	-- 将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ③效果的发动条件判断：判断此卡是否成为攻击或效果的对象
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- ③效果的过滤函数：筛选「青眼白龙」或光属性·1星调整
function s.spfilter(c,e,tp)
	return (c:IsCode(89631139) or c:IsLevel(1) and c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_LIGHT))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动条件判断：判断场上是否有主要怪兽区域的空位，以及墓地是否有满足条件的卡
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有主要怪兽区域的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否有满足条件的卡
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤墓地中的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ③效果的处理：从墓地特殊召唤满足条件的卡
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有主要怪兽区域的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
