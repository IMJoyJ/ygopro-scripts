--溟界の大蛟
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·场上把1只怪兽送去墓地，以原本属性和那只怪兽不同的自己墓地1只爬虫类族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己·对方的主要阶段，怪兽被送去对方墓地的场合才能发动。从卡组把1只爬虫类族怪兽送去墓地。
function c96203584.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：从自己的手卡·场上把1只怪兽送去墓地，以原本属性和那只怪兽不同的自己墓地1只爬虫类族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,96203584)
	e2:SetCost(c96203584.spcost)
	e2:SetTarget(c96203584.sptg)
	e2:SetOperation(c96203584.spop)
	c:RegisterEffect(e2)
	-- ②：自己·对方的主要阶段，怪兽被送去对方墓地的场合才能发动。从卡组把1只爬虫类族怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,96203585)
	e3:SetCondition(c96203584.tgcon)
	e3:SetTarget(c96203584.tgtg)
	e3:SetOperation(c96203584.tgop)
	c:RegisterEffect(e3)
end
-- 定义代价怪兽的过滤条件：必须是怪兽、能作为代价送去墓地、送去墓地后能腾出足够的怪兽区域，且自己墓地存在原本属性与其不同的爬虫类族怪兽
function c96203584.costfilter(c,e,tp)
	-- 检查卡片是否为怪兽、能否作为代价送去墓地，并计算其离开场上后是否有可用的怪兽区域
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
		-- 检查自己墓地是否存在至少1只原本属性与该怪兽不同的、可作为效果对象的爬虫类族怪兽
		and Duel.IsExistingTarget(c96203584.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetOriginalAttribute())
end
-- 定义特殊召唤对象的过滤条件：必须是爬虫类族怪兽、原本属性与传入的属性不同，且可以被特殊召唤
function c96203584.spfilter(c,e,tp,attr)
	return c:IsRace(RACE_REPTILE) and c:GetOriginalAttribute()~=attr and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动代价处理函数
function c96203584.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己手卡或场上是否存在满足代价条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96203584.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或场上选择1只满足代价条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c96203584.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetOriginalAttribute())
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(tc,REASON_COST)
end
-- 效果①的发动准备与对象选择函数
function c96203584.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local attr=e:GetLabel()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c96203584.spfilter(chkc,e,tp,attr) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只原本属性与代价怪兽不同的爬虫类族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c96203584.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,attr)
	-- 设置效果处理信息：将1张目标卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理（特殊召唤）函数
function c96203584.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到发动者的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义对方墓地怪兽的过滤条件：必须是怪兽且属于对方玩家
function c96203584.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(1-tp)
end
-- 效果②的发动条件检查函数
function c96203584.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己或对方的主要阶段，且有怪兽被送去对方的墓地
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) and eg:IsExists(c96203584.cfilter,1,nil,tp)
end
-- 定义卡组送墓怪兽的过滤条件：必须是爬虫类族怪兽且能送去墓地
function c96203584.tgfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToGrave()
end
-- 效果②的发动准备与目标检查函数
function c96203584.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己卡组中是否存在可以送去墓地的爬虫类族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96203584.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（送去墓地）函数
function c96203584.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足条件的爬虫类族怪兽
	local g=Duel.SelectMatchingCard(tp,c96203584.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
