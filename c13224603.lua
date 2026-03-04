--機巧嘴－八咫御先
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以把自己场上1只通常召唤的怪兽解放从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的回合的自己主要阶段才能发动。把1只怪兽召唤。自己在这个效果召唤过的回合，不是原本种族和那只怪兽相同的怪兽不能特殊召唤。
-- ③：这张卡的①的方法特殊召唤的这张卡被解放的场合发动。自己回复2050基本分。
function c13224603.initial_effect(c)
	-- 效果原文内容：①：这张卡可以把自己场上1只通常召唤的怪兽解放从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c13224603.hspcon)
	e1:SetTarget(c13224603.hsptg)
	e1:SetOperation(c13224603.hspop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡召唤·特殊召唤成功的回合的自己主要阶段才能发动。把1只怪兽召唤。自己在这个效果召唤过的回合，不是原本种族和那只怪兽相同的怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13224603,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,13224603)
	e2:SetCondition(c13224603.sumcon)
	e2:SetTarget(c13224603.sumtg)
	e2:SetOperation(c13224603.sumop)
	c:RegisterEffect(e2)
	-- 效果原文内容：③：这张卡的①的方法特殊召唤的这张卡被解放的场合发动。自己回复2050基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13224603,1))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCountLimit(1,13224604)
	e3:SetCondition(c13224603.reccon)
	e3:SetTarget(c13224603.rectg)
	e3:SetOperation(c13224603.recop)
	c:RegisterEffect(e3)
	if not c13224603.global_check then
		c13224603.global_check=true
		-- 效果原文内容：这个卡名的②③的效果1回合各能使用1次。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(13224603)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 规则层面操作：注册EVENT_SUMMON_SUCCESS事件的处理函数为aux.sumreg，用于记录召唤成功的怪兽
		ge1:SetOperation(aux.sumreg)
		-- 规则层面操作：将效果ge1注册给全局环境，使该效果生效
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(13224603)
		-- 规则层面操作：将效果ge2注册给全局环境，使该效果生效
		Duel.RegisterEffect(ge2,0)
	end
end
-- 规则层面操作：定义一个过滤函数，用于判断是否满足特殊召唤条件
function c13224603.hspfilter(c,tp)
	-- 规则层面操作：判断该怪兽是否为通常召唤且场上存在可用怪兽区
	return c:IsSummonType(SUMMON_TYPE_NORMAL) and Duel.GetMZoneCount(tp,c)>0
end
-- 规则层面操作：定义一个条件函数，用于判断是否满足特殊召唤条件
function c13224603.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面操作：检查玩家场上是否存在满足条件的怪兽用于解放
	return Duel.CheckReleaseGroupEx(tp,c13224603.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 规则层面操作：定义一个目标函数，用于选择满足条件的怪兽进行特殊召唤
function c13224603.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 规则层面操作：获取玩家可解放的怪兽组并筛选满足条件的怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c13224603.hspfilter,nil,tp)
	-- 规则层面操作：提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 规则层面操作：定义一个操作函数，用于执行特殊召唤时的解放操作
function c13224603.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 规则层面操作：将指定的怪兽从场上解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 规则层面操作：定义一个条件函数，用于判断是否满足②效果发动条件
function c13224603.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(13224603)>0
end
-- 规则层面操作：定义一个过滤函数，用于判断是否满足召唤条件
function c13224603.sumfilter(c)
	return c:IsSummonable(true,nil)
end
-- 规则层面操作：定义一个目标函数，用于选择满足条件的怪兽进行召唤
function c13224603.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查玩家手牌或场上是否存在满足召唤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c13224603.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 规则层面操作：设置连锁操作信息，表示将要进行召唤操作
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 规则层面操作：定义一个操作函数，用于执行召唤操作
function c13224603.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：提示玩家选择要召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	-- 规则层面操作：选择满足召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c13224603.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if tc then
		-- 效果原文内容：自己在这个效果召唤过的回合，不是原本种族和那只怪兽相同的怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetReset(RESET_PHASE+PHASE_MAIN1)
		e1:SetOperation(c13224603.regop)
		-- 规则层面操作：将效果e1注册给玩家，使该效果生效
		Duel.RegisterEffect(e1,tp)
		-- 效果原文内容：自己在这个效果召唤过的回合，不是原本种族和那只怪兽相同的怪兽不能特殊召唤。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SUMMON_NEGATED)
		e2:SetOperation(c13224603.rstop)
		e2:SetLabelObject(e1)
		e2:SetReset(RESET_PHASE+PHASE_MAIN1)
		-- 规则层面操作：将效果e2注册给玩家，使该效果生效
		Duel.RegisterEffect(e2,tp)
		-- 规则层面操作：执行召唤操作
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 规则层面操作：定义一个限制函数，用于判断是否满足特殊召唤限制条件
function c13224603.splimit(e,c)
	return c:GetOriginalRace()&e:GetLabel()==0
end
-- 规则层面操作：定义一个操作函数，用于设置召唤限制效果
function c13224603.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=eg:GetFirst()
	-- 效果原文内容：自己在这个效果召唤过的回合，不是原本种族和那只怪兽相同的怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(ec:GetOriginalRace())
	e1:SetTarget(c13224603.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面操作：将效果e1注册给玩家，使该效果生效
	Duel.RegisterEffect(e1,tp)
	e:Reset()
end
-- 规则层面操作：定义一个操作函数，用于重置相关效果
function c13224603.rstop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	e1:Reset()
	e:Reset()
end
-- 规则层面操作：定义一个条件函数，用于判断是否满足③效果发动条件
function c13224603.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 规则层面操作：定义一个目标函数，用于设置回复LP效果的目标
function c13224603.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置连锁操作信息中的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 规则层面操作：设置连锁操作信息中的目标参数为2050
	Duel.SetTargetParam(2050)
	-- 规则层面操作：设置连锁操作信息，表示将要进行回复LP操作
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2050)
end
-- 规则层面操作：定义一个操作函数，用于执行回复LP操作
function c13224603.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面操作：使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
