--冥府の使者ゴーズ
-- 效果：
-- 自己场上没有卡存在的场合，因对方控制的卡受到伤害时，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功时，把受到的伤害种类的以下效果发动。
-- ●战斗伤害的场合，在自己场上把1只「冥府之使者 凯恩衍生物」（天使族·光·7星·攻/守?）特殊召唤。这衍生物的攻击力·守备力变成和这个时候受到的战斗伤害相同的数值。
-- ●卡的效果伤害的场合，给与对方基本分和受到的伤害相同的伤害。
function c44330098.initial_effect(c)
	-- 诱发选发效果，当对方控制的卡受到伤害时，若自己场上没有卡存在则可以从手卡特殊召唤
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
	-- 特殊召唤衍生物
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
	-- 给与伤害
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
-- 过滤掉已确认离开的卡片
function c44330098.filter(c)
	return not c:IsStatus(STATUS_LEAVE_CONFIRMED)
end
-- 判断是否满足特殊召唤条件：伤害由对方造成，自己场上没有卡存在
function c44330098.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 伤害由对方造成，自己场上没有卡存在
	return ep==tp and 1-tp==rp and not Duel.IsExistingMatchingCard(c44330098.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置特殊召唤的处理目标
function c44330098.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c44330098.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local typ=bit.band(r,REASON_BATTLE)~=0 and 1 or 2
	e:SetLabel(typ,ev)
	-- 将卡片特殊召唤到场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 判断是否满足衍生物召唤条件：特殊召唤成功且为战斗伤害
function c44330098.sumcon2(e,tp,eg,ep,ev,re,r,rp)
	local typ,val=e:GetLabelObject():GetLabel()
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and typ==1
end
-- 设置衍生物召唤的处理目标
function c44330098.sumtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置衍生物的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置特殊召唤衍生物的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 执行衍生物召唤操作
function c44330098.sumop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local typ,val=e:GetLabelObject():GetLabel()
	-- 检查是否可以特殊召唤衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,44330099,0,TYPES_TOKEN_MONSTER,-2,-2,7,RACE_FAIRY,ATTRIBUTE_LIGHT) then return end
	-- 创建衍生物卡片
	local token=Duel.CreateToken(tp,44330099)
	-- 设置衍生物攻击力
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(val)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	token:RegisterEffect(e1)
	-- 设置衍生物守备力
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_DEFENSE)
	e2:SetValue(val)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	token:RegisterEffect(e2)
	-- 将衍生物特殊召唤到场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断是否满足伤害效果条件：特殊召唤成功且为卡的效果伤害
function c44330098.sumcon3(e,tp,eg,ep,ev,re,r,rp)
	local typ,val=e:GetLabelObject():GetLabel()
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and typ==2
end
-- 设置伤害效果的处理目标
function c44330098.sumtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local typ,d=e:GetLabelObject():GetLabel()
	-- 设置伤害效果的目标玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的目标参数
	Duel.SetTargetParam(d)
	-- 设置伤害效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,d)
end
-- 执行伤害效果操作
function c44330098.sumop3(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
