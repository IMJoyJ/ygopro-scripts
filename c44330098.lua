--冥府の使者ゴーズ
-- 效果：
-- 自己场上没有卡存在的场合，因对方控制的卡受到伤害时，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功时，把受到的伤害种类的以下效果发动。
-- ●战斗伤害的场合，在自己场上把1只「冥府之使者 凯恩衍生物」（天使族·光·7星·攻/守?）特殊召唤。这衍生物的攻击力·守备力变成和这个时候受到的战斗伤害相同的数值。
-- ●卡的效果伤害的场合，给与对方基本分和受到的伤害相同的伤害。
function c44330098.initial_effect(c)
	-- 自己场上没有卡存在的场合，因对方控制的卡受到伤害时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44330098,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(c44330098.sumcon)
	e1:SetTarget(c44330098.sumtg)
	e1:SetOperation(c44330098.sumop)
	c:RegisterEffect(e1)
	-- 这个方法特殊召唤成功时，把受到的伤害种类的以下效果发动。●战斗伤害的场合，在自己场上把1只「冥府之使者 凯恩衍生物」（天使族·光·7星·攻/守?）特殊召唤。这衍生物的攻击力·守备力变成和这个时候受到的战斗伤害相同的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44330098,1))  --"特殊召唤衍生物"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c44330098.sumcon2)
	e2:SetTarget(c44330098.sumtg2)
	e2:SetOperation(c44330098.sumop2)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ●卡的效果伤害的场合，给与对方基本分和受到的伤害相同的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44330098,2))  --"给与伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c44330098.sumcon3)
	e3:SetTarget(c44330098.sumtg3)
	e3:SetOperation(c44330098.sumop3)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
end
-- 过滤函数：排除已确定离场（STATUS_LEAVE_CONFIRMED）的卡，用于判断自己场上是否真的没有卡存在。
function c44330098.filter(c)
	return not c:IsStatus(STATUS_LEAVE_CONFIRMED)
end
-- e1发动条件：受到伤害的玩家是自己（ep==tp），伤害来源的控制者是对方（1-tp==rp），并且自己场上不存在未确定离场的卡（即自己场上没有卡）。
function c44330098.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否不存在满足filter的卡，即自己场上没有卡；同时确认伤害来源是对方控制的效果/攻击。
	return ep==tp and 1-tp==rp and not Duel.IsExistingMatchingCard(c44330098.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- e1发动时的目标判定：自己主要怪兽区有空位，且手牌的这张卡能够被特殊召唤。
function c44330098.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时确认自己主要怪兽区有空位（用于腾出位置从手卡特殊召唤此卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：宣告将这张卡进行特殊召唤，类别为CATEGORY_SPECIAL_SUMMON，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理特殊召唤：确认此卡仍与效果相关后，根据造成伤害的种类（REASON_BATTLE是否为真）将typ设为1（战斗）或2（效果），并把伤害数值ev存入效果标签，然后以自身效果将这张卡特殊召唤。
function c44330098.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local typ=bit.band(r,REASON_BATTLE)~=0 and 1 or 2
	e:SetLabel(typ,ev)
	-- 将手牌的这张卡以自身效果（SUMMON_VALUE_SELF）表侧表示特殊召唤到自己的主要怪兽区，并记录召唤类型供后续效果判断。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- e2发动条件：这张卡通过自身效果特殊召唤成功（召唤类型为SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF），且e1记录的伤害种类为战斗伤害（typ==1）。
function c44330098.sumcon2(e,tp,eg,ep,ev,re,r,rp)
	local typ,val=e:GetLabelObject():GetLabel()
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and typ==1
end
-- e2发动目标：无选择对象，直接宣告要特殊召唤1只衍生物（token），并设置特殊召唤的操作信息。
function c44330098.sumtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次处理将特殊召唤1只衍生物（token），数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次处理包含特殊召唤，类别为CATEGORY_SPECIAL_SUMMON，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 处理衍生物特殊召唤：先确认主要怪兽区有空位，读出e1记录的伤害数值val；确认可以特殊召唤「冥府之使者 凯恩衍生物」后创建衍生物，将其攻击力/守备力设为val，然后表侧表示特殊召唤。
function c44330098.sumop2(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己主要怪兽区没有空位，则无法特殊召唤衍生物，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local typ,val=e:GetLabelObject():GetLabel()
	-- 检查自己是否能够特殊召唤「冥府之使者 凯恩衍生物」（天使族·光·7星，攻击力/守备力暂定），若不能则终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,44330099,0,TYPES_TOKEN_MONSTER,-2,-2,7,RACE_FAIRY,ATTRIBUTE_LIGHT) then return end
	-- 创建1只「冥府之使者 凯恩衍生物」（卡号44330099）到自己的场上。
	local token=Duel.CreateToken(tp,44330099)
	-- 这衍生物的攻击力·守备力变成和这个时候受到的战斗伤害相同的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(val)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	token:RegisterEffect(e1)
	-- 这衍生物的攻击力·守备力变成和这个时候受到的战斗伤害相同的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_DEFENSE)
	e2:SetValue(val)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	token:RegisterEffect(e2)
	-- 将衍生物表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- e3发动条件：这张卡通过自身效果特殊召唤成功，且e1记录的伤害种类为效果伤害（typ==2）。
function c44330098.sumcon3(e,tp,eg,ep,ev,re,r,rp)
	local typ,val=e:GetLabelObject():GetLabel()
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and typ==2
end
-- e3发动目标：无选择对象，将对方玩家设为对象玩家，将受到的伤害数值设为参数，并设置伤害操作信息。
function c44330098.sumtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local typ,d=e:GetLabelObject():GetLabel()
	-- 将当前连锁的对象玩家设为对方（1-tp），即此次伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设为受到的伤害值d，供效果处理时读取。
	Duel.SetTargetParam(d)
	-- 设置操作信息：对对方玩家（1-tp）造成d点伤害，类别为CATEGORY_DAMAGE，用于相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,d)
end
-- 处理给与伤害：从连锁信息中读取对象玩家和伤害数值，对读取到的玩家造成等量效果伤害。
function c44330098.sumop3(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取对象玩家p和对象参数d（即要承受伤害的玩家和伤害数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害（REASON_EFFECT）的形式对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
