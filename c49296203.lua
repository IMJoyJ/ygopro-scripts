--カラクリ法師 九七六参
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1只「机巧」怪兽为对象才能发动。那只怪兽的表示形式变更，这张卡当作调整使用特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族·地属性怪兽不能从额外卡组特殊召唤。
-- ②：这张卡可以攻击的场合必须作出攻击。
-- ③：这张卡被选择作为攻击对象的场合发动。这张卡的表示形式变更。
function c49296203.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡存在的场合，以自己场上1只「机巧」怪兽为对象才能发动。那只怪兽的表示形式变更，这张卡当作调整使用特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族·地属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49296203,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,49296203)
	e1:SetTarget(c49296203.sptg)
	e1:SetOperation(c49296203.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡可以攻击的场合必须作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e2)
	-- ③：这张卡被选择作为攻击对象的场合发动。这张卡的表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49296203,1))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetOperation(c49296203.posop)
	c:RegisterEffect(e3)
end
c49296203.treat_itself_tuner=true
-- 筛选可作为①效果对象的「机巧」怪兽：需要表侧表示、属于「机巧」系列字段、且能够被效果改变表示形式。
function c49296203.posfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x11) and c:IsCanChangePosition()
end
-- ①效果的发动条件判断与目标选择函数：检查存在可用怪兽区域、自己能特殊召唤，并存在满足条件的「机巧」怪兽；同时处理连锁时对象是否合法。
function c49296203.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c49296203.posfilter(chkc) end
	-- 发动条件检查：自己场上主要怪兽区域是否有空闲格子，用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：自己场上是否存在至少1只满足posfilter条件（表侧表示·「机巧」字段·可变更表示形式）的怪兽，可作为效果对象。
		and Duel.IsExistingTarget(c49296203.posfilter,tp,LOCATION_MZONE,0,1,nil)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 选择目标前向当前玩家发送“请选择要改变表示形式的怪兽”的提示消息，用于选择卡片的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从自己场上选择1只满足条件的「机巧」怪兽作为效果对象，并将该怪兽登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c49296203.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：声明本效果包含变更表示形式的处理，对象为已选择的g（1张怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 设置操作信息：声明本效果包含特殊召唤的处理，要特殊召唤的卡为这张卡自身（c）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理函数：对象怪兽仍与效果关联时先变更其表示形式；这张卡仍与效果关联时以特殊召唤步骤尝试将其表侧攻击表示特殊召唤；若成功，则给这张卡附加一个临时效果，使其获得调整属性（当作调整使用）。
function c49296203.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联，并将其表示形式反转变更（攻击表示与守备表示互换），变更成功返回非0。
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0
		-- 确认这张卡仍与效果关联后，将其作为特殊召唤的一步，以表侧攻击表示特殊召唤（检查召唤条件/苏生限制）。
		and c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这张卡当作调整使用特殊召唤（的调整化部分）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	-- 完成由SpecialSummonStep开始的依次特殊召唤流程，确认这张卡特殊召唤成功。
	Duel.SpecialSummonComplete()
	-- 这个效果的发动后，直到回合结束时自己不是机械族·地属性怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c49296203.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果e2注册到决斗中，对该效果的发动者tp生效，使tp在本回合结束时之前不能从额外卡组特殊召唤非机械族·地属性的怪兽。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃效果的过滤条件：若怪兽不是机械族或不是地属性，并且来自额外卡组，则禁止特殊召唤；即只允许从额外卡组特殊召唤机械族·地属性的怪兽。
function c49296203.splimit(e,c)
	return (not c:IsAttribute(ATTRIBUTE_EARTH) or not c:IsRace(RACE_MACHINE)) and c:IsLocation(LOCATION_EXTRA)
end
-- ③效果的处理函数：当这张卡被选择为攻击对象时，若它仍表侧表示且与效果关联，则变更其表示形式。
function c49296203.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 变更这张卡的表示形式：若为表侧攻击表示则变为表侧守备表示，若为表侧守备表示则变为表侧攻击表示，里侧表示不会改变。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
