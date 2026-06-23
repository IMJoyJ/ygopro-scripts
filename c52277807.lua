--転生炎獣スピニー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「转生炎兽」卡存在的场合，把这张卡从手卡丢弃，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升500。
-- ②：自己场上有「转生炎兽 犰狳蜥」以外的「转生炎兽」怪兽存在的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c52277807.initial_effect(c)
	-- ①：自己场上有「转生炎兽」卡存在的场合，把这张卡从手卡丢弃，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52277807,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,52277807)
	e1:SetCondition(c52277807.atkcon)
	e1:SetCost(c52277807.atkcost)
	e1:SetTarget(c52277807.atktg)
	e1:SetOperation(c52277807.atkop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「转生炎兽 犰狳蜥」以外的「转生炎兽」怪兽存在的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52277807,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,52277808)
	e2:SetCondition(c52277807.spcon)
	e2:SetTarget(c52277807.sptg)
	e2:SetOperation(c52277807.spop)
	c:RegisterEffect(e2)
end
-- 用于判断场上是否存在表侧表示的「转生炎兽」卡
function c52277807.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x119)
end
-- 效果①的发动条件：自己场上有「转生炎兽」卡存在
function c52277807.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「转生炎兽」卡
	return Duel.IsExistingMatchingCard(c52277807.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①的发动费用：将此卡从手卡丢弃
function c52277807.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡从手卡丢入墓地作为发动费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果①的目标选择阶段：选择场上1只表侧表示怪兽
function c52277807.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果①的处理阶段：使目标怪兽攻击力上升500
function c52277807.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽的攻击力直到回合结束时上升500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 用于判断场上是否存在除自身外的表侧表示「转生炎兽」怪兽
function c52277807.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x119) and not c:IsCode(52277807)
end
-- 效果②的发动条件：自己场上有「转生炎兽 犰狳蜥」以外的「转生炎兽」怪兽存在
function c52277807.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张除自身外表侧表示的「转生炎兽」怪兽
	return Duel.IsExistingMatchingCard(c52277807.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的目标选择阶段：确认此卡可以特殊召唤
function c52277807.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果②的处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的处理阶段：将此卡从墓地特殊召唤到场上
function c52277807.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡可以被特殊召唤且成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 使此卡从场上离开时被移至除外区，不能送入墓地
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
