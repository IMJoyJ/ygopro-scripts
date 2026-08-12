--大砂海ゴールド・ゴルゴンダ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：场上的「护宝炮妖」超量怪兽的攻击力上升1000。
-- ②：自己场上没有「护宝炮妖」超量怪兽存在的场合，从手卡丢弃1张「护宝炮妖」卡才能发动。从额外卡组把1只「护宝炮妖」超量怪兽特殊召唤。
-- ③：自己场上的表侧表示的超量怪兽因效果从场上离开的场合，以对方场上1只怪兽为对象才能发动。这个回合，那只怪兽不能攻击。
function c60884672.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：场上的「护宝炮妖」超量怪兽的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c60884672.atktg)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	-- ②：自己场上没有「护宝炮妖」超量怪兽存在的场合，从手卡丢弃1张「护宝炮妖」卡才能发动。从额外卡组把1只「护宝炮妖」超量怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60884672,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,60884672)
	e2:SetCondition(c60884672.spcon)
	e2:SetCost(c60884672.spcost)
	e2:SetTarget(c60884672.sptg)
	e2:SetOperation(c60884672.spop)
	c:RegisterEffect(e2)
	-- ③：自己场上的表侧表示的超量怪兽因效果从场上离开的场合，以对方场上1只怪兽为对象才能发动。这个回合，那只怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(60884672,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,60884673)
	e3:SetCondition(c60884672.catkcon)
	e3:SetTarget(c60884672.catktg)
	e3:SetOperation(c60884672.catkop)
	c:RegisterEffect(e3)
end
-- 过滤场上「护宝炮妖」超量怪兽作为攻击力上升的对象
function c60884672.atktg(e,c)
	return c:IsSetCard(0x155) and c:IsType(TYPE_XYZ)
end
-- 过滤自己场上表侧表示的「护宝炮妖」超量怪兽
function c60884672.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x155) and c:IsType(TYPE_XYZ)
end
-- 定义效果②的发动条件函数
function c60884672.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在表侧表示的「护宝炮妖」超量怪兽
	return not Duel.IsExistingMatchingCard(c60884672.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤手卡中可以丢弃的「护宝炮妖」卡片
function c60884672.costfilter(c)
	return c:IsSetCard(0x155) and c:IsDiscardable()
end
-- 定义效果②的发动代价函数
function c60884672.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可作为代价丢弃的「护宝炮妖」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c60884672.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡丢弃1张「护宝炮妖」卡片作为发动代价
	Duel.DiscardHand(tp,c60884672.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 过滤额外卡组中可以特殊召唤的「护宝炮妖」超量怪兽
function c60884672.spfilter(c,e,tp)
	-- 检查卡片是否为「护宝炮妖」超量怪兽、能否特殊召唤，以及额外怪兽区域是否有空位
	return c:IsSetCard(0x155) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 定义效果②的发动准备函数
function c60884672.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可特殊召唤的「护宝炮妖」超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c60884672.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，准备从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义效果②的效果处理函数
function c60884672.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足特殊召唤条件的「护宝炮妖」超量怪兽
	local g=Duel.SelectMatchingCard(tp,c60884672.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤因效果从自己场上离开的表侧表示超量怪兽
function c60884672.catkfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousTypeOnField()&TYPE_XYZ~=0 and c:IsReason(REASON_EFFECT)
end
-- 定义效果③的发动条件函数
function c60884672.catkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c60884672.catkfilter,1,nil,tp)
end
-- 定义效果③的发动准备函数
function c60884672.catktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 定义效果③的效果处理函数
function c60884672.catkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
