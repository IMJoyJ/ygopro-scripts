--黄金郷のアンヘルカイド
-- 效果：
-- 「黄金卿 黄金国巫妖」＋不死族怪兽
-- 「黄金乡的堕落天使」1回合1次用融合召唤以及以下方法才能特殊召唤。
-- ●自己的场上或墓地有「黄金卿 黄金国巫妖」存在的状态，把自己场上1只不死族·光属性怪兽解放的场合可以从额外卡组特殊召唤。
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡从场上送去墓地的场合才能发动。从自己的卡组·额外卡组·墓地把1只「黄金国巫妖」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，启用融合召唤限制并添加融合召唤手续
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：使用卡号为95440946的怪兽和1只满足s.mfilter条件的怪兽进行融合召唤
	aux.AddFusionProcCodeFun(c,95440946,s.mfilter,1,true,true)
	-- ①：这张卡从场上送去墓地的场合才能发动。从自己的卡组·额外卡组·墓地把1只「黄金国巫妖」怪兽特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	-- 「黄金乡的堕落天使」1回合1次用融合召唤以及以下方法才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(s.splimit)
	c:RegisterEffect(e2)
	-- ●自己的场上或墓地有「黄金卿 黄金国巫妖」存在的状态，把自己场上1只不死族·光属性怪兽解放的场合可以从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ①：这张卡从场上送去墓地的场合才能发动。从自己的卡组·额外卡组·墓地把1只「黄金国巫妖」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.tgcon)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断怪兽是否为不死族
function s.mfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
-- 限制特殊召唤条件：必须是融合召唤且该玩家未使用过此效果
function s.splimit(e,se,sp,st)
	-- 必须是融合召唤且该玩家未使用过此效果
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id)==0
end
-- 判断该卡是否为融合召唤或是否已使用过效果
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:GetFlagEffect(id)>0
end
-- 注册标识效果：在特殊召唤成功时记录该效果已使用
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册标识效果：在特殊召唤成功时记录该效果已使用
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数：判断怪兽是否为不死族·光属性且可特殊召唤
function s.spfilter(c,tp,sc)
	-- 判断怪兽是否为不死族·光属性且可特殊召唤
	return c:IsRace(RACE_ZOMBIE) and c:IsAttribute(ATTRIBUTE_LIGHT) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 过滤函数：判断怪兽是否为「黄金卿 黄金国巫妖」且表侧表示
function s.cfilter(c)
	return c:IsCode(95440946) and c:IsFaceupEx()
end
-- 判断是否满足特殊召唤条件：场上或墓地有「黄金卿 黄金国巫妖」且该玩家未使用过此效果
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 场上或墓地没有「黄金卿 黄金国巫妖」或该玩家已使用过此效果
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) or Duel.GetFlagEffect(tp,id)>0 then return false end
	-- 检查是否有满足条件的怪兽可解放
	return Duel.CheckReleaseGroupEx(tp,s.spfilter,1,REASON_SPSUMMON,false,nil,tp,c)
end
-- 设置特殊召唤目标：选择1只满足条件的怪兽进行解放
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取可解放的怪兽组并筛选满足条件的怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.spfilter,nil,tp,c)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤操作：记录效果已使用并解放指定怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	local g=e:GetLabelObject()
	-- 解放指定怪兽
	Duel.Release(g,REASON_SPSUMMON)
end
-- 判断该卡是否从场上送去墓地
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数：判断怪兽是否为「黄金国巫妖」且可特殊召唤
function s.tgfilter(c,e,tp)
	return c:IsSetCard(0x1142) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and
		-- 若怪兽在主卡组则检查主怪兽区是否为空
		(not c:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp)>0
		-- 若怪兽在额外卡组则检查额外卡组是否有召唤空间
		or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 设置效果目标：检查是否有满足条件的怪兽可特殊召唤
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的怪兽可特殊召唤
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：确定要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 执行效果：选择并特殊召唤1只满足条件的怪兽
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tgfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
