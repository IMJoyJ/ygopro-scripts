--アンデット・リボーン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己或者对方的墓地1只不死族怪兽为对象才能发动。从自己的卡组·额外卡组把1只那只怪兽的同名怪兽除外，作为对象的怪兽在自己场上特殊召唤。
-- ②：这张卡在墓地存在的场合才能发动。选除外的1只自己的不死族怪兽回到卡组，这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c19942835.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：以自己或者对方的墓地1只不死族怪兽为对象才能发动。从自己的卡组·额外卡组把1只那只怪兽的同名怪兽除外，作为对象的怪兽在自己场上特殊召唤。
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
-- 过滤函数：判断卡片卡号与指定怪兽相同且能够除外，用于从卡组·额外卡组检索同名怪兽。
function c19942835.rmfilter(c,sc)
	return c:GetCode()==sc:GetCode() and c:IsAbleToRemove()
end
-- 过滤函数：判断墓地怪兽是否为不死族且可特殊召唤，并确认自己卡组·额外卡组存在同名可除外的怪兽。
function c19942835.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己卡组·额外卡组是否存在至少1张与候选怪兽同名的可除外怪兽。
		and Duel.IsExistingMatchingCard(c19942835.rmfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c)
end
-- ①效果的发动条件与取对象判定：需要自己主要怪兽区有空位，且双方墓地存在可作为对象的不死族怪兽；指定对象时确认其在墓地且满足特殊召唤条件。
function c19942835.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c19942835.spfilter(chkc,e,tp) end
	-- 发动时检查自己主要怪兽区是否有空位，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地是否存在至少1只可作为对象且满足特殊召唤条件的不死族怪兽。
		and Duel.IsExistingTarget(c19942835.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 弹出选择提示“请选择要特殊召唤的卡”，用于提示玩家选择墓地对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从双方墓地选择1只满足条件的不死族怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c19942835.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置连锁处理信息：包含特殊召唤操作，对象为已选择的墓地怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置连锁处理信息：包含除外操作，预计从自己卡组·额外卡组除外1张卡，具体卡在效果处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ①效果处理：获取对象怪兽，从自己卡组·额外卡组选择1张同名可除外怪兽；若对象仍与效果关联且除外成功，则将该对象怪兽特殊召唤到自己场上。
function c19942835.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的墓地对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 弹出选择提示“请选择要除外的卡”，用于下一步从卡组·额外卡组选择除外卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己卡组·额外卡组选择1张与对象怪兽同名的可除外卡，并取回该卡。
	local rc=Duel.SelectMatchingCard(tp,c19942835.rmfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tc):GetFirst()
	-- 判定对象怪兽仍与效果关联、选中的同名卡存在，且该卡被表侧表示除外成功并处于除外区。
	if tc:IsRelateToEffect(e) and rc and Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)>0 and rc:IsLocation(LOCATION_REMOVED) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：判断除外区卡片是否满足表侧表示、不死族且能回到卡组，用于②效果选择返回卡组的目标。
function c19942835.setfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeck()
end
-- ②效果的发动条件：这张卡在墓地存在且可盖放，并且自己除外区存在至少1张满足回卡组条件的不死族怪兽。
function c19942835.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable()
		-- 检查自己除外区是否存在至少1张表侧、不死族且可回到卡组的怪兽。
		and Duel.IsExistingMatchingCard(c19942835.setfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置连锁处理信息：包含涉及墓地的操作（CATEGORY_LEAVE_GRAVE），对象为墓地的这张卡，用于适配王家长眠之谷等效果。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：从自己除外区选1只不死族怪兽返回卡组洗牌，然后这张卡在自己场上盖放；若盖放成功，则给这张卡附加离场时除外的效果。
function c19942835.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 弹出选择提示“请选择要返回卡组的卡”，用于选择除外区回卡组的不死族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己除外区选择1只满足条件的不死族怪兽，准备返回卡组。
	local g=Duel.SelectMatchingCard(tp,c19942835.setfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 为所选卡显示被选为对象的动画，并记录其为广义对象，供其他卡互动检测。
		Duel.HintSelection(g)
		-- 若怪兽返回卡组成功，且这张卡仍与效果关联并可以盖放，则将墓地的这张卡盖放到自己魔法·陷阱区。
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
