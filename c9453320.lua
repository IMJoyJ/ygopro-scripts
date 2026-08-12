--海皇精 アビストリーテ
-- 效果：
-- 水属性7星怪兽×2只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合，以自己墓地1只7星以下的鱼族·海龙族·水族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的水属性怪兽的攻击力·守备力上升这张卡的超量素材数量×300。
-- ③：把这张卡1个超量素材取除才能发动。从卡组把1张「深渊」陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化效果注册函数
function s.initial_effect(c)
	-- 设置超量召唤手续：水属性7星怪兽2只以上
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),7,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合，以自己墓地1只7星以下的鱼族·海龙族·水族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的水属性怪兽的攻击力·守备力上升这张卡的超量素材数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置攻击力上升效果的适用对象为自己场上的水属性怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：把这张卡1个超量素材取除才能发动。从卡组把1张「深渊」陷阱卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"盖放"
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCost(s.setcost)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 效果①的发动条件：此卡超量召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果①的墓地目标过滤：等级7以下的水族、鱼族或海龙族怪兽，且可以特殊召唤
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(7) and c:IsRace(RACE_AQUA+RACE_FISH+RACE_SEASERPENT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动目标选择与合法性检测
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择墓地中1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的实际处理：将选中的墓地怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的发动对象
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，并进行王家之谷的过滤判定
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 计算并返回攻击力/守备力上升的数值（超量素材数量×300）
function s.val(e,c)
	return e:GetHandler():GetOverlayCount()*300
end
-- 效果③的发动代价：取除此卡的1个超量素材
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果③的卡组目标过滤：可以盖放的「深渊」陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x75) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果③的发动目标检测
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在满足条件的「深渊」陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果③的实际处理：从卡组选择1张「深渊」陷阱卡在场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组中选择1张满足条件的「深渊」陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的陷阱卡在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
