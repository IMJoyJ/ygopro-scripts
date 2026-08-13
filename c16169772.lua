--インスタント・コンタクト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：支付1000基本分才能发动。7星以下的1只「元素英雄」怪兽或者「新空间侠」怪兽无视召唤条件从额外卡组特殊召唤。自己的场上以及墓地没有「元素英雄 新宇侠」存在的场合，这个效果特殊召唤的怪兽不能攻击，效果无效化，结束阶段回到持有者的额外卡组。
local s,id,o=GetID()
-- 定义卡片的初始化函数：登记卡名关联信息和系列字段，创建效果 e1 并设置分类、类型、发动时点、1回合1次限制、代价、对象与处理函数，最后将e1注册到卡片上。
function s.initial_effect(c)
	-- 将卡号89943723（元素英雄 新宇侠）登记到卡片代码列表中，使本卡效果文本中记载的这张卡能被相关检索/判定识别。
	aux.AddCodeList(c,89943723)
	-- 将系列字段0x3008（元素英雄）登记到卡片记载的怪兽系列列表中，用于支持“「元素英雄」怪兽”的系列判定。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 对应效果原文：‘这个卡名的卡在1回合只能发动1张。①：支付1000基本分才能发动。7星以下的1只「元素英雄」怪兽或者「新空间侠」怪兽无视召唤条件从额外卡组特殊召唤。自己的场上以及墓地没有「元素英雄 新宇侠」存在的场合，这个效果特殊召唤的怪兽不能攻击，效果无效化，结束阶段回到持有者的额外卡组。’
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 定义代价函数：在发动前检查并支付1000基本分作为COST。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段（chk==0）时，返回自己是否能支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分，完成cost。
	Duel.PayLPCost(tp,1000)
end
-- 定义额外卡组怪兽的筛选条件：等级7以下且是「元素英雄」系列，或是「新空间侠」系列，并且满足从额外卡组特殊召唤的场所条件和召唤条件。
function s.spfilter(c,e,tp)
	return (c:IsLevelBelow(7) and c:IsSetCard(0x3008) or c:IsSetCard(0x1f))
		-- 额外判定：自己场上有可供额外卡组怪兽使用的空格，且该怪兽当前可以被无视召唤条件地特殊召唤。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 定义效果发动时点的目标函数：检查额外卡组是否存在符合条件的可特殊召唤怪兽，并设置本次效果将进行特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：检查额外卡组中是否存在至少1只满足条件（等级7以下的元素英雄或新空间侠且可特召）的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：本次连锁将从额外卡组特殊召唤1只怪兽，效果分类为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义过滤函数：判断一张卡是否为「元素英雄 新宇侠」，且处于表侧表示或墓地中。
function s.cfilter(c)
	return c:IsCode(89943723) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 效果处理：先让玩家从额外卡组选择符合条件的1只怪兽；若选择后特殊召唤成功，且自己场上（表侧）和墓地没有「元素英雄 新宇侠」，则为该怪兽附加不能攻击、效果无效化，并设置结束阶段返回持有者额外卡组的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己的额外卡组选出1只满足条件的怪兽，并取第一张作为tc。
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	-- 将选择的怪兽以表侧表示、无视召唤条件地加入特殊召唤处理，并确认这步特殊召唤是否成功。
	if Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
		-- 若上一步特殊召唤成功，且自己的场上（表侧）以及墓地没有「元素英雄 新宇侠」，则进入附加限制和结束阶段回卡组的处理。
		and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) then
		local c=e:GetHandler()
		-- 对应效果原文：‘这个效果特殊召唤的怪兽不能攻击’。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 对应效果原文：‘效果无效化’。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e3,true)
		-- 对应效果原文：‘结束阶段回到持有者的额外卡组。’
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetCountLimit(1)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetLabelObject(tc)
		e4:SetCondition(s.tdcon)
		e4:SetOperation(s.tdop)
		-- 将结束阶段回额外卡组的持续效果注册给当前玩家tp，使其能在结束阶段时触发。
		Duel.RegisterEffect(e4,tp)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
	-- 完成所有SpecialSummonStep步骤，正式完成特殊召唤处理。
	Duel.SpecialSummonComplete()
end
-- 定义结束阶段回卡组效果的条件：被标记的怪兽仍在场上且仍带有对应flag时满足；若怪兽已离场或flag消失，则重置该效果并不再处理。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or tc:GetFlagEffect(id)==0 then
		e:Reset()
		return false
	end
	return true
end
-- 定义结束阶段回卡组的操作：将被标记的怪兽返回持有者的额外卡组（卡组），并洗切。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc then
		-- 将被标记的怪兽以效果原因送回持有者的卡组/额外卡组，并需要洗牌。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
