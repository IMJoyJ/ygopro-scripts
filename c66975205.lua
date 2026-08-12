--ヤミーズメント☆ミニヨン
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上的「味美喵」怪兽的攻击力上升场上的兽族·光属性怪兽数量×500。
-- ②：自己场上有连接1怪兽存在的场合，以自己墓地1只1星「味美喵」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ③：这张卡在墓地存在的场合，以自己的墓地·除外状态的2只「味美喵」怪兽为对象才能发动。那些怪兽和这张卡用喜欢的顺序回到卡组下面。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的「味美喵」怪兽的攻击力上升场上的兽族·光属性怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置攻击力上升效果的影响对象为自己场上的「味美喵」怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1ca))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- ②：自己场上有连接1怪兽存在的场合，以自己墓地1只1星「味美喵」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤墓地怪兽"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ③：这张卡在墓地存在的场合，以自己的墓地·除外状态的2只「味美喵」怪兽为对象才能发动。那些怪兽和这张卡用喜欢的顺序回到卡组下面。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"回到卡组"
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上表侧表示的兽族·光属性怪兽。
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 计算攻击力上升数值的函数。
function s.atkval(e,c)
	-- 返回场上满足条件的兽族·光属性怪兽数量乘以500的数值。
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)*500
end
-- 过滤条件：场上表侧表示的连接1怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsLink(1)
end
-- 效果②发动的条件判定函数。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的连接1怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：墓地中可以特殊召唤的1星「味美喵」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1ca) and c:IsLevel(1)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与目标选择函数。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 在效果发动阶段，检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己墓地是否存在至少1只满足条件的1星「味美喵」怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的1星「味美喵」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时的操作信息为特殊召唤选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理（特殊召唤）函数。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为特殊召唤对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍与效果相关，且不受王家长眠之谷的影响。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：墓地或除外状态的可以回到卡组的「味美喵」怪兽。
function s.tdfilter(c)
	return c:IsSetCard(0x1ca) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and c:IsFaceupEx()
end
-- 效果③的发动准备与目标选择函数。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return c:IsAbleToDeck()
		-- 并检查自己墓地或除外状态是否存在至少2只满足条件的「味美喵」怪兽。
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil) end
	-- 向玩家发送“请选择要返回卡组的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地或除外状态的2只「味美喵」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,nil)
	g:AddCard(c)
	-- 设置效果处理时的操作信息为将选中的卡片和墓地的这张卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果③的效果处理（回到卡组下面）函数。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中仍与效果相关且不受王家长眠之谷影响的目标怪兽集合。
	local sg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(aux.TRUE),nil)
	if #sg==0 then return end
	-- 如果墓地中的这张卡已不与效果相关，或者受到王家长眠之谷的影响，则不进行处理。
	if not c:IsRelateToEffect(e) or not aux.NecroValleyFilter()(c) then return end
	sg:AddCard(c)
	-- 让玩家将目标怪兽和这张卡以喜欢的顺序放回卡组最下方。
	aux.PlaceCardsOnDeckBottom(tp,sg)
end
