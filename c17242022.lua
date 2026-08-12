--真紅眼の超越黒竜
-- 效果：
-- 「真红眼黑龙」＋有「时间黑魔术师」的卡名记述的怪兽
-- 「真红眼超越黑龙」1回合1次用融合召唤以及以下方法才能特殊召唤。
-- ●「时间黑魔术师」的效果让怪兽被破坏的回合，把自己·对方场上1只表侧表示怪兽解放的场合可以从额外卡组特殊召唤。
-- ①：这张卡特殊召唤的场合才能发动。从自己的手卡·墓地把1只8星以下的怪兽特殊召唤。
-- ②：场上的这张卡不受对方发动的魔法·怪兽的效果影响。
local s,id,o=GetID()
-- 初始化效果：设置苏生限制与融合召唤手续，记录卡名记述，注册特殊召唤成功时登记回合标记的效果、特殊召唤条件、从额外卡组解放出场的召唤手续、①效果（特殊召唤时从手卡·墓地特殊召唤）、②效果（不受对方魔法·怪兽效果影响），以及全局监视「时间黑魔术师」效果破坏怪兽的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只「真红眼黑龙」（74677422）和1只满足s.mfilter条件（记载「时间黑魔术师」卡名）的怪兽为融合素材
	aux.AddFusionProcCodeFun(c,74677422,s.mfilter,1,true,true)
	-- 记录这张卡的效果文本上记载着「真红眼黑龙」（74677422）和「时间黑魔术师」（40235813）的卡名
	aux.AddCodeList(c,74677422,40235813)
	-- 「真红眼超越黑龙」1回合1次用融合召唤以及以下方法才能特殊召唤。（登记本回合已特殊召唤过此卡的标记）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.regop2)
	c:RegisterEffect(e0)
	-- 「真红眼超越黑龙」1回合1次用融合召唤以及以下方法才能特殊召唤。（设定只能用融合召唤特殊召唤的条件）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(s.splimit)
	c:RegisterEffect(e2)
	-- ●「时间黑魔术师」的效果让怪兽被破坏的回合，把自己·对方场上1只表侧表示怪兽解放的场合可以从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ①：这张卡特殊召唤的场合才能发动。从自己的手卡·墓地把1只8星以下的怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
	-- ②：场上的这张卡不受对方发动的魔法·怪兽的效果影响。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(s.immval)
	c:RegisterEffect(e5)
	if not s.global_check then
		s.global_check=true
		-- ●「时间黑魔术师」的效果让怪兽被破坏的回合（全局监视该回合事件并登记标记）
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.regop)
		-- 把这个监视怪兽被效果破坏的全局效果注册为双方玩家的环境效果
		Duel.RegisterEffect(ge1,0)
	end
end
s.material_setcode=0x3b
-- 「真红眼融合」等卡使用时的素材检查：检查两张卡组成的素材组合是否满足条件
function s.red_eyes_fusion_check(tp,sg,fc)
	-- 检查素材组中是否一张为卡号74677422（「真红眼黑龙」）、另一张满足s.mfilter条件（记载「时间黑魔术师」卡名的怪兽）
	return aux.gffcheck(sg,Card.IsFusionCode,74677422,s.mfilter,nil)
end
-- 过滤器：筛选出被效果破坏（破坏原因是效果）的卡
function s.dcfilter(c)
	return c:IsReason(REASON_EFFECT)
end
-- 全局处理：当怪兽因「时间黑魔术师」（40235813）的效果被破坏时，为双方玩家注册本回合的标识效果，标记该回合满足解放出场的回合条件
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if re and eg:IsExists(s.dcfilter,1,nil) and re:GetHandler():IsCode(40235813) then
		-- 为双方玩家注册持续到回合结束的标识效果，记录本回合「时间黑魔术师」的效果让怪兽被破坏过
		Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 融合素材过滤器：效果文本上记载着「时间黑魔术师」（40235813）卡名的怪兽
function s.mfilter(c)
	-- 检查该卡的效果文本上是否记载着「时间黑魔术师」（40235813）的卡名
	return aux.IsCodeListed(c,40235813)
end
-- 特殊召唤条件：只能用融合召唤特殊召唤，且召唤玩家本回合尚未用融合召唤或自身方法特殊召唤过这张卡（1回合1次限制）
function s.splimit(e,se,sp,st)
	-- 返回是否为融合召唤，且该玩家本回合的id+o标记为0（本回合还未特殊召唤过这张卡）
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id+o)==0
end
-- 条件：这张卡是融合召唤特殊召唤的，或持有通过解放方法特殊召唤时注册的标记，即这张卡特殊召唤的场合
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:GetFlagEffect(id)>0
end
-- 特殊召唤成功时的处理：为该玩家注册本回合已特殊召唤过这张卡的回合标记（用于1回合1次限制）
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家注册持续到回合结束的标识效果，记录本回合已特殊召唤过这张卡
	Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
end
-- 出场手续过滤器：表侧表示、可以因特殊召唤被解放、能作为这张卡的融合素材、且解放后额外卡组怪兽有可用空格的怪兽
function s.hspfilter(c,tp,fc)
	return c:IsFaceup() and c:IsReleasable(REASON_MATERIAL|REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
		-- 确认把该怪兽解放后，额外卡组的怪兽有可用的特殊召唤空格
		and Duel.GetLocationCountFromEx(tp,tp,c,fc)>0
end
-- 出场手续条件：本回合「时间黑魔术师」的效果已让怪兽被破坏、本回合尚未特殊召唤过这张卡，且自己·对方场上存在可解放的表侧表示怪兽
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 若没有本回合的标记（「时间黑魔术师」的效果未让怪兽被破坏）或该玩家本回合已特殊召唤过这张卡，则不能用此方法特殊召唤
	if Duel.GetFlagEffect(0,id)==0 or Duel.GetFlagEffect(tp,id+o)>0 then return false end
	-- 检查自己·对方场上是否存在至少1只满足解放条件的表侧表示怪兽
	return Duel.IsExistingMatchingCard(s.hspfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,c)
end
-- 出场手续目标：取得双方场上所有可解放的表侧表示怪兽，提示玩家并让其从中选择1只作为解放对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己·对方场上所有满足解放条件的表侧表示怪兽组成的卡组
	local g=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp,c)
	-- 向玩家发送“请选择要解放的卡”的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 出场手续处理：给这张卡注册标记（表示通过此方法特殊召唤，供①效果条件判定），并解放玩家选定的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	local g=e:GetLabelObject()
	-- 以特殊召唤为由解放玩家选定的怪兽，完成从额外卡组的特殊召唤手续
	Duel.Release(g,REASON_SPSUMMON)
end
-- ①效果过滤器：等级8以下且可以特殊召唤的怪兽
function s.spfilter2(c,e,tp)
	return c:IsLevelBelow(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果目标：发动条件为自己怪兽区域有可用空格，且自己的手卡·墓地存在至少1只可以特殊召唤的8星以下怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：自己怪兽区域有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己的手卡·墓地存在至少1只满足条件（8星以下、可以特殊召唤）的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息：本次处理将从手卡·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果处理：怪兽区域无空格则中止；提示玩家并让其从自己的手卡·墓地选择1只8星以下的怪兽，将其特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己怪兽区域没有可用空格，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送“请选择要特殊召唤的卡”的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·墓地选择1只8星以下且可以特殊召唤的怪兽（附加王家长眠之谷过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 把选定的怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果判定值：效果为对方玩家发动的魔法卡或怪兽的效果时，这张卡不受其影响
function s.immval(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer() and re:IsActivated()
		and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL)
end
