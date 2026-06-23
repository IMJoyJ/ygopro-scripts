--覇道星シュラ
-- 效果：
-- 「霸胜星 韦驮天」＋5星以上的战士族怪兽
-- ①：1回合1次，自己·对方的战斗阶段才能发动。对方场上的全部表侧表示怪兽的攻击力变成0。
-- ②：怪兽之间进行战斗的伤害计算时才能发动1次。那些进行战斗的双方怪兽的攻击力只在那次伤害计算时上升各自等级×200。
-- ③：融合召唤的这张卡被对方破坏送去墓地的场合才能发动。把1只「霸胜星 韦驮天」当作融合召唤从额外卡组特殊召唤。
function c32615065.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用卡号为96220350的怪兽和1个满足ffilter条件的怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,96220350,c32615065.ffilter,1,true,true)
	-- ①：1回合1次，自己·对方的战斗阶段才能发动。对方场上的全部表侧表示怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32615065,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c32615065.atkcon)
	e1:SetTarget(c32615065.atktg)
	e1:SetOperation(c32615065.atkop)
	c:RegisterEffect(e1)
	-- ②：怪兽之间进行战斗的伤害计算时才能发动1次。那些进行战斗的双方怪兽的攻击力只在那次伤害计算时上升各自等级×200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32615065,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c32615065.atkcon2)
	e2:SetCost(c32615065.atkcost2)
	e2:SetOperation(c32615065.atkop2)
	c:RegisterEffect(e2)
	-- ③：融合召唤的这张卡被对方破坏送去墓地的场合才能发动。把1只「霸胜星 韦驮天」当作融合召唤从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32615065,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c32615065.spcon)
	e3:SetTarget(c32615065.sptg)
	e3:SetOperation(c32615065.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选种族为战士族且等级大于等于5的怪兽
function c32615065.ffilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(5)
end
-- 判断当前是否处于战斗阶段开始到战斗阶段结束之间，并且未在伤害计算后发动
function c32615065.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为战斗阶段开始到战斗阶段结束之间
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
		-- 调用aux.dscon函数，确保效果不能在伤害计算后发动
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤函数，用于筛选场上正面表示且攻击力大于0的怪兽
function c32615065.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 设置效果目标，检查是否存在满足条件的怪兽
function c32615065.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足atkfilter条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c32615065.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 将对方场上所有正面表示的怪兽攻击力设为0
function c32615065.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有正面表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 将怪兽的攻击力设为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 设置效果发动时的费用，检查是否已使用过该效果
function c32615065.atkcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(32615065)==0 end
	c:RegisterFlagEffect(32615065,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 判断是否为怪兽间战斗且攻击方与防守方不同控制者
function c32615065.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取防守怪兽
	local d=Duel.GetAttackTarget()
	return d and a:GetControler()~=d:GetControler()
end
-- 在伤害计算时，使攻击怪兽和防守怪兽的攻击力上升各自等级×200
function c32615065.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取防守怪兽
	local d=Duel.GetAttackTarget()
	if a:IsFaceup() and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle() then
		-- 使攻击怪兽的攻击力上升其等级×200
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(a:GetLevel()*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		a:RegisterEffect(e1)
		-- 使防守怪兽的攻击力上升其等级×200
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(d:GetLevel()*200)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		d:RegisterEffect(e2)
	end
end
-- 判断是否为融合召唤且被对方破坏送去墓地
function c32615065.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsReason(REASON_DESTROY)
		and rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 过滤函数，用于筛选可特殊召唤的「霸胜星 韦驮天」
function c32615065.spfilter(c,e,tp)
	return c:IsCode(96220350) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
		-- 检查是否有足够的特殊召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置效果目标，检查是否存在满足条件的怪兽
function c32615065.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查是否满足融合召唤的必须素材条件
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查是否存在满足spfilter条件的怪兽
		and Duel.IsExistingMatchingCard(c32615065.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息，指定将要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行特殊召唤操作，从额外卡组特殊召唤「霸胜星 韦驮天」
function c32615065.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足融合召唤的必须素材条件
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c32615065.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
