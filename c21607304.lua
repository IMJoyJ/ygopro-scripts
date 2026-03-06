--サブテラーマリス・ボルティニア
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ③：这张卡反转的场合，以对方场上1只里侧表示怪兽为对象才能发动。那只怪兽的控制权直到下次的自己结束阶段得到。
function c21607304.initial_effect(c)
	-- ③：这张卡反转的场合，以对方场上1只里侧表示怪兽为对象才能发动。那只怪兽的控制权直到下次的自己结束阶段得到。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21607304,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,21607304)
	e1:SetTarget(c21607304.target)
	e1:SetOperation(c21607304.operation)
	c:RegisterEffect(e1)
	-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21607304,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetCondition(c21607304.spcon)
	e2:SetTarget(c21607304.sptg)
	e2:SetOperation(c21607304.spop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21607304,2))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c21607304.postg)
	e3:SetOperation(c21607304.posop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断目标怪兽是否为里侧表示且可以改变控制权
function c21607304.filter(c)
	return c:IsFacedown() and c:IsControlerCanBeChanged()
end
-- 设置效果目标为对方场上的里侧表示怪兽
function c21607304.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c21607304.filter(chkc) end
	-- 判断是否存在满足条件的对方场上的里侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c21607304.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上的1只里侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c21607304.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息，表示将改变目标怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 处理效果的发动和控制权转移逻辑
function c21607304.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	local tct=1
	-- 如果当前回合玩家不是效果发动者，则控制权持续到下次结束阶段
	if Duel.GetTurnPlayer()~=tp then tct=2
	-- 如果当前阶段是结束阶段，则控制权持续到下次结束阶段
	elseif Duel.GetCurrentPhase()==PHASE_END then tct=3 end
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 让效果发动者获得目标怪兽的控制权直到下次结束阶段
		Duel.GetControl(tc,tp,PHASE_END,tct)
	end
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示变为里侧表示且属于效果发动者
function c21607304.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown() and c:IsControler(tp)
end
-- 判断是否满足①效果的发动条件：有怪兽从表侧变为里侧且自己场上没有表侧表示怪兽
function c21607304.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21607304.cfilter,1,nil,tp)
		-- 判断自己场上是否没有表侧表示怪兽
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置①效果的发动条件和特殊召唤目标
function c21607304.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己场上是否没有表侧表示怪兽
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置效果操作信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理①效果的发动和特殊召唤逻辑
function c21607304.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡从手牌特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置②效果的发动条件和表示形式变更目标
function c21607304.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(21607304)==0 end
	c:RegisterFlagEffect(21607304,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置效果操作信息，表示将此卡变为里侧守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 处理②效果的发动和表示形式变更逻辑
function c21607304.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将此卡变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
