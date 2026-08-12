--大騎甲虫インヴィンシブル・アトラス
-- 效果：
-- 昆虫族怪兽2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：连接召唤的这张卡在攻击力是3000以下的场合不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：只要这张卡在怪兽区域存在，自己不是昆虫族怪兽不能特殊召唤。
-- ③：可以把自己场上1只昆虫族怪兽解放，从以下效果选择1个发动。
-- ●从卡组把1只「骑甲虫」怪兽特殊召唤。
-- ●这张卡的攻击力直到回合结束时上升2000。
function c38229962.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用至少2张满足过滤条件的昆虫族连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_INSECT),2)
	-- ①：连接召唤的这张卡在攻击力是3000以下的场合不会成为对方的效果的对象，不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetCondition(c38229962.condition)
	-- 设置效果值为不会成为对方效果的对象的过滤函数
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置效果值为不会被对方效果破坏的过滤函数
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己不是昆虫族怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c38229962.splimit)
	c:RegisterEffect(e3)
	-- ③：可以把自己场上1只昆虫族怪兽解放，从以下效果选择1个发动。●从卡组把1只「骑甲虫」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(38229962,0))  --"从卡组特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,38229962)
	e4:SetCost(c38229962.spcost)
	e4:SetTarget(c38229962.sptg)
	e4:SetOperation(c38229962.spop)
	c:RegisterEffect(e4)
	-- ③：可以把自己场上1只昆虫族怪兽解放，从以下效果选择1个发动。●这张卡的攻击力直到回合结束时上升2000。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(38229962,1))  --"这张卡攻击力上升"
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,38229962)
	e5:SetCost(c38229962.atkcost)
	e5:SetTarget(c38229962.atktg)
	e5:SetOperation(c38229962.atkop)
	c:RegisterEffect(e5)
end
-- 条件函数：判断此卡是否为连接召唤且攻击力不超过3000
function c38229962.condition(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:IsAttackBelow(3000)
end
-- 限制函数：判断目标怪兽是否不是昆虫族
function c38229962.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_INSECT)
end
-- 过滤函数：判断目标卡是否为昆虫族且为己方控制或表侧表示
function c38229962.costfilter(c,tp)
	return c:IsRace(RACE_INSECT) and (c:IsControler(tp) or c:IsFaceup())
end
-- 过滤函数：判断目标卡是否为昆虫族且为己方控制或表侧表示且场上存在可用怪兽区
function c38229962.spcostfilter(c,tp)
	-- 判断目标卡是否为昆虫族且为己方控制或表侧表示且场上存在可用怪兽区
	return c38229962.costfilter(c,tp) and Duel.GetMZoneCount(tp,c)>0
end
-- 起动效果的费用处理函数：检查并选择1张满足条件的昆虫族怪兽进行解放
function c38229962.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c38229962.spcostfilter,1,nil,tp) end
	-- 选择满足条件的1张昆虫族怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c38229962.spcostfilter,1,1,nil,tp)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 过滤函数：判断目标卡是否为骑甲虫卡组且可特殊召唤
function c38229962.spfilter(c,e,tp)
	return c:IsSetCard(0x170) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 起动效果的目标处理函数：检查卡组中是否存在满足条件的骑甲虫怪兽
function c38229962.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的骑甲虫怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c38229962.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示对方选择了此效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 起动效果的处理函数：从卡组选择1只骑甲虫怪兽特殊召唤
function c38229962.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的骑甲虫怪兽
		local g=Duel.SelectMatchingCard(tp,c38229962.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 执行特殊召唤操作
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 攻击力上升效果的费用处理函数：检查并选择1张满足条件的昆虫族怪兽进行解放
function c38229962.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c38229962.costfilter,1,e:GetHandler(),tp) end
	-- 选择满足条件的1张昆虫族怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c38229962.costfilter,1,1,e:GetHandler(),tp)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 攻击力上升效果的目标处理函数：提示对方选择了此效果
function c38229962.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示对方选择了此效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 攻击力上升效果的处理函数：使此卡攻击力上升2000点直到回合结束
function c38229962.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 设置此卡攻击力上升2000点直到回合结束
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
