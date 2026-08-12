--天気予報
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②③的效果1回合各能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组选1张「天气」魔法·陷阱卡在自己的魔法与陷阱区域表侧表示放置。
-- ②：自己把「天气」连接怪兽连接召唤的场合，可以让自己的魔法与陷阱区域的表侧表示的「天气」卡作为「天气」怪兽来成为连接素材。
-- ③：自己主要阶段才能发动。从手卡把1只「天气」怪兽召唤。
local s,id,o=GetID()
-- 初始化效果函数，创建并注册3个效果：①发动效果、②连接素材效果、③召唤效果
function c18720257.initial_effect(c)
	-- ①作为这张卡的发动时的效果处理，可以从卡组选1张「天气」魔法·陷阱卡在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,18720257+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c18720257.activate)
	c:RegisterEffect(e1)
	-- ②自己把「天气」连接怪兽连接召唤的场合，可以让自己的魔法与陷阱区域的表侧表示的「天气」卡作为「天气」怪兽来成为连接素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetCountLimit(1,18720257+o)
	e2:SetTarget(c18720257.mattg)
	e2:SetValue(c18720257.matval)
	c:RegisterEffect(e2)
	-- ③自己主要阶段才能发动。从手卡把1只「天气」怪兽召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18720257,0))
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,18720257+o*2)
	e3:SetTarget(c18720257.sumtg)
	e3:SetOperation(c18720257.sumop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「天气」魔法·陷阱卡的过滤函数，包括类型、属性、是否禁止、是否唯一
function c18720257.tffilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_FIELD) and c:IsSetCard(0x109)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 发动效果：从卡组检索符合条件的「天气」魔法·陷阱卡并放置到魔法与陷阱区域
function c18720257.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「天气」魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c18720257.tffilter,tp,LOCATION_DECK,0,nil,tp)
	-- 判断是否有满足条件的卡、场上是否有空位、玩家是否选择放置
	if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(18720257,1)) then  --"是否选「天气」魔法·陷阱卡放置？"
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡移动到魔法与陷阱区域
		Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
-- 连接素材效果的目标过滤函数，判断是否为「天气」卡且在魔法与陷阱区域
function c18720257.mattg(e,c)
	return c:IsSetCard(0x109) and c:GetSequence()<5
end
-- 连接素材效果的值函数，判断是否可以作为连接素材
function c18720257.matval(e,lc,mg,c,tp)
	if not (lc:IsSetCard(0x109) and e:GetHandlerPlayer()==tp) then return false,nil end
	return true,true
end
-- 召唤效果的过滤函数，判断是否为「天气」怪兽且可通常召唤
function c18720257.sumfilter(c)
	return c:IsSetCard(0x109) and c:IsSummonable(true,nil)
end
-- 召唤效果的目标函数，检查手卡是否存在符合条件的「天气」怪兽
function c18720257.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在符合条件的「天气」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c18720257.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息为召唤类别
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 召唤效果的处理函数，从手卡选择并通常召唤一只「天气」怪兽
function c18720257.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手卡选择一只符合条件的「天气」怪兽
	local g=Duel.SelectMatchingCard(tp,c18720257.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 对选中的怪兽进行通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end
