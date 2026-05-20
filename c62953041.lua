--稲荷火
-- 效果：
-- ①：「稻荷火」在自己场上只能有1张表侧表示存在。
-- ②：自己场上有魔法师族怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ③：场上的表侧表示的这张卡被效果破坏送去墓地的场合，下次的自己准备阶段发动。这张卡从墓地特殊召唤。
function c62953041.initial_effect(c)
	c:SetUniqueOnField(1,0,62953041)
	-- ②：自己场上有魔法师族怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c62953041.hspcon)
	c:RegisterEffect(e1)
	-- ③：场上的表侧表示的这张卡被效果破坏送去墓地的场合，下次的自己准备阶段发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c62953041.spreg)
	c:RegisterEffect(e2)
	-- ③：场上的表侧表示的这张卡被效果破坏送去墓地的场合，下次的自己准备阶段发动。这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(62953041,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c62953041.spcon)
	e3:SetTarget(c62953041.sptg)
	e3:SetOperation(c62953041.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的魔法师族怪兽
function c62953041.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 手卡特殊召唤效果的判定条件
function c62953041.hspcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的魔法师族怪兽
		and Duel.IsExistingMatchingCard(c62953041.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 被效果破坏送去墓地时的注册处理，根据当前是否为准备阶段设置不同的Flag和Label
function c62953041.spreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 or not c:IsPreviousPosition(POS_FACEUP) or not c:IsPreviousLocation(LOCATION_ONFIELD) then return end
	-- 判断当前是否为自己的准备阶段
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 将当前回合数记录在Label中，用于防止在被破坏的当个准备阶段立刻发动
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(62953041,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(62953041,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- 墓地特殊召唤效果的发动条件判定
function c62953041.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定当前回合不是被破坏的回合、当前是自己的回合且存在有效的被破坏标记
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(62953041)>0
end
-- 墓地特殊召唤效果的发动准备，设置操作信息并清除标记
function c62953041.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(62953041)
end
-- 墓地特殊召唤效果的执行函数
function c62953041.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从墓地表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
