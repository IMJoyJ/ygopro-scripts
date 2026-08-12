--春化精の花盛
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己场上有地属性怪兽5只以上存在，自己场上的怪兽的攻击力上升1000。
-- ②：从自己的手卡·墓地把1张「春化精与花蕾」除外才能发动。从卡组把1只「春化精的女神 春」特殊召唤。
-- ③：从自己墓地有「春化精」怪兽特殊召唤的场合，以自己或者对方的场上·墓地1只怪兽为对象才能发动。那只怪兽回到持有者手卡。
function c7206349.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要自己场上有地属性怪兽5只以上存在，自己场上的怪兽的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c7206349.condition)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- ②：从自己的手卡·墓地把1张「春化精与花蕾」除外才能发动。从卡组把1只「春化精的女神 春」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(7206349,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,7206349)
	e3:SetCost(c7206349.spcost)
	e3:SetTarget(c7206349.sptg)
	e3:SetOperation(c7206349.spop)
	c:RegisterEffect(e3)
	-- ③：从自己墓地有「春化精」怪兽特殊召唤的场合，以自己或者对方的场上·墓地1只怪兽为对象才能发动。那只怪兽回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(7206349,1))  --"怪兽回到手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,7206350)
	e4:SetCondition(c7206349.thcon)
	e4:SetTarget(c7206349.thtg)
	e4:SetOperation(c7206349.thop)
	c:RegisterEffect(e4)
end
-- 过滤条件：表侧表示的地属性怪兽
function c7206349.atkfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceup()
end
-- 攻击力上升效果的适用条件：自己场上有地属性怪兽5只以上存在
function c7206349.condition(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上表侧表示的地属性怪兽数量是否在5只以上
	return Duel.GetMatchingGroupCount(c7206349.atkfilter,tp,LOCATION_MZONE,0,nil)>=5
end
-- 过滤条件：手卡·墓地可以作为cost除外的「春化精与花蕾」
function c7206349.costfilter(c)
	return c:IsCode(63708033) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤效果的cost：从手卡·墓地将1张「春化精与花蕾」除外
function c7206349.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查手卡·墓地是否存在可以除外的「春化精与花蕾」
	if chk==0 then return Duel.IsExistingMatchingCard(c7206349.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择手卡·墓地1张「春化精与花蕾」
	local g=Duel.SelectMatchingCard(tp,c7206349.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡作为cost表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：卡组中可以特殊召唤的「春化精的女神 春」
function c7206349.filter(c,e,tp)
	return c:IsCode(55125728) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的target：检查怪兽区域空位及卡组中是否存在「春化精的女神 春」，并设置操作信息
function c7206349.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动时，检查卡组中是否存在可以特殊召唤的「春化精的女神 春」
		and Duel.IsExistingMatchingCard(c7206349.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的operation：从卡组将1只「春化精的女神 春」特殊召唤
function c7206349.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只「春化精的女神 春」
	local g=Duel.SelectMatchingCard(tp,c7206349.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：原本在自己墓地且被特殊召唤的「春化精」怪兽
function c7206349.cfilter(c,tp)
	return c:IsSetCard(0x182) and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
-- 回手牌效果的发动条件：检查是否有「春化精」怪兽从自己墓地特殊召唤
function c7206349.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c7206349.cfilter,1,nil,tp)
end
-- 过滤条件：可以回到手牌的怪兽
function c7206349.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 回手牌效果的target：选择自己或对方场上·墓地1只怪兽作为对象，并设置操作信息
function c7206349.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and c7206349.thfilter(chkc) end
	-- 在发动时，检查自己或对方的场上·墓地是否存在可以回到手牌的怪兽
	if chk==0 then return Duel.IsExistingTarget(c7206349.thfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 优先从场上选择自己或对方场上·墓地1只可以回到手牌的怪兽作为对象
	local g=aux.SelectTargetFromFieldFirst(tp,c7206349.thfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理的操作信息：将选中的对象怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回手牌效果的operation：将作为对象的怪兽送回持有者手牌
function c7206349.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
