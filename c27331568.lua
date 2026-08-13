--荘厳なる機械天使
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己的手卡·场上1只「电子化天使」仪式怪兽解放，以自己场上1只天使族·光属性怪兽为对象才能发动。作为对象的怪兽的攻击力·守备力直到回合结束时上升解放的怪兽的等级×200。这个回合，作为对象的怪兽和从额外卡组特殊召唤的对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
function c27331568.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己的手卡·场上1只「电子化天使」仪式怪兽解放，以自己场上1只天使族·光属性怪兽为对象才能发动。作为对象的怪兽的攻击力·守备力直到回合结束时上升解放的怪兽的等级×200。这个回合，作为对象的怪兽和从额外卡组特殊召唤的对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,27331568+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果只能在非伤害步骤或伤害计算前发动（即不能在伤害计算后发动），配合EFFECT_FLAG_DAMAGE_STEP实现在伤害步骤中仅限伤害计算前发动的规则限制。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c27331568.cost)
	e1:SetTarget(c27331568.target)
	e1:SetOperation(c27331568.activate)
	c:RegisterEffect(e1)
end
-- 定义可解放的怪兽筛选条件：必须满足卡名属于「电子化天使」系列（0x2093）、是仪式怪兽、等级1以上，并且自己场上还存在另一只可成为对象的天使族·光属性表侧表示怪兽（排除自身），以确保发动时满足解放和取对象的要求。
function c27331568.cfilter(c,tp)
	return c:IsSetCard(0x2093) and c:IsType(TYPE_RITUAL) and c:IsLevelAbove(1)
		-- 追加判定条件：除了解放的这张卡以外，自己场上存在至少1张满足filter条件的表侧表示光属性天使族怪兽，保证效果发动时能够选择对象。
		and Duel.IsExistingTarget(c27331568.filter,tp,LOCATION_MZONE,0,1,c)
end
-- 定义效果对象的选择条件：怪兽必须是表侧表示、光属性、天使族。
function c27331568.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)
end
-- 代价处理：先检查能否从手卡·场上解放1只满足条件的「电子化天使」仪式怪兽，若能则选择该怪兽解放，并将其等级记录到效果标签中，用于后续攻击力·守备力的上升计算。
function c27331568.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 费用合法性检查（chk==0）：确认存在至少1只满足解放条件的「电子化天使」仪式怪兽，且同时通过cfilter确保场上存在可选对象，若不存在则效果不能发动。
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c27331568.cfilter,1,REASON_COST,true,nil,tp) end
	-- 从手卡·场上选择1只满足条件的「电子化天使」仪式怪兽作为解放代价。
	local g=Duel.SelectReleaseGroupEx(tp,c27331568.cfilter,1,1,REASON_COST,true,nil,tp)
	e:SetLabel(g:GetFirst():GetLevel())
	-- 将选中的怪兽解放，作为发动费用（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 对象选择处理：效果发动时确认对象条件，提示玩家选择自己场上1张表侧表示光属性天使族怪兽，并将其设置为效果对象。
function c27331568.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c27331568.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家显示选择提示消息，提示内容为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1张满足filter条件的表侧表示光属性天使族怪兽作为效果对象（取对象发动）。
	Duel.SelectTarget(tp,c27331568.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：从效果标签取得解放怪兽的等级，使对象怪兽攻击力·守备力直到回合结束时上升等级×200；并注册无效化效果，使这个回合中与对象怪兽战斗的、从额外卡组特殊召唤的对方怪兽在战斗阶段内效果无效。
function c27331568.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	local c=e:GetHandler()
	-- 取得效果处理时选择的对象怪兽（本效果只取1个对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 作为对象的怪兽的攻击力·守备力直到回合结束时上升解放的怪兽的等级×200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(lv*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		-- 这个回合，作为对象的怪兽和从额外卡组特殊召唤的对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetTargetRange(0,LOCATION_MZONE)
		e3:SetTarget(c27331568.distg)
		e3:SetLabel(tc:GetFieldID())
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将EFFECT_DISABLE效果注册到场上：当对方从额外卡组特殊召唤的怪兽满足distg条件时，使该怪兽效果无效化。
		Duel.RegisterEffect(e3,tp)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		-- 将EFFECT_DISABLE_EFFECT效果注册到场上：与e3配合，使满足条件的对方怪兽从额外卡组特殊召唤后其效果也被无效化（即使离场仍保持无效），确保战斗阶段内效果无效化彻底生效。
		Duel.RegisterEffect(e4,tp)
	end
end
-- 无效化目标判断函数：若对方怪兽已被本效果标记（FlagEffect 27331568）则持续使其无效；若对方怪兽从额外卡组特殊召唤，且其战斗对象（GetBattleTarget）是作为对象的本方怪兽（通过FieldID匹配），则将其标记并立即触发无效化。
function c27331568.distg(e,c)
	if c:GetFlagEffect(27331568)>0 then return true end
	if c:IsSummonLocation(LOCATION_EXTRA) and c:GetBattleTarget()~=nil and c:GetBattleTarget():GetFieldID()==e:GetLabel() then
		c:RegisterFlagEffect(27331568,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
		-- 立即刷新效果状态，使刚被标记的对方怪兽即刻变为效果无效状态，无需等待下一次处理。
		Duel.AdjustInstantly(e:GetHandler())
		return true
	end
	return false
end
