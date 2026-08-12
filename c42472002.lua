--聖騎士コルネウス
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「圣剑」装备魔法卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：场上的这张卡为素材作同调·超量·连接召唤的「圣骑士」怪兽得到以下效果。
-- ●这次特殊召唤成功的场合才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只怪兽召唤。这个效果的发动后，直到回合结束时自己不是「圣骑士」怪兽不能从额外卡组特殊召唤。
function c42472002.initial_effect(c)
	-- ①：自己场上有「圣剑」装备魔法卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,42472002+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c42472002.sprcon)
	c:RegisterEffect(e1)
	-- 场上的这张卡为素材作同调·超量·连接召唤的「圣骑士」怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c42472002.effcon)
	e2:SetOperation(c42472002.effop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在「圣剑」装备魔法卡。
function c42472002.sprfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x207a) and c:GetType()==TYPE_SPELL+TYPE_EQUIP
end
-- 判断特殊召唤条件是否满足：手卡特殊召唤时，场上存在「圣剑」装备魔法卡且有空场。
function c42472002.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断当前玩家场上是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断当前玩家场上是否存在至少1张「圣剑」装备魔法卡。
		and Duel.IsExistingMatchingCard(c42472002.sprfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 判断该怪兽是否作为同调/超量/连接召唤的素材被特殊召唤。
function c42472002.effcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_SYNCHRO+REASON_XYZ+REASON_LINK)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():GetReasonCard():IsSetCard(0x107a)
end
-- 当怪兽作为同调/超量/连接召唤的素材被特殊召唤时，注册效果使其在特殊召唤成功后可以发动额外召唤。
function c42472002.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 发动后，直到回合结束时自己不是「圣骑士」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(42472002,0))  --"增加召唤次数"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c42472002.sumtg)
	e1:SetOperation(c42472002.sumop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 若该怪兽没有效果类型，则为其添加TYPE_EFFECT类型。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 判断是否可以发动额外召唤效果：玩家可以通常召唤、可以额外召唤、未使用过该效果、且为当前回合玩家。
function c42472002.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以通常召唤。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 判断玩家是否可以额外召唤、该效果是否已使用过、且为当前回合玩家。
		and Duel.GetFlagEffect(tp,42472002)==0 and Duel.GetTurnPlayer()==tp end
end
-- 发动额外召唤效果：使玩家在本回合可以额外召唤一次。
function c42472002.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该效果是否已使用过。
	if Duel.GetFlagEffect(tp,42472002)==0 then
		-- 注册额外召唤次数效果，使玩家在本回合可以额外召唤一次。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(42472002,1))  --"使用「圣骑士 康尼厄斯」的效果召唤"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将额外召唤次数效果注册到全局环境。
		Duel.RegisterEffect(e1,tp)
		-- 注册标识效果，防止该效果在本回合再次使用。
		Duel.RegisterFlagEffect(tp,42472002,RESET_PHASE+PHASE_END,0,1)
	end
	-- 注册不能从额外卡组特殊召唤的效果，仅限非「圣骑士」怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c42472002.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤效果注册到全局环境。
	Duel.RegisterEffect(e2,tp)
end
-- 判断目标卡是否为非「圣骑士」怪兽且位于额外卡组。
function c42472002.splimit(e,c)
	return not c:IsSetCard(0x107a) and c:IsLocation(LOCATION_EXTRA)
end
