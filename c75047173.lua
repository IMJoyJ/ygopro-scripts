--フェイバリット・コンタクト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上·墓地·除外状态让融合怪兽决定的融合素材怪兽用喜欢的顺序回到卡组下面，把以「英雄」怪兽为融合素材的那1只融合怪兽从额外卡组无视召唤条件特殊召唤。这个效果让「元素英雄 新宇侠」回到卡组的场合，双方不能让这个效果特殊召唤的怪兽回到额外卡组。
local s,id,o=GetID()
-- 注册卡片的效果，设置分类为回到卡组和特殊召唤，类型为魔法·陷阱卡的发动，时点为自由时点，并设置同名卡一回合只能发动一次的誓约限制。
function s.initial_effect(c)
	-- 将「元素英雄 新宇侠」的卡片密码加入到此卡的关联卡片列表中。
	aux.AddCodeList(c,89943723)
	-- 将「元素英雄」系列怪兽加入到此卡的关联系列怪兽列表中。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·场上·墓地·除外状态让融合怪兽决定的融合素材怪兽用喜欢的顺序回到卡组下面，把以「英雄」怪兽为融合素材的那1只融合怪兽从额外卡组无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.fstg)
	e1:SetOperation(s.fsop)
	c:RegisterEffect(e1)
end
-- 过滤融合素材：手卡、墓地、场上或除外状态的怪兽，且必须能回到卡组且不受效果免疫。
function s.fsfilter1(c,e)
	return (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) and c:IsType(TYPE_MONSTER)
		and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以特殊召唤的融合怪兽，且该融合怪兽必须以「英雄」怪兽为融合素材。
function s.fsfilter2(c,e,tp,m,chkf)
	-- 检查卡片是否为融合怪兽，且其融合素材中是否记有「英雄」系列。
	if not (c:IsType(TYPE_FUSION) and aux.IsMaterialListSetCard(c,0x8)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)) then return false end
	-- 设置额外的融合素材检查函数，若怪兽自身没有特定的英雄融合检查，则使用自定义的s.fscheck。
	aux.FCheckAdditional=c.hero_fusion_check or s.fscheck
	local res=c:CheckFusionMaterial(m,nil,chkf,true)
	-- 清空额外的融合素材检查函数。
	aux.FCheckAdditional=nil
	return res
end
-- 自定义融合素材检查：选取的素材中必须包含至少1张「英雄」系列怪兽。
function s.fscheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionSetCard,1,nil,0x8)
end
-- 过滤需要向对方确认的素材卡：处于手卡、墓地、除外状态，或者是场上里侧表示的卡。
function s.fscfilter(c)
	return c:IsLocation(LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED) or (c:IsLocation(LOCATION_MZONE) and c:IsFacedown())
end
-- 效果发动的Target函数，检查是否存在可用的融合素材和可特殊召唤的融合怪兽，并设置操作信息。
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp|0x200
		-- 获取自己手卡、场上、墓地、除外状态中所有满足条件的可用融合素材怪兽。
		local mg=Duel.GetMatchingGroup(s.fsfilter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
		-- 检查额外卡组中是否存在至少1只可以使用上述素材进行特殊召唤的融合怪兽。
		return Duel.IsExistingMatchingCard(s.fsfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf) end
	-- 设置连锁处理的操作信息：预计将手卡、场上、墓地或除外状态的卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	-- 设置连锁处理的操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的Operation函数，执行素材返回卡组、特殊召唤融合怪兽，并在满足条件时适用不回额外卡组的限制。
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp|0x200
	-- 获取自己手卡、场上、墓地、除外状态中所有满足条件且不受「王家长眠之谷」影响的可用融合素材怪兽。
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.fsfilter1),tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 获取额外卡组中所有可以使用当前可用素材进行特殊召唤的融合怪兽。
	local sg=Duel.GetMatchingGroup(s.fsfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,chkf)
	if sg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 针对选定的融合怪兽，设置其特定的或通用的「英雄」素材检查规则。
		aux.FCheckAdditional=tc.hero_fusion_check or s.fscheck
		-- 让玩家从可用素材中选择用于召唤该融合怪兽的融合素材。
		local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf,true)
		-- 重置额外的融合素材检查函数。
		aux.FCheckAdditional=nil
		local cf=mat:Filter(s.fscfilter,nil)
		if cf:GetCount()>0 then
			-- 将非公开状态（手卡、墓地、除外、里侧表示）的融合素材给对方确认。
			Duel.ConfirmCards(1-tp,cf)
		end
		local ng=mat:Filter(Card.IsCode,nil,89943723)
		-- 让玩家将选定的融合素材以喜欢的顺序放回持有者卡组最下方。
		aux.PlaceCardsOnDeckBottom(tp,mat)
		-- 中断当前效果处理，使后续的特殊召唤不与返回卡组同时处理。
		Duel.BreakEffect()
		-- 将选定的融合怪兽无视召唤条件表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		if ng:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
			-- 这个效果让「元素英雄 新宇侠」回到卡组的场合，双方不能让这个效果特殊召唤的怪兽回到额外卡组。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,1))  --"「至爱接触」效果适用中"
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_CANNOT_TO_DECK)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetTargetRange(1,1)
			e1:SetTarget(s.tdlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
		end
	end
end
-- 限制目标怪兽不能回到卡组（额外卡组）。
function s.tdlimit(e,c)
	return c==e:GetHandler()
end
