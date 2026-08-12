--リターン・オブ・アンデット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：选场上1只不死族怪兽除外。那之后，从那个控制者墓地选1只不死族怪兽在那持有者场上守备表示特殊召唤。
-- ②：这张卡在墓地存在的场合才能发动。选除外的1只自己的不死族怪兽回到卡组，这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c91742238.initial_effect(c)
	-- ①：选场上1只不死族怪兽除外。那之后，从那个控制者墓地选1只不死族怪兽在那持有者场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,91742238)
	e1:SetTarget(c91742238.target)
	e1:SetOperation(c91742238.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合才能发动。选除外的1只自己的不死族怪兽回到卡组，这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e2:SetDescription(aux.Stringid(91742238,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,91742239)
	e2:SetTarget(c91742238.settg)
	e2:SetOperation(c91742238.setop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示、可除外的不死族怪兽，且该怪兽离开后其控制者场上有空位，且该控制者墓地有可特召的不死族怪兽
function c91742238.rmfilter(c,e,tp)
	local p=c:GetControler()
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemove()
		-- 检查该怪兽离开场上后，其控制者的怪兽区域是否有空位
		and Duel.GetMZoneCount(p,c,p,LOCATION_REASON_TOFIELD)
		-- 检查该怪兽控制者的墓地是否存在可以特殊召唤的不死族怪兽
		and Duel.IsExistingMatchingCard(c91742238.spfilter,p,LOCATION_GRAVE,0,1,nil,e,tp,p)
end
-- 过滤墓地中可以守备表示特殊召唤到指定玩家场上的不死族怪兽
function c91742238.spfilter(c,e,tp,p)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,p)
end
-- ①号效果的发动准备，检查场上是否存在满足条件的除外对象，并设置除外和特殊召唤的操作信息
function c91742238.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只满足除外及后续特召条件的不死族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91742238.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 设置除外操作的信息，涉及双方场上的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
	-- 设置特殊召唤操作的信息，涉及双方墓地的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_GRAVE)
end
-- ①号效果的处理：选场上1只不死族怪兽除外，那之后从其控制者墓地选1只不死族怪兽在持有者场上守备表示特殊召唤
function c91742238.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择场上1只满足条件的不死族怪兽
	local rc=Duel.SelectMatchingCard(tp,c91742238.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp):GetFirst()
	-- 将选中的怪兽表侧表示除外，若除外成功则继续处理
	if rc and Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)~=0 then
		local p=rc:GetPreviousControler()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从被除外怪兽的前控制者墓地中，选择1只不受王家之谷影响且满足特召条件的不死族怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c91742238.spfilter),p,LOCATION_GRAVE,0,1,1,nil,e,tp,p)
		-- 若选出怪兽，则将其在持有者（即前控制者）场上守备表示特殊召唤
		if #g>0 then Duel.SpecialSummon(g,0,tp,p,false,false,POS_FACEUP_DEFENSE) end
	end
end
-- 过滤除外区表侧表示、可以回到卡组的不死族怪兽
function c91742238.setfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeck()
end
-- ②号效果的发动准备，检查自身是否可以盖放，以及除外区是否存在可回到卡组的自己的不死族怪兽
function c91742238.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable()
		-- 检查除外区是否存在至少1只自己的不死族怪兽可以回到卡组
		and Duel.IsExistingMatchingCard(c91742238.setfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置卡片离开墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②号效果的处理：选除外的1只自己的不死族怪兽回到卡组，这张卡在自己场上盖放，并添加离场除外的约束
function c91742238.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择除外的1只自己的不死族怪兽
	local g=Duel.SelectMatchingCard(tp,c91742238.setfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 给选中的卡片显示被选择的动画效果
		Duel.HintSelection(g)
		-- 将选中的怪兽送回卡组并洗牌，若成功且此卡仍存在于墓地，则将此卡在自己场上盖放
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
			-- 这个效果盖放的这张卡从场上离开的场合除外。
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
