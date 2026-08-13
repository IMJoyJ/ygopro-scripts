--覇道星シュラ
-- 效果：
-- 「霸胜星 韦驮天」＋5星以上的战士族怪兽
-- ①：1回合1次，自己·对方的战斗阶段才能发动。对方场上的全部表侧表示怪兽的攻击力变成0。
-- ②：怪兽之间进行战斗的伤害计算时才能发动1次。那些进行战斗的双方怪兽的攻击力只在那次伤害计算时上升各自等级×200。
-- ③：融合召唤的这张卡被对方破坏送去墓地的场合才能发动。把1只「霸胜星 韦驮天」当作融合召唤从额外卡组特殊召唤。
function c32615065.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只「霸胜星 韦驮天」（卡号96220350）和1只5星以上的战士族怪兽作为融合素材。
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
-- 定义融合素材的额外条件：怪兽必须为战士族且等级在5以上。
function c32615065.ffilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(5)
end
-- 效果①的发动条件：当前为战斗阶段，且满足伤害步骤限制（伤害计算前可发动）。
function c32615065.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否处于战斗阶段（从战斗阶段开始到战斗阶段结束的范围内）。
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
		-- 追加伤害步骤限制条件：当前不是伤害步骤或尚未进行伤害计算，即不能在伤害计算时及之后发动。
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤条件：对方场上的表侧表示怪兽且攻击力大于0。
function c32615065.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 效果①的发动目标条件：确认对方场上存在至少1只表侧表示且攻击力大于0的怪兽（不取对象，满足条件即可发动）。
function c32615065.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时，检索对方怪兽区是否存在满足atkfilter（表侧表示且攻击力>0）的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c32615065.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果①处理：获取对方场上全部表侧表示怪兽，给每只怪兽赋予攻击力变为0的效果（持续时间为其在场期间）。
function c32615065.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上的全部表侧表示怪兽，作为要变更攻击力的对象集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部表侧表示怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 效果②的COST：以这张卡没有对应标记为发动条件，发动后给自己设置标记；该标记在伤害计算阶段结束时重置，从而保证每次伤害计算时此效果至多发动1次。
function c32615065.atkcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(32615065)==0 end
	c:RegisterFlagEffect(32615065,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 效果②的发动条件：存在攻击怪兽和被攻击怪兽，且二者控制者不同，即进行的是怪兽之间的战斗。
function c32615065.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的被攻击怪兽（攻击对象）。
	local d=Duel.GetAttackTarget()
	return d and a:GetControler()~=d:GetControler()
end
-- 效果②处理：若双方怪兽仍表侧表示且与本次战斗相关，则分别给攻击怪兽和被攻击怪兽附加攻击力上升各自等级×200的效果，效果持续到伤害计算结束。
function c32615065.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的被攻击怪兽（攻击对象）。
	local d=Duel.GetAttackTarget()
	if a:IsFaceup() and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle() then
		-- 那些进行战斗的双方怪兽的攻击力只在那次伤害计算时上升各自等级×200（此段为攻击怪兽上升其等级×200）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(a:GetLevel()*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		a:RegisterEffect(e1)
		-- 那些进行战斗的双方怪兽的攻击力只在那次伤害计算时上升各自等级×200（此段为攻击对象上升其等级×200）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(d:GetLevel()*200)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		d:RegisterEffect(e2)
	end
end
-- 效果③的发动条件：这张卡为融合召唤且被对方破坏并送去墓地，并且破坏前由自己控制、在自己场上。即满足“融合召唤的这张卡被对方破坏送去墓地”。
function c32615065.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsReason(REASON_DESTROY)
		and rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 筛选额外卡组中可作为融合召唤特殊召唤的「霸胜星 韦驮天」：是卡号96220350、能够以融合召唤方式特殊召唤、满足融合素材条件，且额外卡组怪兽有可用出场区域。
function c32615065.spfilter(c,e,tp)
	return c:IsCode(96220350) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
		-- 检查额外卡组怪兽可用的主要怪兽区/额外怪兽区空格数大于0，确保特殊召唤后能有位置。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果③的发动目标条件：没有必须作为融合素材的限制，且额外卡组存在符合条件的「霸胜星 韦驮天」。
function c32615065.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查是否存在必须作为融合素材的限制效果（如指定素材的卡），若有则不能发动。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查额外卡组是否存在至少1张满足spfilter（可被当作融合召唤特殊召唤的「霸胜星 韦驮天」）。
		and Duel.IsExistingMatchingCard(c32615065.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果处理将进行1次特殊召唤，位置为额外卡组，使其他卡能正确响应这次特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果③处理：从额外卡组选择1只符合条件的「霸胜星 韦驮天」，以融合召唤方式特殊召唤，并完成融合召唤后的手续。
function c32615065.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认没有必须作为融合素材的限制，若存在则终止处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 显示选择提示消息，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组选择1张符合条件的「霸胜星 韦驮天」。
	local g=Duel.SelectMatchingCard(tp,c32615065.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选择的「霸胜星 韦驮天」以融合召唤方式、表侧表示特殊召唤到自己的场上，并检查常规召唤条件/苏生限制。
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
