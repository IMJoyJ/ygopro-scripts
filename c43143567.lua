--黄金郷のアンヘルカイド
-- 效果：
-- 「黄金卿 黄金国巫妖」＋不死族怪兽
-- 「黄金乡的堕落天使」1回合1次用融合召唤以及以下方法才能特殊召唤。
-- ●自己的场上或墓地有「黄金卿 黄金国巫妖」存在的状态，把自己场上1只不死族·光属性怪兽解放的场合可以从额外卡组特殊召唤。
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡从场上送去墓地的场合才能发动。从自己的卡组·额外卡组·墓地把1只「黄金国巫妖」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：启用苏生限制，注册融合素材条件、特殊召唤成功时的次数标记、特殊召唤条件限制、规则解放召唤手续、以及①墓地发动的特殊召唤效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：需要1只「黄金卿 黄金国巫妖」（卡号95440946）和1只不死族怪兽作为融合素材。
	aux.AddFusionProcCodeFun(c,95440946,s.mfilter,1,true,true)
	-- 1回合1次
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	-- 用融合召唤以及以下方法才能特殊召唤
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
	-- 这个卡名的效果1回合只能使用1次。①：这张卡从场上送去墓地的场合才能发动。从自己的卡组·额外卡组·墓地把1只「黄金国巫妖」怪兽特殊召唤。
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
-- 判断怪兽是否属于不死族（融合素材的种族条件）。
function s.mfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
-- 判定这张卡是否满足特殊召唤条件：必须是融合召唤，且本回合未进行过这张卡的特殊召唤（flag为0）。
function s.splimit(e,se,sp,st)
	-- 检查召唤类型是否为融合召唤，且当前玩家没有本回合使用过该卡特殊召唤的次数标记。
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id)==0
end
-- e0的触发条件：当这张卡通过融合召唤成功，或通过规则召唤（●方法）特殊召唤成功时。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:GetFlagEffect(id)>0
end
-- 在特殊召唤成功时，为当前玩家注册一个本回合的标识，记录已经进行过这张卡的特殊召唤。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家注册一个持续到结束阶段的标识（id），用于限制本回合不能再次通过融合召唤/规则召唤方式特殊召唤。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 规则召唤选择解放素材的过滤函数：怪兽为不死族·光属性，且解放后额外卡组有可用怪兽区域。
function s.spfilter(c,tp,sc)
	-- 素材必须是不死族·光属性；并且解放该素材后，额外卡组有怪兽区域可用；素材可以是自己控制的卡或表侧表示的卡。
	return c:IsRace(RACE_ZOMBIE) and c:IsAttribute(ATTRIBUTE_LIGHT) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查场上或墓地是否存在表侧表示/可确认的「黄金卿 黄金国巫妖」（卡号95440946）。
function s.cfilter(c)
	return c:IsCode(95440946) and c:IsFaceupEx()
end
-- 规则召唤能否发动的条件：额外卡组的这张卡进行规则特殊召唤时，需要场/墓有黄金卿，本回合未用过该卡召唤次数，并且有可解放的不死族·光属性怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 若没有黄金卿在场/墓，或本回合已有该卡特殊召唤flag，则不能用规则召唤方式特殊召唤。
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) or Duel.GetFlagEffect(tp,id)>0 then return false end
	-- 检查是否存在至少1只满足条件（不死族·光属性）的可解放怪兽作为规则召唤的解放素材。
	return Duel.CheckReleaseGroupEx(tp,s.spfilter,1,REASON_SPSUMMON,false,nil,tp,c)
end
-- 规则召唤的target处理：从可解放素材中选择1只不死族·光属性怪兽，并把选择结果暂存到效果e中，供处理时解放。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可解放的怪兽组，并过滤出满足不死族·光属性条件的可选素材。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.spfilter,nil,tp,c)
	-- 向玩家显示“请选择要解放的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 规则召唤的处理：给这张卡注册自身flag（标记已通过规则召唤特殊召唤），然后解放选择的素材。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	local g=e:GetLabelObject()
	-- 解放选择的素材怪兽，作为规则召唤的代价。
	Duel.Release(g,REASON_SPSUMMON)
end
-- ①效果的发动条件：这张卡从场上被送去墓地（之前所在区域为场上）。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ①效果选择特殊召唤对象时的过滤：必须是「黄金国巫妖」系列怪兽，且可以被特殊召唤；同时根据来源（卡组/墓地或额外）检查是否有可用怪兽区域。
function s.tgfilter(c,e,tp)
	return c:IsSetCard(0x1142) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and
		-- 对于从卡组或墓地特殊召唤的情况，需要我方怪兽区有空位。
		(not c:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp)>0
		-- 对于从额外卡组特殊召唤的情况，需要有可用的额外怪兽区域。
		or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ①效果的target：发动时确认存在符合条件的「黄金国巫妖」怪兽，并声明效果将进行特殊召唤（来源为卡组·墓地·额外卡组）。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组·墓地·额外卡组是否存在至少1只符合条件的「黄金国巫妖」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置本连锁的操作信息：效果类型为特殊召唤，对象数量为1，来源位置为卡组·墓地·额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end
-- ①效果处理：让玩家选择1只符合条件的「黄金国巫妖」怪兽，将其特殊召唤到自己场上。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组·墓地·额外卡组中选择1只符合条件的「黄金国巫妖」怪兽；使用NecroValleyFilter确保不受王家长眠之谷影响（不能从墓地特殊召唤时会被过滤）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tgfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽表侧表示特殊召唤到当前玩家场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
