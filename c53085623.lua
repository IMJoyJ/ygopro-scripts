--水精鱗の深影隊
-- 效果：
-- 这个卡名在规则上也当作「海皇」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：把1张手卡丢弃去墓地才能发动。自己场上的全部水属性怪兽的等级直到回合结束时变成7星。
-- ②：这张卡为让水属性怪兽的效果发动而被送去墓地的场合发动。除「水精鳞的深影队」外的4星以下的1只「海皇」怪兽或「水精鳞」怪兽从卡组特殊召唤。这个回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②的效果
function s.initial_effect(c)
	-- ①：把1张手卡丢弃去墓地才能发动。自己场上的全部水属性怪兽的等级直到回合结束时变成7星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"等级变更"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.lvcost)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	-- ②：这张卡为让水属性怪兽的效果发动而被送去墓地的场合发动。除「水精鳞的深影队」外的4星以下的1只「海皇」怪兽或「水精鳞」怪兽从卡组特殊召唤。这个回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 用于判断手牌是否满足丢弃条件
function s.lvcfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsDiscardable()
end
-- 检查是否有满足条件的手牌并进行丢弃操作
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的手牌
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvcfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃手牌操作
	Duel.DiscardHand(tp,s.lvcfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 用于筛选场上符合条件的水属性怪兽
function s.lvfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup() and c:IsLevelAbove(1) and not c:IsLevel(7)
end
-- 检查场上是否存在符合条件的水属性怪兽
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在符合条件的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 将符合条件的水属性怪兽等级变为7星
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取所有符合条件的水属性怪兽
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历所有符合条件的水属性怪兽
	for tc in aux.Next(g) do
		-- 设置水属性怪兽等级变为7星的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(7)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判断是否为水属性怪兽发动的效果导致被送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsAttribute(ATTRIBUTE_WATER)
end
-- 筛选可特殊召唤的「海皇」或「水精鳞」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x74,0x77) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsLevelBelow(4) and not c:IsCode(id)
end
-- 设置特殊召唤的处理信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作并设置后续限制效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择符合条件的怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置不能从额外卡组特殊召唤非水属性怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制非水属性怪兽从额外卡组特殊召唤
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsLocation(LOCATION_EXTRA)
end
