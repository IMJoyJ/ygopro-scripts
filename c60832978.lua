--ダブル・リゾネーター
-- 效果：
-- 「双头共鸣者」的②的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽当作调整使用。
-- ②：把墓地的这张卡除外，以自己场上1只恶魔族怪兽为对象才能发动。这个回合，那只恶魔族怪兽当作调整使用。
function c60832978.initial_effect(c)
	-- 对应①效果：“这张卡召唤·特殊召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽当作调整使用。”中的召唤成功部分；特殊召唤成功部分见e2。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetTarget(c60832978.target1)
	e1:SetOperation(c60832978.operation1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 对应②效果：“把墓地的这张卡除外，以自己场上1只恶魔族怪兽为对象才能发动。这个回合，那只恶魔族怪兽当作调整使用。”
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,60832978)
	-- 设置②效果的发动代价为把墓地中的这张卡除外（aux.bfgcost会检查此卡是否可从墓地除外并执行除外）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c60832978.target2)
	e3:SetOperation(c60832978.operation2)
	c:RegisterEffect(e3)
end
-- 定义①效果的对象选择条件：怪兽必须是表侧表示且不是调整怪兽（已经是调整的怪兽不能作为对象）。
function c60832978.filter1(c)
	return c:IsFaceup() and not c:IsType(TYPE_TUNER)
end
-- ①效果的取对象处理函数：判断是否存在合法对象，并选择场上1只表侧表示且非调整的怪兽为对象。
function c60832978.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c60832978.filter1(chkc) end
	-- 发动时检查：是否存在1只以上表侧表示且非调整的怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c60832978.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家发送提示信息：请选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 令操作玩家从双方场上选择1只表侧表示且非调整的怪兽作为效果对象。
	Duel.SelectTarget(tp,c60832978.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ①效果处理函数：使对象怪兽获得“当作调整使用”的效果，持续到这个回合结束（若对象仍可被效果处理且表侧表示）。
function c60832978.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取①效果所选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 对应①效果后半句：“这个回合，那只表侧表示怪兽当作调整使用。”——给对象怪兽添加调整种类（TYPE_TUNER）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
-- 定义②效果的对象选择条件：怪兽必须是自己场上的表侧表示、非调整、恶魔族怪兽。
function c60832978.filter2(c)
	return c60832978.filter1(c) and c:IsRace(RACE_FIEND)
end
-- ②效果的取对象处理函数：判断是否存在合法对象，并选择自己场上1只符合条件的恶魔族怪兽为对象。
function c60832978.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c60832978.filter2(chkc) end
	-- 发动时检查：是否存在1只以上自己场上的表侧表示、非调整的恶魔族怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c60832978.filter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家发送提示信息：请选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 令操作玩家从自己场上选择1只表侧表示且非调整的恶魔族怪兽作为效果对象。
	Duel.SelectTarget(tp,c60832978.filter2,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理函数：使对象恶魔族怪兽获得“当作调整使用”的效果，持续到这个回合结束（若对象仍可被效果处理且表侧表示且为恶魔族）。
function c60832978.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果所选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRace(RACE_FIEND) then
		-- 对应②效果后半句：“这个回合，那只恶魔族怪兽当作调整使用。”——给对象恶魔族怪兽添加调整种类（TYPE_TUNER）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
