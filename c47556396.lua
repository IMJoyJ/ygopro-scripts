--サブテラーマリス・エルガウスト
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ③：这张卡反转的场合，以场上1只怪兽为对象才能发动。那只怪兽是守备表示的场合，变成表侧攻击表示。那只怪兽的攻击力变成0。
function c47556396.initial_effect(c)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡反转的场合，以场上1只怪兽为对象才能发动。那只怪兽是守备表示的场合，变成表侧攻击表示。那只怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47556396,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,47556396)
	e1:SetTarget(c47556396.target)
	e1:SetOperation(c47556396.operation)
	c:RegisterEffect(e1)
	-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47556396,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetCondition(c47556396.spcon)
	e2:SetTarget(c47556396.sptg)
	e2:SetOperation(c47556396.spop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(47556396,2))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c47556396.postg)
	e3:SetOperation(c47556396.posop)
	c:RegisterEffect(e3)
end
-- 定义③效果的对象过滤条件：可选择场上守备表示或攻击力大于0的怪兽作为对象。
function c47556396.filter(c)
	return c:IsDefensePos() or c:GetAttack()>0
end
-- ③效果的取对象目标函数：处理连锁指定对象时校验对象是否合法，发动时检查是否有可选的怪兽，并提示玩家选择1只场上符合条件的怪兽作为对象。
function c47556396.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c47556396.filter(chkc) end
	-- 发动合法性检查：确认场上存在至少1只满足条件的怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c47556396.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择效果的对象”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择场上1只满足条件的怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,c47556396.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ③效果处理：取得对象，若对象仍与该效果关联，则当对象是守备表示时改为表侧攻击表示，之后若对象为表侧表示则将其攻击力变成0。
function c47556396.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsDefensePos() then
		-- 将对象怪兽的表示形式变更为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
	if tc:IsFaceup() then
		-- 那只怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断事件怪兽是否原是表侧表示、现为里侧表示且控制者为发动者，用于筛选“表侧怪兽变成里侧表示”的事件。
function c47556396.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown() and c:IsControler(tp)
end
-- ①效果的发动条件：存在满足条件的表侧变里侧怪兽，且自己场上没有表侧表示怪兽。
function c47556396.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47556396.cfilter,1,nil,tp)
		-- 确认自己场上没有表侧表示怪兽存在。
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动条件判定与操作登记：chk==0时检查空位、无表侧怪兽且可特殊召唤；chk==1时登记特殊召唤操作信息。
function c47556396.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上有空余的怪兽区域可进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 再次确认自己场上没有表侧表示怪兽存在。
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本效果将进行特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其从手卡以表侧守备表示特殊召唤。
function c47556396.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 以表侧守备表示将这张卡特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动条件判定与处理：chk==0时检查自身可变为里侧守备且本回合未使用过该效果；chk==1时登记本回合已使用该效果并登记改变表示形式的操作信息。
function c47556396.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(47556396)==0 end
	c:RegisterFlagEffect(47556396,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 登记本效果将改变这张卡表示形式的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联且表侧表示，则将其变成里侧守备表示。
function c47556396.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡变更为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
