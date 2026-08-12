--アンデット・リボーン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己或者对方的墓地1只不死族怪兽为对象才能发动。从自己的卡组·额外卡组把1只那只怪兽的同名怪兽除外，作为对象的怪兽在自己场上特殊召唤。
-- ②：这张卡在墓地存在的场合才能发动。选除外的1只自己的不死族怪兽回到卡组，这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c19942835.initial_effect(c)
	-- ①：以自己或者对方的墓地1只不死族怪兽为对象才能发动。从自己的卡组·额外卡组把1只那只怪兽的同名怪兽除外，作为对象的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19942835,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,19942835)
	e1:SetTarget(c19942835.target)
	e1:SetOperation(c19942835.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合才能发动。选除外的1只自己的不死族怪兽回到卡组，这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19942835,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,19942835)
	e2:SetTarget(c19942835.settg)
	e2:SetOperation(c19942835.setop)
	c:RegisterEffect(e2)
end
-- 用于过滤满足条件的同名怪兽卡片，用于除外操作
function c19942835.rmfilter(c,sc)
	return c:GetCode()==sc:GetCode() and c:IsAbleToRemove()
end
-- 用于过滤满足条件的不死族怪兽卡片，用于特殊召唤操作
function c19942835.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查玩家的卡组和额外卡组中是否存在与目标怪兽同名且可除外的怪兽
		and Duel.IsExistingMatchingCard(c19942835.rmfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c)
end
-- 设置效果目标为墓地中的不死族怪兽，检查是否有满足条件的怪兽可特殊召唤
function c19942835.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c19942835.spfilter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在满足条件的不死族怪兽
		and Duel.IsExistingTarget(c19942835.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c19942835.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息为除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 处理效果发动，选择要除外的同名怪兽并进行特殊召唤
function c19942835.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择要除外的同名怪兽
	local rc=Duel.SelectMatchingCard(tp,c19942835.rmfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tc):GetFirst()
	-- 确认目标怪兽和除外怪兽均有效且成功除外
	if tc:IsRelateToEffect(e) and rc and Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)>0 and rc:IsLocation(LOCATION_REMOVED) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 用于过滤满足条件的除外不死族怪兽卡片，用于返回卡组操作
function c19942835.setfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeck()
end
-- 设置效果目标为除外的不死族怪兽，检查是否有满足条件的怪兽可返回卡组
function c19942835.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable()
		-- 检查玩家除外区域是否存在满足条件的不死族怪兽
		and Duel.IsExistingMatchingCard(c19942835.setfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息为离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 处理效果发动，选择要返回卡组的除外怪兽并进行盖放
function c19942835.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择要返回卡组的除外怪兽
	local g=Duel.SelectMatchingCard(tp,c19942835.setfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 显示被选为对象的怪兽动画
		Duel.HintSelection(g)
		-- 确认怪兽成功返回卡组且卡牌成功盖放
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
			-- 当盖放的此卡从场上离开时，将其除外
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1)
		end
	end
end
