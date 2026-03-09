--呪眼の眷属 カトブレパス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1张「咒眼」魔法·陷阱卡为对象才能发动。直到下个回合的结束时，那张卡只有1次不会被对方的效果破坏。
-- ②：这张卡在墓地存在，自己场上有「咒眼之眷属 卡托布莱帕斯」以外的「咒眼」怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c45955628.initial_effect(c)
	-- ①：以自己场上1张「咒眼」魔法·陷阱卡为对象才能发动。直到下个回合的结束时，那张卡只有1次不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45955628,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,45955628)
	e1:SetTarget(c45955628.indtg)
	e1:SetOperation(c45955628.indop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「咒眼之眷属 卡托布莱帕斯」以外的「咒眼」怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45955628,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,45955629)
	e2:SetCondition(c45955628.spcon)
	e2:SetTarget(c45955628.sptg)
	e2:SetOperation(c45955628.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选场上正面表示的「咒眼」魔法·陷阱卡
function c45955628.tgfilter(c)
	return c:IsSetCard(0x129) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
-- 效果处理时的判断函数，用于选择场上正面表示的「咒眼」魔法·陷阱卡作为对象
function c45955628.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and c45955628.tgfilter(chkc) end
	-- 判断是否场上存在正面表示的「咒眼」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c45955628.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上正面表示的「咒眼」魔法·陷阱卡作为对象
	Duel.SelectTarget(tp,c45955628.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
end
-- 效果处理函数，为选中的魔法·陷阱卡添加不会被对方效果破坏的效果
function c45955628.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 创建一个永续效果，使对象卡在1回合内只有1次不会被对方的效果破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_NO_TURN_RESET)
		e1:SetCountLimit(1)
		e1:SetValue(c45955628.indval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end
-- 判断破坏原因是否为效果且破坏者不是该卡的持有者
function c45955628.indval(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and rp~=e:GetHandlerPlayer()
end
-- 过滤函数，用于筛选场上正面表示的「咒眼」怪兽（不包括卡托布莱帕斯自身）
function c45955628.spcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x129) and not c:IsCode(45955628)
end
-- 判断条件函数，检查自己场上是否存在「咒眼」怪兽（不包括卡托布莱帕斯）
function c45955628.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「咒眼」怪兽（不包括卡托布莱帕斯）
	return Duel.IsExistingMatchingCard(c45955628.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的处理函数，判断是否可以将此卡特殊召唤
function c45955628.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤操作信息，用于发动检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的处理函数，将此卡从墓地特殊召唤到场上
function c45955628.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否能被特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 创建一个效果，使此卡从场上离开时被移除（不进入墓地）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
