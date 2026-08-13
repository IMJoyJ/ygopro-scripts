--マドルチェ・デセール
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以包含「魔偶甜点」怪兽的场上2只效果怪兽为对象才能发动。那些效果怪兽回到手卡·额外卡组。那之后，可以把回去的怪兽的原本攻击力合计以下的攻击力的1只「魔偶甜点」怪兽从手卡·额外卡组特殊召唤。
-- ②：这张卡在墓地存在的状态，自己墓地的「魔偶甜点」卡回到卡组·额外卡组的场合才能发动。把这张卡作为自己场上1只超量怪兽的超量素材。
local s,id,o=GetID()
-- 初始化效果注册：给本卡注册两个效果，e1为①的魔法卡发动效果（取对象回手卡/额外并可选特召「魔偶甜点」怪兽），e2为②的墓地诱发效果（作为超量素材叠放）；两者通过SetCountLimit(1,id)共用这个卡名1回合1次的使用限制。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：以包含「魔偶甜点」怪兽的场上2只效果怪兽为对象才能发动。那些效果怪兽回到手卡·额外卡组。那之后，可以把回去的怪兽的原本攻击力合计以下的攻击力的1只「魔偶甜点」怪兽从手卡·额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己墓地的「魔偶甜点」卡回到卡组·额外卡组的场合才能发动。把这张卡作为自己场上1只超量怪兽的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变成超量素材"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.matcon)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
-- 定义①效果的取对象候选过滤器：需要是场上表侧表示的效果怪兽，并且（非融合/同调/超量/连接怪兽且能加入手卡，或额外卡组怪兽且能返回额外卡组），同时能成为效果对象。
function s.tdfilter(c,e)
	return c:IsType(TYPE_EFFECT) and (not c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and c:IsAbleToHand() or c:IsAbleToExtra()) and c:IsCanBeEffectTarget(e)
		and c:IsFaceup()
end
-- 判断卡片是否属于「魔偶甜点」系列（卡名含有0x71对应的字段）。
function s.filter(c,e)
	return c:IsSetCard(0x71)
end
-- 检查组内是否存在至少1只「魔偶甜点」怪兽，用于保证选择的2只效果怪兽中包含「魔偶甜点」怪兽。
function s.gcheck(g)
	return g:IsExists(s.filter,1,nil)
end
-- 定义特殊召唤候选过滤器：必须是「魔偶甜点」怪兽，可被特殊召唤，攻击力不高于atk（返回怪兽的原本攻击力合计），且根据所在位置（手卡或额外卡组）满足对应的召唤区域空位要求。
function s.spfilter(c,e,tp,atk)
	return c:IsSetCard(0x71) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsAttackBelow(atk)
		-- 当候选怪兽位于手卡时，要求我方场上有空余的怪兽区域可供特殊召唤。
		and (c:IsLocation(LOCATION_HAND) and Duel.GetMZoneCount(tp)>0
			-- 当候选怪兽位于额外卡组时，要求我方场上有可供额外卡组怪兽特殊召唤的区域（额外怪兽区或可用的主怪兽区）。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- e1的target函数：发动时从双方怪兽区选择2只满足s.tdfilter且其中至少1只为「魔偶甜点」怪兽的效果怪兽作为对象，并登记效果处理的操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取双方怪兽区域中所有满足s.tdfilter条件的表侧效果怪兽，作为发动时选择对象的候选组。
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2) end
	-- 向操作玩家显示“请选择要返回手牌的卡”的选择提示框，用于选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
	-- 将玩家选择的2张卡登记为当前连锁的对象（取对象效果的目标）。
	Duel.SetTargetCard(sg)
	-- 登记操作信息：本次效果处理涉及回卡组/额外卡组（CATEGORY_TODECK），对象为已选中的卡，数量为其张数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetCount(),0,0)
end
-- 效果处理时的对象筛选过滤器：从原对象中选出仍然与该效果关联、表侧表示且为效果怪兽的卡，这些卡才会执行返回手卡/额外。
function s.rtfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 执行①效果处理：将对象怪兽返回持有者手卡/额外卡组；之后若存在符合条件的「魔偶甜点」怪兽，可由玩家选择是否特殊召唤1只攻击力不超过返回怪兽原本攻击力合计的「魔偶甜点」怪兽。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁中记录的对象卡组，并用s.rtfilter过滤，得到实际仍应返回手卡/额外的对象。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.rtfilter,nil,e)
	-- 将过滤后的对象怪兽返回持有者手卡（额外卡组怪兽因不能加入手卡而实际返回额外卡组）。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 获取上一步Duel.SendtoHand实际移动过的卡片组，用于判断哪些卡真正返回了手卡/额外。
	local tg=Duel.GetOperatedGroup()
	if tg:GetCount()==0 then return end
	local sg=tg:Filter(Card.IsLocation,nil,LOCATION_HAND+LOCATION_EXTRA)
	local atk=sg:GetSum(Card.GetBaseAttack)
	-- 检查是否存在满足s.spfilter条件的「魔偶甜点」怪兽，并让玩家选择是否发动“那之后”的特殊召唤。
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e,tp,atk) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 显示“请选择要特殊召唤的卡”的选择提示框。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡或额外卡组中选择1只满足s.spfilter的「魔偶甜点」怪兽。
		local ssg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e,tp,atk)
		if ssg:GetCount()>0 then
			-- 中断当前效果处理，使后续的特殊召唤作为独立处理，保证“那之后”的时点正确。
			Duel.BreakEffect()
			-- 将选中的「魔偶甜点」怪兽以表侧攻击表示特殊召唤到控制者场上。
			Duel.SpecialSummon(ssg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 定义②效果的触发条件过滤器：事件涉及的卡必须是之前由己方控制、从墓地回到卡组/额外卡组的「魔偶甜点」卡。
function s.cfilter(c,e,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsSetCard(0x71) and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- ②效果的发动条件：当自己墓地的「魔偶甜点」卡回到卡组/额外卡组的事件发生时，此效果可以发动。
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,e,tp)
end
-- 定义超量怪兽的选择条件：我方场上表侧表示的超量怪兽。
function s.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- ②效果的target函数：发动时检查我方场上有表侧表示超量怪兽且此卡可作为超量素材，并登记这张卡将离开墓地的操作信息。
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动的合法性检查：存在可叠放的表侧超量怪兽且墓地的这张卡可以作为超量素材时，才允许发动②效果。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsCanOverlay() end
	-- 登记操作信息：效果处理时墓地的这张卡将离开墓地（用于“作为超量素材”的移动）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 执行②效果处理：选择我方场上1只表侧表示超量怪兽，将墓地的这张卡作为超量素材叠放在其下方。
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 效果处理时再次确认：场上仍存在可叠放的表侧超量怪兽，且这张卡仍可作为超量素材。
	if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) and c:IsCanOverlay() then
		-- 显示“请选择表侧表示的卡”的提示框，用于选择要叠放超量素材的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 从我方场上选择1只表侧表示超量怪兽作为叠放目标。
		local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
		-- 为选中的超量怪兽显示被选为对象的动画效果，并记录其成为对象。
		Duel.HintSelection(tg)
		local tc=tg:GetFirst()
		-- 将墓地的这张卡作为超量素材叠放在选中的超量怪兽下方。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
