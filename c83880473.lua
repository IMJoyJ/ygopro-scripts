--ウォークライ・スピリッツ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的战斗阶段可以以自己墓地1只「战吼」怪兽为对象，从以下效果选择1个发动。
-- ●作为对象的怪兽攻击表示特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能直接攻击。
-- ●作为对象的怪兽守备表示特殊召唤。这个回合，自己的「战吼」怪兽各有1次不会被战斗破坏。
function c83880473.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的战斗阶段可以以自己墓地1只「战吼」怪兽为对象，从以下效果选择1个发动。●作为对象的怪兽攻击表示特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能直接攻击。●作为对象的怪兽守备表示特殊召唤。这个回合，自己的「战吼」怪兽各有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,83880473+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c83880473.condition)
	e1:SetTarget(c83880473.target)
	e1:SetOperation(c83880473.activate)
	c:RegisterEffect(e1)
end
-- 判定当前阶段是否为自己或对方的战斗阶段
function c83880473.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤自己墓地中可以以攻击表示特殊召唤的「战吼」怪兽
function c83880473.afilter(c,e,tp)
	return c:IsSetCard(0x15f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 过滤自己墓地中可以以守备表示特殊召唤的「战吼」怪兽
function c83880473.dfilter(c,e,tp)
	return c:IsSetCard(0x15f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的对象选择与合法性检测，并让玩家选择要发动的效果分支
function c83880473.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local op=e:GetLabel()
		return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE)
			and (op==0 and c83880473.afilter(chkc,e,tp) or op==1 and c83880473.dfilter(chkc,e,tp))
	end
	-- 检查墓地是否存在可以攻击表示特殊召唤的「战吼」怪兽
	local b1=Duel.IsExistingTarget(c83880473.afilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	-- 检查墓地是否存在可以守备表示特殊召唤的「战吼」怪兽
	local b2=Duel.IsExistingTarget(c83880473.dfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	-- 检查发动时自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (b1 or b2) end
	local op=0
	if b1 and b2 then
		-- 让玩家选择攻击表示特殊召唤或守备表示特殊召唤
		op=Duel.SelectOption(tp,aux.Stringid(83880473,0),aux.Stringid(83880473,1))  --"攻击表示特殊召唤/守备表示特殊召唤"
	elseif b1 then
		-- 让玩家选择攻击表示特殊召唤
		op=Duel.SelectOption(tp,aux.Stringid(83880473,0))  --"攻击表示特殊召唤"
	else
		-- 让玩家选择守备表示特殊召唤
		op=Duel.SelectOption(tp,aux.Stringid(83880473,1))+1  --"守备表示特殊召唤"
	end
	e:SetLabel(op)
	local filter=c83880473.afilter
	if op==1 then filter=c83880473.dfilter end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地的一只「战吼」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理中的操作信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理，根据选择的分支将对象怪兽特殊召唤，并适用对应的后续效果
function c83880473.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	local op=e:GetLabel()
	if tc:IsRelateToEffect(e) then
		if op==0 then
			-- 将对象怪兽以表侧攻击表示特殊召唤（分步处理，以便后续添加无效化等效果）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
			-- 这个效果特殊召唤的怪兽在这个回合效果无效化
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
			-- 不能直接攻击。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
			-- 完成特殊召唤的最终处理
			Duel.SpecialSummonComplete()
		else
			-- 将对象怪兽以表侧守备表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	if op==1 then
		-- 这个回合，自己的「战吼」怪兽各有1次不会被战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c83880473.indtg)
		e1:SetValue(c83880473.indct)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将不会被战斗破坏的效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤适用战斗破坏抗性的卡，必须是场上表侧表示的「战吼」怪兽
function c83880473.indtg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x15f)
end
-- 限制抗性仅在因战斗破坏时适用1次
function c83880473.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
