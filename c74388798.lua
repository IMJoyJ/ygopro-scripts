--サイレント・ソードマン LV5
-- 效果：
-- ①：这张卡不受对方的魔法卡的效果影响。
-- ②：这张卡直接攻击给与对方战斗伤害的场合，下次的自己回合的准备阶段把场上的这张卡送去墓地才能发动。从手卡·卡组把1只「沉默剑士 LV7」特殊召唤。
function c74388798.initial_effect(c)
	-- ①：这张卡不受对方的魔法卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c74388798.efilter)
	c:RegisterEffect(e1)
	-- ②：这张卡直接攻击给与对方战斗伤害的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetOperation(c74388798.damop)
	c:RegisterEffect(e2)
	-- 下次的自己回合的准备阶段把场上的这张卡送去墓地才能发动。从手卡·卡组把1只「沉默剑士 LV7」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74388798,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c74388798.spcon)
	e3:SetCost(c74388798.spcost)
	e3:SetTarget(c74388798.sptg)
	e3:SetOperation(c74388798.spop)
	c:RegisterEffect(e3)
end
c74388798.lvup={37267041}
c74388798.lvdn={1995985}
-- 过滤对方的魔法卡效果（使自身不受其影响）
function c74388798.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
-- 造成战斗伤害时，若是直接攻击则给自身注册Flag（用于记录直接攻击成功）
function c74388798.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断受到伤害的是对方玩家且没有攻击目标（即直接攻击）
	if ep~=tp and Duel.GetAttackTarget()==nil then
		e:GetHandler():RegisterFlagEffect(74388798,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,2)
	end
end
-- 特殊召唤效果的发动条件：当前是自己的回合且自身带有直接攻击成功的Flag
function c74388798.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己，且自身是否已注册直接攻击成功的Flag
	return tp==Duel.GetTurnPlayer() and e:GetHandler():GetFlagEffect(74388798)~=0
end
-- 特殊召唤效果的代价：将场上的这张卡送去墓地
function c74388798.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤手卡·卡组中可以无视召唤条件特殊召唤的「沉默剑士 LV7」
function c74388798.spfilter(c,e,tp)
	return c:IsCode(37267041) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 特殊召唤效果的发动准备：检查怪兽区域空位及手卡·卡组是否存在可特召的卡，并设置特殊召唤的操作信息
function c74388798.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（因为自身作为代价送墓，所以可用格子数大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或卡组中是否存在至少1只满足特召条件的「沉默剑士 LV7」
		and Duel.IsExistingMatchingCard(c74388798.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的处理：从手卡·卡组选择1只「沉默剑士 LV7」无视召唤条件特殊召唤
function c74388798.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足特召条件的「沉默剑士 LV7」
	local g=Duel.SelectMatchingCard(tp,c74388798.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽无视召唤条件和苏生限制以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
