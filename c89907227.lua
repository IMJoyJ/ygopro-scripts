--白闘気双頭神龍
-- 效果：
-- 同调怪兽调整＋调整以外的怪兽1只以上
-- ①：自己回合这张卡同调召唤成功时才能发动。在自己场上把1只「神龙衍生物」（鱼族·水·10星·攻3300/守3000）守备表示特殊召唤。
-- ②：对方回合1次，自己场上没有衍生物的场合才能发动。在自己场上把1只「神龙衍生物」特殊召唤。
-- ③：这张卡被对方的效果破坏送去墓地的场合，若自己场上有「神龙衍生物」存在则能发动。这张卡守备表示特殊召唤。
function c89907227.initial_effect(c)
	-- 添加同调召唤手续：同调怪兽调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_SYNCHRO),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己回合这张卡同调召唤成功时才能发动。在自己场上把1只「神龙衍生物」（鱼族·水·10星·攻3300/守3000）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89907227,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c89907227.tkcon)
	e1:SetTarget(c89907227.tktg)
	e1:SetOperation(c89907227.tkop)
	c:RegisterEffect(e1)
	-- ②：对方回合1次，自己场上没有衍生物的场合才能发动。在自己场上把1只「神龙衍生物」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89907227,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_END_PHASE)
	e2:SetCondition(c89907227.tkcon2)
	e2:SetTarget(c89907227.tktg)
	e2:SetOperation(c89907227.tkop2)
	c:RegisterEffect(e2)
	-- ③：这张卡被对方的效果破坏送去墓地的场合，若自己场上有「神龙衍生物」存在则能发动。这张卡守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89907227,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c89907227.spcon)
	e3:SetTarget(c89907227.sptg)
	e3:SetOperation(c89907227.spop)
	c:RegisterEffect(e3)
end
c89907227.material_type=TYPE_SYNCHRO
-- 效果①（同调召唤成功时产生衍生物）的发动条件判定函数
function c89907227.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为自己回合，且自身是否是通过同调召唤特殊召唤
	return Duel.GetTurnPlayer()==tp and e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①和效果②（产生衍生物）的发动准备与合法性检测函数
function c89907227.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 检查玩家是否能够特殊召唤指定的「神龙衍生物」（鱼族·水·10星·攻3300/守3000）
	and Duel.IsPlayerCanSpecialSummonMonster(tp,89907228,0,TYPES_TOKEN_MONSTER,3300,3000,10,RACE_FISH,ATTRIBUTE_WATER,POS_FACEUP_DEFENSE) end
	-- 设置连锁处理信息：包含产生衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁处理信息：包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果①（同调召唤成功时产生衍生物）的效果处理函数
function c89907227.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否能够特殊召唤指定的「神龙衍生物」
	if Duel.IsPlayerCanSpecialSummonMonster(tp,89907228,0,TYPES_TOKEN_MONSTER,3300,3000,10,RACE_FISH,ATTRIBUTE_WATER,POS_FACEUP_DEFENSE) then
		-- 在后台创建「神龙衍生物」卡片数据
		local token=Duel.CreateToken(tp,89907228)
		-- 将创建的衍生物以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②（对方回合产生衍生物）的发动条件判定函数
function c89907227.tkcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合，且自己场上不存在衍生物
	return Duel.IsTurnPlayer(1-tp) and not aux.tkfcon(e,tp)
end
-- 效果②（对方回合产生衍生物）的效果处理函数
function c89907227.tkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否能够特殊召唤指定的「神龙衍生物」
	if Duel.IsPlayerCanSpecialSummonMonster(tp,89907228,0,TYPES_TOKEN_MONSTER,3300,3000,10,RACE_FISH,ATTRIBUTE_WATER) then
		-- 在后台创建「神龙衍生物」卡片数据
		local token=Duel.CreateToken(tp,89907228)
		-- 将创建的衍生物以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③（自身被破坏送墓时特殊召唤）的发动条件判定函数
function c89907227.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and rp==1-tp and c:IsReason(REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		-- 判定自己场上是否存在「神龙衍生物」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,89907228)
end
-- 效果③（自身被破坏送墓时特殊召唤）的发动准备与合法性检测函数
function c89907227.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③（自身被破坏送墓时特殊召唤）的效果处理函数
function c89907227.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧守备表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
