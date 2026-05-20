--スターダスト・ファントム
-- 效果：
-- 自己场上存在的这张卡被对方破坏送去墓地时，可以选择自己墓地存在的1只「星尘龙」表侧守备表示特殊召唤。此外，把墓地存在的这张卡从游戏中除外，选择自己场上表侧表示存在的1只龙族的同调怪兽才能发动。选择的怪兽1回合只有1次不会被战斗破坏，这个效果适用的伤害步骤结束时攻击力·守备力下降800。
function c80244114.initial_effect(c)
	-- 将「星尘龙」加入到这张卡记载的卡片密码列表中
	aux.AddCodeList(c,44508094)
	-- 自己场上存在的这张卡被对方破坏送去墓地时，可以选择自己墓地存在的1只「星尘龙」表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80244114,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c80244114.spcon)
	e1:SetTarget(c80244114.sptg)
	e1:SetOperation(c80244114.spop)
	c:RegisterEffect(e1)
	-- 此外，把墓地存在的这张卡从游戏中除外，选择自己场上表侧表示存在的1只龙族的同调怪兽才能发动。选择的怪兽1回合只有1次不会被战斗破坏，这个效果适用的伤害步骤结束时攻击力·守备力下降800。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80244114,1))  --"战斗破坏耐性"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c80244114.indcost)
	e2:SetTarget(c80244114.indtg)
	e2:SetOperation(c80244114.indop)
	c:RegisterEffect(e2)
end
-- 判断发动条件：自己场上的这张卡因对方被破坏并送去墓地
function c80244114.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤出墓地中可以表侧守备表示特殊召唤的「星尘龙」
function c80244114.spfilter(c,e,tp)
	return c:IsCode(44508094) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的靶向/目标选择处理，确认是否存在合法的特殊召唤对象并进行选择
function c80244114.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c80244114.spfilter(chkc,e,tp) end
	-- 在效果发动阶段，检测自己墓地是否存在至少1只满足特殊召唤条件的「星尘龙」
	if chk==0 then return Duel.IsExistingTarget(c80244114.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向发动效果的玩家提示“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地存在的1只「星尘龙」作为效果的对象
	local g=Duel.SelectTarget(tp,c80244114.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息，表明此效果包含将选中的1张卡特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的执行处理，将选择的怪兽特殊召唤
function c80244114.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 判断并执行发动代价：将墓地的这张卡除外
function c80244114.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将墓地的这张卡表侧表示除外作为发动的代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤出自己场上表侧表示存在的龙族同调怪兽
function c80244114.indfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
-- 战斗破坏耐性效果的靶向/目标选择处理，确认是否存在合法的龙族同调怪兽并进行选择
function c80244114.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c80244114.indfilter(chkc) end
	-- 在效果发动阶段，检测自己场上是否存在至少1只表侧表示的龙族同调怪兽
	if chk==0 then return Duel.IsExistingTarget(c80244114.indfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动效果的玩家提示“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上表侧表示存在的1只龙族同调怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c80244114.indfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 战斗破坏耐性效果的执行处理，为选择的怪兽赋予“1回合只有1次不会被战斗破坏”和“伤害步骤结束时攻击力·守备力下降800”的效果
function c80244114.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的龙族同调怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽1回合只有1次不会被战斗破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetCountLimit(1)
		e1:SetValue(c80244114.valcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果适用的伤害步骤结束时攻击力·守备力下降800
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e2:SetCode(EVENT_DAMAGE_STEP_END)
		e2:SetOperation(c80244114.addown)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 判断破坏原因是否为战斗破坏，若是则注册标记并使不会被破坏的效果适用
function c80244114.valcon(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		e:GetHandler():RegisterFlagEffect(80244114,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
		return true
	else return false end
end
-- 在伤害步骤结束时，若该怪兽适用了不会被战斗破坏的效果，则使其攻击力·守备力下降800
function c80244114.addown(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(80244114)==0 then return end
	-- 攻击力·守备力下降800
	local e1=Effect.CreateEffect(e:GetOwner())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e:GetHandler():RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e:GetHandler():RegisterEffect(e2)
end
