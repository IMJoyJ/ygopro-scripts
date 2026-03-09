--カラクリ法師 九七六参
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1只「机巧」怪兽为对象才能发动。那只怪兽的表示形式变更，这张卡当作调整使用特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族·地属性怪兽不能从额外卡组特殊召唤。
-- ②：这张卡可以攻击的场合必须作出攻击。
-- ③：这张卡被选择作为攻击对象的场合发动。这张卡的表示形式变更。
function c49296203.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以自己场上1只「机巧」怪兽为对象才能发动。
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
-- 筛选满足条件的场上「机巧」怪兽（表侧表示且能改变表示形式）
function c49296203.posfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x11) and c:IsCanChangePosition()
end
-- 判断是否满足①效果的发动条件（场上有空位、有目标怪兽、此卡可特殊召唤）
function c49296203.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c49296203.posfilter(chkc) end
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己场上是否存在符合条件的「机巧」怪兽
		and Duel.IsExistingTarget(c49296203.posfilter,tp,LOCATION_MZONE,0,1,nil)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择符合条件的场上「机巧」怪兽作为目标
	local g=Duel.SelectTarget(tp,c49296203.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息：改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 设置效果处理信息：特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 处理①效果的发动后操作（改变目标怪兽表示形式并特殊召唤此卡）
function c49296203.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然在场且与效果相关，并改变其表示形式为守备表示
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0
		-- 判断此卡是否仍在场且与效果相关，并执行特殊召唤步骤
		and c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 将此卡增加调整类型
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	-- 直到回合结束时自己不是机械族·地属性怪兽不能从额外卡组特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c49296203.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制特殊召唤效果给对方玩家
	Duel.RegisterEffect(e2,tp)
end
-- 限制非机械族或非地属性的额外卡组怪兽特殊召唤
function c49296203.splimit(e,c)
	return (not c:IsAttribute(ATTRIBUTE_EARTH) or not c:IsRace(RACE_MACHINE)) and c:IsLocation(LOCATION_EXTRA)
end
-- 处理③效果：改变此卡表示形式
function c49296203.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将此卡的表示形式变为攻击表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
