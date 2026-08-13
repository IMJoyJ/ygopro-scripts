--機巧嘴－八咫御先
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以把自己场上1只通常召唤的怪兽解放从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的回合的自己主要阶段才能发动。把1只怪兽召唤。自己在这个效果召唤过的回合，不是原本种族和那只怪兽相同的怪兽不能特殊召唤。
-- ③：这张卡的①的方法特殊召唤的这张卡被解放的场合发动。自己回复2050基本分。
function c13224603.initial_effect(c)
	-- ①：这张卡可以把自己场上1只通常召唤的怪兽解放从手卡特殊召唤。
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
	-- ②：这张卡召唤·特殊召唤成功的回合的自己主要阶段才能发动。把1只怪兽召唤。自己在这个效果召唤过的回合，不是原本种族和那只怪兽相同的怪兽不能特殊召唤。
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
	-- ③：这张卡的①的方法特殊召唤的这张卡被解放的场合发动。自己回复2050基本分。
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
		-- ②：这张卡召唤·特殊召唤成功的回合的自己主要阶段才能发动。把1只怪兽召唤。自己在这个效果召唤过的回合，不是原本种族和那只怪兽相同的怪兽不能特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(13224603)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置通常召唤成功时的全局处理函数，为成功通常召唤的怪兽打上“本回合召唤成功”的标记，供②效果的发动条件判断。
		ge1:SetOperation(aux.sumreg)
		-- 将监听通常召唤成功的全局效果注册到决斗中，使任意玩家的通常召唤成功都会触发标记记录。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(13224603)
		-- 将监听特殊召唤成功的全局效果注册到决斗中，使任意玩家的特殊召唤成功也会触发标记记录。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 定义①效果解放素材的过滤函数：被解放的怪兽必须是通常召唤过的怪兽，且解放后自己仍有可用的怪兽区域。
function c13224603.hspfilter(c,tp)
	-- 判断候选怪兽是通常召唤过且解放后我方场上有空位，满足作为①效果解放素材的条件。
	return c:IsSummonType(SUMMON_TYPE_NORMAL) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义①特殊召唤规则效果的发动条件：存在1只可解放的通常召唤怪兽且解放后有空位；若c为nil则先返回true进入选择处理。
function c13224603.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在至少1只满足条件的可解放怪兽，作为从手卡进行①效果特殊召唤的前提。
	return Duel.CheckReleaseGroupEx(tp,c13224603.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 定义①效果的选材处理：从可解放的怪兽中选择1只通常召唤过的怪兽并记录为解放对象，未选择则效果不适用。
function c13224603.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家场上可解放的怪兽组，并筛选出满足hspfilter条件的候选解放对象。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c13224603.hspfilter,nil,tp)
	-- 向玩家发送“请选择要解放的卡”的提示信息，用于选择解放怪兽的操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义①效果特殊召唤手续的处理：将之前选择的怪兽解放，完成从手卡特殊召唤此卡的代价。
function c13224603.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤手续的原因解放，作为此卡从手卡特殊召唤的解放代价。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 定义②效果的发动条件：此卡带有本回合召唤·特殊召唤成功的标记（FlagEffect 13224603）时才能发动。
function c13224603.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(13224603)>0
end
-- 定义②效果可召唤对象的过滤条件：该怪兽处于可以进行无解放通常召唤的状态。
function c13224603.sumfilter(c)
	return c:IsSummonable(true,nil)
end
-- 定义②效果的发动合法性：手卡·场上存在至少1只可召唤的怪兽时，登记操作信息并允许发动。
function c13224603.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认存在可通常召唤的怪兽，保证②效果拥有合法的处理对象。
	if chk==0 then return Duel.IsExistingMatchingCard(c13224603.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 将当前连锁的操作信息设置为“召唤”类别，标记本次处理将进行1只怪兽的通常召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 定义②效果的处理：选择1只怪兽进行通常召唤，并注册召唤成功时施加相同原本种族限制、以及召唤被无效时撤销限制的后续效果。
function c13224603.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送“请选择要召唤的卡”的提示信息，用于选择召唤对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从自己手卡·场上选择1只满足条件的怪兽作为本次效果要召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c13224603.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if tc then
		-- 自己在这个效果召唤过的回合，不是原本种族和那只怪兽相同的怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetReset(RESET_PHASE+PHASE_MAIN1)
		e1:SetOperation(c13224603.regop)
		-- 注册监听通常召唤成功的辅助效果，使本次召唤成功时能够施加后续的“仅能特殊召唤相同原本种族”限制。
		Duel.RegisterEffect(e1,tp)
		-- 把1只怪兽召唤。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SUMMON_NEGATED)
		e2:SetOperation(c13224603.rstop)
		e2:SetLabelObject(e1)
		e2:SetReset(RESET_PHASE+PHASE_MAIN1)
		-- 注册监听召唤被无效的辅助效果，用于在召唤被无效时取消自肃效果的注册。
		Duel.RegisterEffect(e2,tp)
		-- 对选择的怪兽进行不占通常召唤次数、无需祭品的通常召唤。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 定义自肃过滤函数：怪兽原本种族与记录种族不一致时不能特殊召唤，从而实现只能特殊召唤相同原本种族的怪兽。
function c13224603.splimit(e,c)
	return c:GetOriginalRace()&e:GetLabel()==0
end
-- 定义召唤成功后的自肃处理：为当前玩家注册一个持续到回合结束的特殊召唤限制，并结束本次监听。
function c13224603.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=eg:GetFirst()
	-- 自己在这个效果召唤过的回合，不是原本种族和那只怪兽相同的怪兽不能特殊召唤。③：这张卡的①的方法特殊召唤的这张卡被解放的场合发动。自己回复2050基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(ec:GetOriginalRace())
	e1:SetTarget(c13224603.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能特殊召唤”的限制效果注册给当前玩家，使其本回合内不能特殊召唤原本种族与召唤成功怪兽不同的怪兽。
	Duel.RegisterEffect(e1,tp)
	e:Reset()
end
-- 定义召唤被无效时的撤销处理：取消之前注册的自肃监听，避免自肃错误生效。
function c13224603.rstop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	e1:Reset()
	e:Reset()
end
-- 定义③效果的发动条件：这张卡从场上被解放，且是以①的效果特殊召唤成功的场合。
function c13224603.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 定义③效果的目标设置：将回复对象设为这张卡的控制者，回复量设为2050，并登记回复效果的操作信息。
function c13224603.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁处理的对象玩家设置为这张卡的控制者，即回复基本分的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁处理的参数设置为2050，作为回复的具体数值。
	Duel.SetTargetParam(2050)
	-- 将操作信息登记为“回复”类别，指定回复玩家为tp、回复量为2050。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2050)
end
-- 定义③效果的实际处理：读取记录的目标玩家和回复量，执行基本分回复。
function c13224603.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设置的目标玩家和回复量参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果处理的原因，让目标玩家回复对应数值的基本分。
	Duel.Recover(p,d,REASON_EFFECT)
end
