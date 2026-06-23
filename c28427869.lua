--スモーク・モスキート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击要让自己受到战斗伤害的伤害计算时才能发动。这张卡从手卡特殊召唤，那次战斗发生的对自己的战斗伤害变成一半，那次伤害步骤结束后战斗阶段结束。
-- ②：以自己场上1只表侧表示怪兽为对象才能发动。这张卡的等级直到回合结束时变成和那只怪兽相同。
function c28427869.initial_effect(c)
	-- ①：对方怪兽的攻击要让自己受到战斗伤害的伤害计算时才能发动。这张卡从手卡特殊召唤，那次战斗发生的对自己的战斗伤害变成一半，那次伤害步骤结束后战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,28427869)
	e1:SetCondition(c28427869.condition)
	e1:SetTarget(c28427869.sptg)
	e1:SetOperation(c28427869.spop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只表侧表示怪兽为对象才能发动。这张卡的等级直到回合结束时变成和那只怪兽相同。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,28427870)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c28427869.lvtg)
	e2:SetOperation(c28427869.lvop)
	c:RegisterEffect(e2)
end
-- 效果发动的条件：攻击怪兽控制者不是自己
function c28427869.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击怪兽控制者不是自己
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果的发动条件判断：玩家未受到‘不会受到战斗伤害’影响、本次战斗伤害大于0、场上怪兽区域有空位、此卡可特殊召唤
function c28427869.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 玩家未受到‘不会受到战斗伤害’影响、本次战斗伤害大于0
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,EFFECT_AVOID_BATTLE_DAMAGE) and Duel.GetBattleDamage(tp)>0
		-- 场上怪兽区域有空位、此卡可特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息：特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：特殊召唤此卡，若成功则设置战斗伤害减半效果和跳过战斗阶段结束步骤效果
function c28427869.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 特殊召唤此卡成功
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 设置战斗伤害减半效果：将受到的战斗伤害减半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(HALF_DAMAGE)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 注册战斗伤害减半效果
		Duel.RegisterEffect(e1,tp)
		-- 设置跳过战斗阶段结束步骤效果：在伤害步骤结束后跳过战斗阶段
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_DAMAGE_STEP_END)
		e2:SetOperation(c28427869.skipop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		-- 注册跳过战斗阶段结束步骤效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 跳过战斗阶段结束步骤效果处理函数
function c28427869.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过当前回合玩家的战斗阶段
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
-- 等级变化效果的对象筛选函数：对象怪兽等级大于0、正面表示、且等级与自身不同
function c28427869.lvfilter(c,lv)
	return c:GetLevel()>0 and c:IsFaceup() and not c:IsLevel(lv)
end
-- 效果的发动条件判断：选择场上1只符合条件的怪兽作为对象
function c28427869.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lv=e:GetHandler():GetLevel()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c28427869.lvfilter(chkc,lv) end
	-- 场上存在符合条件的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c28427869.lvfilter,tp,LOCATION_MZONE,0,1,nil,lv) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只符合条件的怪兽作为对象
	Duel.SelectTarget(tp,c28427869.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,lv)
end
-- 效果处理：将此卡等级变为对象怪兽等级
function c28427869.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 设置等级变化效果：将此卡等级变为对象怪兽等级
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
