--カイザー・グライダー－ゴールデン・バースト
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把自己场上1只怪兽解放才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
-- ②：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。这张卡的攻击力直到回合结束时变成和那只怪兽的攻击力相同。
function c41002238.initial_effect(c)
	-- ①：把自己场上1只怪兽解放才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41002238,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,41002238)
	e1:SetCost(c41002238.spcost)
	e1:SetTarget(c41002238.sptg)
	e1:SetOperation(c41002238.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。这张卡的攻击力直到回合结束时变成和那只怪兽的攻击力相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41002238,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c41002238.atktg)
	e2:SetOperation(c41002238.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 检查是否有满足条件的怪兽可以解放并用于特殊召唤
function c41002238.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家可解放的怪兽组
	local g=Duel.GetReleaseGroup(tp)
	-- 判断是否满足解放条件
	if chk==0 then return g:CheckSubGroup(aux.mzctcheckrel,1,1,tp) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的怪兽组
	local rg=g:SelectSubGroup(tp,aux.mzctcheckrel,false,1,1,tp)
	-- 使用代替解放次数
	aux.UseExtraReleaseCount(rg,tp)
	-- 实际解放选中的怪兽
	Duel.Release(rg,REASON_COST)
end
-- 判断是否可以特殊召唤此卡
function c41002238.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c41002238.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断目标怪兽是否满足攻击力变更条件
function c41002238.filter(c,atk)
	return c:IsFaceup() and not c:IsAttack(atk)
end
-- 设置攻击力变更效果的目标
function c41002238.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c41002238.filter(chkc,c:GetAttack()) end
	if chk==0 then return c:IsRelateToEffect(e)
		-- 判断是否存在符合条件的目标怪兽
		and Duel.IsExistingTarget(c41002238.filter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择效果对象怪兽
	Duel.SelectTarget(tp,c41002238.filter,tp,0,LOCATION_MZONE,1,1,nil,c:GetAttack())
end
-- 执行攻击力变更效果
function c41002238.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡的攻击力设置为与目标怪兽相同
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
