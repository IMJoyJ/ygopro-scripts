--アームド・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「武装龙」怪兽
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡特殊召唤成功的场合才能发动。选自己墓地1只龙族怪兽，持有那个等级以下的等级的对方场上的怪兽全部破坏。
-- ②：这张卡战斗破坏怪兽时才能发动。这张卡得到以下效果。
-- ●双方的主要阶段，把这张卡解放才能发动。从额外卡组把1只「元素英雄」融合怪兽无视召唤条件特殊召唤。
function c31817415.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为89943723的怪兽和1个满足过滤条件的怪兽为融合素材
	aux.AddFusionProcCodeFun(c,89943723,aux.FilterBoolFunction(Card.IsFusionSetCard,0x111),1,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡的特殊召唤条件为必须通过融合召唤
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ①：这张卡特殊召唤成功的场合才能发动。选自己墓地1只龙族怪兽，持有那个等级以下的等级的对方场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31817415,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c31817415.destg)
	e1:SetOperation(c31817415.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽时才能发动。这张卡得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c31817415.regcon)
	e2:SetOperation(c31817415.regop)
	c:RegisterEffect(e2)
	-- ●双方的主要阶段，把这张卡解放才能发动。从额外卡组把1只「元素英雄」融合怪兽无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31817415,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCondition(c31817415.spcon)
	e3:SetCost(c31817415.spcost)
	e3:SetTarget(c31817415.sptg)
	e3:SetOperation(c31817415.spop)
	c:RegisterEffect(e3)
end
c31817415.material_setcode=0x8
-- 过滤满足条件的墓地龙族怪兽，要求其等级大于等于1且存在满足破坏条件的对方场上怪兽
function c31817415.filter(c,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevelAbove(1)
		-- 检查是否存在满足破坏条件的对方场上怪兽
		and Duel.IsExistingMatchingCard(c31817415.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetLevel())
end
-- 过滤满足等级条件的对方场上怪兽
function c31817415.desfilter(c,lv)
	return c:IsFaceup() and c:IsLevelBelow(lv)
end
-- 设置效果处理时要破坏的怪兽组
function c31817415.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的墓地龙族怪兽组
	local g=Duel.GetMatchingGroup(c31817415.filter,tp,LOCATION_GRAVE,0,nil,tp)
	if chk==0 then return #g>0 end
	local _,lv=g:GetMaxGroup(Card.GetLevel)
	-- 获取满足等级条件的对方场上怪兽组
	local dg=Duel.GetMatchingGroup(c31817415.desfilter,tp,0,LOCATION_MZONE,nil,lv)
	-- 设置连锁操作信息，指定要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
-- 执行效果处理，选择墓地龙族怪兽并破坏对方场上满足等级条件的怪兽
function c31817415.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取满足条件的墓地龙族怪兽组
	local g=Duel.GetMatchingGroup(c31817415.filter,tp,LOCATION_GRAVE,0,nil,tp)
	if #g==0 then return end
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local tg=g:Select(tp,1,1,nil)
	-- 显示所选卡被选为对象的动画效果
	Duel.HintSelection(tg)
	-- 获取满足等级条件的对方场上怪兽组
	local dg=Duel.GetMatchingGroup(c31817415.desfilter,tp,0,LOCATION_MZONE,nil,tg:GetFirst():GetLevel())
	-- 以效果原因破坏满足条件的对方场上怪兽
	Duel.Destroy(dg,REASON_EFFECT)
end
-- 判断该卡是否参与战斗且未使用过效果
function c31817415.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetFlagEffect(31817416)==0
end
-- 为该卡注册标记，表示效果已适用
function c31817415.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToChain() then
		c:RegisterFlagEffect(31817416,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(31817415,2))  --"「武装新宇侠」效果适用中"
	end
end
-- 判断该卡是否已使用过效果且当前处于主要阶段
function c31817415.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否已使用过效果且当前处于主要阶段
	return c:GetFlagEffect(31817416)>0 and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 设置效果发动时的费用，需解放该卡并确保额外卡组有符合条件的融合怪兽
function c31817415.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable()
		-- 检查额外卡组是否存在满足条件的融合怪兽
		and Duel.IsExistingMatchingCard(c31817415.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 解放该卡作为发动费用
	Duel.Release(c,REASON_COST)
end
-- 过滤满足条件的额外卡组融合怪兽
function c31817415.spfilter(c,e,tp,rc)
	-- 检查额外卡组是否存在满足条件的融合怪兽
	return c:IsSetCard(0x3008) and c:IsType(TYPE_FUSION) and Duel.GetLocationCountFromEx(tp,tp,rc,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置效果处理时要特殊召唤的怪兽组
function c31817415.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，指定要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行效果处理，从额外卡组特殊召唤符合条件的融合怪兽
function c31817415.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的额外卡组融合怪兽组
	local g=Duel.GetMatchingGroup(c31817415.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,nil)
	if #g==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,1,nil)
	-- 将选中的融合怪兽特殊召唤到场上
	Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
end
