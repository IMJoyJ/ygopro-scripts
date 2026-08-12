--E-HERO ヘル・ゲイナー
-- 效果：
-- ①：自己主要阶段1把场上的这张卡除外，以自己场上1只恶魔族怪兽为对象才能发动。那只自己的恶魔族怪兽只要在场上表侧表示存在，同1次的战斗阶段中可以作2次攻击。
-- ②：这张卡为①的效果发动而被除外的场合，第2次的自己准备阶段发动。这张卡攻击表示特殊召唤。
function c95943058.initial_effect(c)
	-- ①：自己主要阶段1把场上的这张卡除外，以自己场上1只恶魔族怪兽为对象才能发动。那只自己的恶魔族怪兽只要在场上表侧表示存在，同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95943058,0))  --"两次攻击"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c95943058.condition)
	e1:SetCost(c95943058.cost)
	e1:SetTarget(c95943058.target)
	e1:SetOperation(c95943058.operation)
	c:RegisterEffect(e1)
end
-- 定义效果①的发动条件函数
function c95943058.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能够进入战斗阶段（用于判定是否为主要阶段1）
	return Duel.IsAbleToEnterBP()
end
-- 定义效果①的发动代价函数
function c95943058.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将作为发动代价的自身卡片表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤出自己场上表侧表示、恶魔族且未拥有追加攻击效果的怪兽
function c95943058.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 定义效果①的对象选择与发动准备函数
function c95943058.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c95943058.filter(chkc) end
	-- 在发动时，检查自己场上是否存在除自身以外的、满足条件的恶魔族怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c95943058.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只满足条件的恶魔族怪兽作为效果对象
	Duel.SelectTarget(tp,c95943058.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 定义效果①的效果处理函数
function c95943058.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只自己的恶魔族怪兽只要在场上表侧表示存在，同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
	-- ②：这张卡为①的效果发动而被除外的场合，第2次的自己准备阶段发动。这张卡攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95943058,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	e2:SetCondition(c95943058.spcon)
	e2:SetTarget(c95943058.sptg)
	e2:SetOperation(c95943058.spop)
	-- 将触发特殊召唤的回合数设置为当前回合数加2（即第2次自己的准备阶段）
	e2:SetLabel(Duel.GetTurnCount(tp)+2)
	c:RegisterEffect(e2)
end
-- 定义效果②的发动条件函数
function c95943058.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己，且当前回合数是否等于预设的第2个回合数
	return Duel.GetTurnPlayer()==tp and e:GetLabel()==Duel.GetTurnCount(tp)
end
-- 定义效果②的发动准备与效果分类注册函数
function c95943058.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息，表明该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果②的效果处理函数
function c95943058.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将除外区的这张卡以攻击表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)
end
