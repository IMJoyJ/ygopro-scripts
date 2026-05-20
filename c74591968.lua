--ミスティック・ソードマン LV4
-- 效果：
-- 当这张卡在通常召唤的场合时，必须里侧守备表示出场。攻击里侧守备表示怪兽的场合，不进行战斗伤害，那只怪兽以里侧守备表示的状态直接破坏。这张卡战斗破坏怪兽的回合的结束阶段，可以把这张卡送去墓地，从手卡·卡组特殊召唤1只「谜之剑士 LV6」
function c74591968.initial_effect(c)
	-- 这张卡战斗破坏怪兽的回合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c74591968.bdop)
	c:RegisterEffect(e1)
	-- 攻击里侧守备表示怪兽的场合，不进行战斗伤害，那只怪兽以里侧守备表示的状态直接破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74591968,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c74591968.descon)
	e2:SetTarget(c74591968.destg)
	e2:SetOperation(c74591968.desop)
	c:RegisterEffect(e2)
	-- 这张卡战斗破坏怪兽的回合的结束阶段，可以把这张卡送去墓地，从手卡·卡组特殊召唤1只「谜之剑士 LV6」
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74591968,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCondition(c74591968.spcon)
	e3:SetCost(c74591968.spcost)
	e3:SetTarget(c74591968.sptg)
	e3:SetOperation(c74591968.spop)
	c:RegisterEffect(e3)
	-- 当这张卡在通常召唤的场合时，必须里侧守备表示出场。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e4:SetCondition(c74591968.sumcon)
	c:RegisterEffect(e4)
end
c74591968.lvup={60482781}
c74591968.lvdn={47507260}
-- 战斗破坏怪兽时，给自身注册一个在回合结束前有效的Flag，用于记录本回合曾战斗破坏过怪兽
function c74591968.bdop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(74591968,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查此卡是否为攻击怪兽，且攻击目标是里侧守备表示怪兽
function c74591968.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 返回是否自身是攻击怪兽，且攻击目标存在、为里侧表示、且为守备表示
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFacedown() and d:IsDefensePos()
end
-- 破坏效果的发动准备，设置破坏操作信息
function c74591968.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为破坏攻击目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 破坏效果的处理，若攻击目标仍在战斗中则将其破坏
function c74591968.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 因效果破坏该攻击目标怪兽
		Duel.Destroy(d,REASON_EFFECT)
	end
end
-- 检查自身是否在本回合战斗破坏过怪兽（检查Flag是否存在）
function c74591968.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(74591968)>0
end
-- 特殊召唤效果的代价处理，检查并把自身送去墓地
function c74591968.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤手卡或卡组中可以无视召唤条件特殊召唤的「谜之剑士 LV6」
function c74591968.spfilter(c,e,tp)
	return c:IsCode(60482781) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 特殊召唤效果的发动准备，检查怪兽区域空位以及手卡、卡组中是否存在可特殊召唤的卡，并设置特殊召唤操作信息
function c74591968.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（因为自身作为代价送去墓地，所以空位要求大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或卡组中是否存在至少1张满足特殊召唤条件的「谜之剑士 LV6」
		and Duel.IsExistingMatchingCard(c74591968.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的处理，从手卡或卡组选择1只「谜之剑士 LV6」特殊召唤
function c74591968.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1张满足特殊召唤条件的「谜之剑士 LV6」
	local g=Duel.SelectMatchingCard(tp,c74591968.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽无视召唤条件和苏生限制以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 限制召唤方式，使该卡在通常召唤时不能表侧表示召唤（必须里侧守备表示出场）
function c74591968.sumcon(e,c,minc)
	if not c then return true end
	return false
end
