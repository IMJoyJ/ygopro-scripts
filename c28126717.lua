--ふわんだりぃずと謎の地図
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只1星「随风旅鸟」怪兽给对方观看，和给人观看的怪兽卡名不同的1张「随风旅鸟」卡从卡组除外。那之后，给人观看的怪兽召唤。
-- ②：对方对怪兽的召唤成功的场合才能发动。自己把1只「随风旅鸟」怪兽召唤。
function c28126717.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己主要阶段才能发动。从手卡把1只1星「随风旅鸟」怪兽给对方观看，和给人观看的怪兽卡名不同的1张「随风旅鸟」卡从卡组除外。那之后，给人观看的怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28126717,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,28126717)
	e1:SetTarget(c28126717.rmtg)
	e1:SetOperation(c28126717.rmop)
	c:RegisterEffect(e1)
	-- ②：对方对怪兽的召唤成功的场合才能发动。自己把1只「随风旅鸟」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28126717,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,28126718)
	e2:SetCondition(c28126717.sumcon)
	e2:SetTarget(c28126717.sumtg)
	e2:SetOperation(c28126717.sumop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选手卡中满足条件的1星随风旅鸟怪兽，包括：等级为1、属于随风旅鸟卡组、可以通常召唤、未公开，并且卡组中存在一张与该怪兽不同名的随风旅鸟卡可被除外。
function c28126717.rmcfilter(c,tp)
	return c:IsLevel(1) and c:IsSetCard(0x16d) and c:IsSummonable(true,nil) and not c:IsPublic()
		-- 检查卡组中是否存在一张与已选怪兽不同名的随风旅鸟卡，用于确认是否可以执行除外操作。
		and Duel.IsExistingMatchingCard(c28126717.rmfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 过滤函数，用于筛选卡组中满足条件的随风旅鸟卡，包括：属于随风旅鸟卡组、与指定卡号不同、可以被除外。
function c28126717.rmfilter(c,code)
	return c:IsSetCard(0x16d) and not c:IsCode(code) and c:IsAbleToRemove()
end
-- 效果的发动条件判断函数，检查手卡中是否存在满足条件的1星随风旅鸟怪兽，用于确认是否可以发动效果。
function c28126717.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的1星随风旅鸟怪兽，用于确认是否可以发动效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c28126717.rmcfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 设置效果处理时将要处理的召唤对象，即手卡中的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置效果处理时将要处理的除外对象，即卡组中1张随风旅鸟卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，执行以下操作：选择手卡中的1只1星随风旅鸟怪兽给对方确认，然后从卡组中选择一张与该怪兽不同名的随风旅鸟卡除外，如果成功则将确认的怪兽通常召唤。
function c28126717.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡中选择满足条件的1只1星随风旅鸟怪兽。
	local g1=Duel.SelectMatchingCard(tp,c28126717.rmcfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	if g1:GetCount()>0 then
		-- 向对方玩家确认所选怪兽的卡面。
		Duel.ConfirmCards(1-tp,g1)
		-- 提示玩家选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从卡组中选择一张与已选怪兽不同名的随风旅鸟卡。
		local g2=Duel.SelectMatchingCard(tp,c28126717.rmfilter,tp,LOCATION_DECK,0,1,1,nil,g1:GetFirst():GetCode())
		-- 将选中的卡从卡组除外，如果成功则继续执行后续操作。
		if Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)>0 then
			-- 中断当前效果处理，使之后的效果视为不同时处理。
			Duel.BreakEffect()
			-- 将确认的怪兽通常召唤。
			Duel.Summon(tp,g1:GetFirst(),true,nil)
		end
	end
end
-- 触发效果的条件判断函数，判断是否为对方召唤成功。
function c28126717.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤函数，用于筛选满足条件的随风旅鸟怪兽，包括：属于随风旅鸟卡组、可以通常召唤。
function c28126717.sumfilter(c)
	return c:IsSetCard(0x16d) and c:IsSummonable(true,nil)
end
-- 效果的发动条件判断函数，检查手卡或场上是否存在满足条件的随风旅鸟怪兽，用于确认是否可以发动效果。
function c28126717.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在满足条件的随风旅鸟怪兽，用于确认是否可以发动效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c28126717.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置效果处理时将要处理的召唤对象，即1只随风旅鸟怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果的处理函数，执行以下操作：选择手卡或场上的1只随风旅鸟怪兽，然后将其通常召唤。
function c28126717.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手卡或场上选择满足条件的1只随风旅鸟怪兽。
	local g=Duel.SelectMatchingCard(tp,c28126717.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽通常召唤。
		Duel.Summon(tp,tc,true,nil)
	end
end
