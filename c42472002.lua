--聖騎士コルネウス
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「圣剑」装备魔法卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：场上的这张卡为素材作同调·超量·连接召唤的「圣骑士」怪兽得到以下效果。
-- ●这次特殊召唤成功的场合才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只怪兽召唤。这个效果的发动后，直到回合结束时自己不是「圣骑士」怪兽不能从额外卡组特殊召唤。
function c42472002.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「圣剑」装备魔法卡存在的场合，这张卡可以从手卡特殊召唤。
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
-- 筛选「圣剑」装备魔法卡：要求表侧表示、属于「圣剑」字段且为装备魔法卡，用于①的特殊召唤条件。
function c42472002.sprfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x207a) and c:GetType()==TYPE_SPELL+TYPE_EQUIP
end
-- 规则特殊召唤的条件：若被尝试召唤的是自身则要求自己的怪兽区有空位，且自己场上有满足sprfilter的「圣剑」装备魔法卡。
function c42472002.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域，以放置从手牌特殊召唤的这张卡。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张表侧表示的「圣剑」装备魔法卡（满足sprfilter）。
		and Duel.IsExistingMatchingCard(c42472002.sprfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 作为素材时效果的触发条件：这张卡从场上被用作同调·超量·连接召唤的素材，且所召唤的怪兽是「圣骑士」怪兽。
function c42472002.effcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_SYNCHRO+REASON_XYZ+REASON_LINK)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():GetReasonCard():IsSetCard(0x107a)
end
-- 作为素材时给召唤出的「圣骑士」怪兽附加效果：注册一个在特殊召唤成功时发动的诱发效果；若该怪兽原本不是效果怪兽，则追加效果怪兽种类。
function c42472002.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这次特殊召唤成功的场合才能发动。
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
		-- 得到以下效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 额外召唤效果的发动条件：自己通常召唤未被禁止、拥有额外召唤次数、本回合尚未用同名效果增加过召唤次数，且是己方回合。
function c42472002.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定玩家当前可以进行通常召唤，并且拥有追加通常召唤次数（已使用完通常召唤次数也没关系，EFFECT_EXTRA_SUMMON_COUNT会追加）。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 判定本回合还没有使用过本卡片的效果（flag为0），且当前是发动玩家的回合。
		and Duel.GetFlagEffect(tp,42472002)==0 and Duel.GetTurnPlayer()==tp end
end
-- 执行效果：若本回合尚未适用过追加召唤效果，则给玩家追加一次通常召唤并登记flag；随后无条件设置自肃：本回合不能从额外卡组特殊召唤非「圣骑士」怪兽。
function c42472002.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若玩家本回合还没有适用过本效果（flag为0），才注册追加召唤次数，避免重复。
	if Duel.GetFlagEffect(tp,42472002)==0 then
		-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只怪兽召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(42472002,1))  --"使用「圣骑士 康尼厄斯」的效果召唤"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将追加通常召唤次数的永续效果注册到玩家区域，使本回合玩家能够额外进行一次通常召唤。
		Duel.RegisterEffect(e1,tp)
		-- 登记本回合已使用过「圣骑士 康尼厄斯」的追加召唤效果的标志，防止同名效果再次发动/重复追加。
		Duel.RegisterFlagEffect(tp,42472002,RESET_PHASE+PHASE_END,0,1)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「圣骑士」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c42472002.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到玩家区域：本回合内自己不能特殊召唤额外卡组的非「圣骑士」怪兽。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃的判定函数：如果要从额外卡组特殊召唤的怪兽不是「圣骑士」字段，则禁止特殊召唤。
function c42472002.splimit(e,c)
	return not c:IsSetCard(0x107a) and c:IsLocation(LOCATION_EXTRA)
end
