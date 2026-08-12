--罪宝の囁き
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只幻想魔族·魔法师族怪兽为对象才能发动。那只表侧表示怪兽回到手卡·额外卡组。那之后，自己的墓地·除外状态的1只幻想魔族·魔法师族怪兽特殊召唤。
-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（发动时回手/额外并特召）和②效果（因怪兽效果发动送墓时盖放）
function s.initial_effect(c)
	-- ①：以自己场上1只幻想魔族·魔法师族怪兽为对象才能发动。那只表侧表示怪兽回到手卡·额外卡组。那之后，自己的墓地·除外状态的1只幻想魔族·魔法师族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回手卡·额外卡组后特殊召唤"
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示、可回到手卡或额外卡组的幻想魔族·魔法师族怪兽，且此时墓地或除外状态存在可特殊召唤的幻想魔族·魔法师族怪兽，并确保该怪兽离场后有可用的怪兽区域
function s.thfilter(c,e,tp)
	-- 检查卡片是否为表侧表示的幻想魔族或魔法师族怪兽，是否可以回到手卡或额外卡组，且其离场后能空出至少1个怪兽区域
	return c:IsFaceup() and c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER) and (c:IsAbleToHand() or c:IsAbleToExtra()) and Duel.GetMZoneCount(tp,c)>0
		-- 检查自己的墓地或除外状态是否存在至少1只满足特召条件的幻想魔族或魔法师族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
end
-- 过滤墓地或除外状态中可以特殊召唤的幻想魔族·魔法师族怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与对象选择，检查是否存在符合条件的对象，提示玩家选择并将其设为效果对象，设置操作信息为回手卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.thfilter(chkc,e,tp) end
	-- 检查场上是否存在可以作为此效果对象的幻想魔族或魔法师族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要返回手卡或额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，表明此效果包含将选中的1张卡送回手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果的处理函数，将选中的怪兽送回手卡或额外卡组，若成功且有空余怪兽区域，则从墓地或除外状态选择1只幻想魔族·魔法师族怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() or not tc:IsType(TYPE_MONSTER) then return end
	-- 将对象怪兽送回手卡（或额外卡组），若成功且此时自己场上有可用的怪兽区域
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND+LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取自己墓地或除外状态中满足特召条件且不受王家长眠之谷影响的幻想魔族·魔法师族怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
		if g:GetCount()>0 then
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前效果处理，使后续的特殊召唤与前面的回手卡处理不视为同时进行
			Duel.BreakEffect()
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②效果的发动条件检查，判断此卡是否是作为怪兽效果发动的代价（Cost）被送去墓地
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- ②效果的发动准备，检查此卡是否可以盖放到场上，并设置操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置连锁操作信息，表明此效果包含将墓地的此卡移出墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果的处理函数，若此卡仍存在于墓地，则将其在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡在自己场上盖放
		Duel.SSet(tp,c)
	end
end
