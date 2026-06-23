--ペンギン勇士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，把这张卡作为同调素材的场合，不是水属性怪兽的同调召唤不能使用。
-- ①：自己场上有怪兽被盖放的场合才能发动。这张卡从手卡特殊召唤。那之后，可以让这张卡的等级下降1星或者2星。
-- ②：以自己场上1只里侧守备表示怪兽为对象才能发动。那只怪兽变成表侧守备表示。这个效果把「企鹅」怪兽以外的怪兽变成表侧守备表示的场合，那个效果无效化。
function c14761450.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次，把这张卡作为同调素材的场合，不是水属性怪兽的同调召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c14761450.synlimit)
	c:RegisterEffect(e1)
	-- 自己场上有怪兽被盖放的场合才能发动。这张卡从手卡特殊召唤。那之后，可以让这张卡的等级下降1星或者2星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14761450,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_MSET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,14761450)
	e2:SetCondition(c14761450.spcon1)
	e2:SetTarget(c14761450.sptg)
	e2:SetOperation(c14761450.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetCondition(c14761450.spcon2)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c14761450.spcon2)
	c:RegisterEffect(e4)
	-- 以自己场上1只里侧守备表示怪兽为对象才能发动。那只怪兽变成表侧守备表示。这个效果把「企鹅」怪兽以外的怪兽变成表侧守备表示的场合，那个效果无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(14761450,1))
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1,14761451)
	e5:SetTarget(c14761450.postg)
	e5:SetOperation(c14761450.posop)
	c:RegisterEffect(e5)
end
-- 设置该效果为不能作为同调素材的条件，当目标怪兽不是水属性时返回true
function c14761450.synlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 判断是否满足效果发动条件：场上有自己控制的怪兽被设置
function c14761450.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp)
end
-- 用于筛选目标怪兽是否为里侧守备表示且为己方控制
function c14761450.cfilter(c,tp)
	return c:IsFacedown() and c:IsControler(tp)
end
-- 判断是否满足效果发动条件：场上有自己控制的怪兽被设置或特殊召唤成功
function c14761450.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c14761450.cfilter,1,nil,tp)
end
-- 设置特殊召唤效果的目标判定函数
function c14761450.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的条件：场上存在空位且该卡可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的操作信息，告知对方将要特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 设置特殊召唤效果的处理函数
function c14761450.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否满足特殊召唤处理条件：该卡在场且能特殊召唤，并且等级大于等于2
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsLevelAbove(2) then
		local off=1
		local ops,opval={},{}
		ops[off]=aux.Stringid(14761450,2)  --"等级下降1星"
		opval[off]=-1
		off=off+1
		if c:IsLevelAbove(3) then
			ops[off]=aux.Stringid(14761450,3)  --"等级下降2星"
			opval[off]=-2
			off=off+1
		end
		ops[off]=aux.Stringid(14761450,4)  --"什么都不做"
		opval[off]=0
		-- 选择等级下降选项
		local op=Duel.SelectOption(tp,table.unpack(ops))+1
		local sel=opval[op]
		if sel==0 then return end
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 设置等级下降效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(sel)
		c:RegisterEffect(e1)
	end
end
-- 用于筛选目标怪兽是否为里侧守备表示
function c14761450.filter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsCanChangePosition()
end
-- 设置位置变更效果的目标判定函数
function c14761450.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14761450.filter(chkc) end
	-- 检查是否满足位置变更的条件：己方场上存在里侧守备表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c14761450.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c14761450.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置位置变更效果的操作信息，告知对方将要改变目标怪兽位置
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 设置位置变更效果的处理函数
function c14761450.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsPosition(POS_FACEUP_DEFENSE) then
		-- 将目标怪兽变为表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		if tc:IsPosition(POS_FACEUP_DEFENSE) and not tc:IsSetCard(0x5a) then
			local c=e:GetHandler()
			-- 若目标怪兽不是企鹅族，则使其效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- 若目标怪兽不是企鹅族，则使其效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
	end
end
