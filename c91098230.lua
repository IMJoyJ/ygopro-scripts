--古代の機械戦車兵
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从手卡把「古代的机械战车兵」以外的1只「古代的机械」怪兽无视召唤条件特殊召唤。对方场上有怪兽存在的场合，也能作为代替从自己墓地选。
-- ②：以自己场上1张表侧表示卡为对象才能发动。那张卡破坏。这个回合中自己场上的「古代的机械巨人」以及有那个卡名记述的怪兽的攻击力上升600。
function c91098230.initial_effect(c)
	-- 将「古代的机械巨人」的卡片密码注册到当前卡片的关联卡片列表中
	aux.AddCodeList(c,83104731)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从手卡把「古代的机械战车兵」以外的1只「古代的机械」怪兽无视召唤条件特殊召唤。对方场上有怪兽存在的场合，也能作为代替从自己墓地选。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91098230,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,91098230)
	e1:SetTarget(c91098230.sptg)
	e1:SetOperation(c91098230.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以自己场上1张表侧表示卡为对象才能发动。那张卡破坏。这个回合中自己场上的「古代的机械巨人」以及有那个卡名记述的怪兽的攻击力上升600。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91098230,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,91098231)
	e3:SetTarget(c91098230.destg)
	e3:SetOperation(c91098230.desop)
	c:RegisterEffect(e3)
end
-- 过滤手卡或墓地中「古代的机械战车兵」以外的、可以无视召唤条件特殊召唤的「古代的机械」怪兽
function c91098230.filter1(c,e,tp)
	return not c:IsCode(91098230) and c:IsSetCard(0x7) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 判断卡片是否在手卡，或者在对方场上有怪兽存在时的墓地
		and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_GRAVE) and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil))
end
-- ①效果的发动条件与效果处理的检测（Target函数）
function c91098230.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检测自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动效果时，检测手卡或墓地是否存在满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c91098230.filter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示此效果包含从手卡或墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果的实际处理（Operation函数）
function c91098230.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，若自己场上没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足条件的怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c91098230.filter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽无视召唤条件以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- ②效果的发动条件与对象选择（Target函数）
function c91098230.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 在发动效果时，检测自己场上是否存在表侧表示的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己场上1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置连锁的操作信息，表示此效果包含破坏所选卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的实际处理（Operation函数）
function c91098230.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
	-- 这个回合中自己场上的「古代的机械巨人」以及有那个卡名记述的怪兽的攻击力上升600。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c91098230.atktg)
	e1:SetValue(600)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境注册该攻击力上升的阶段性效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤攻击力上升效果所适用的怪兽
function c91098230.atktg(e,c)
	-- 判断怪兽是否为「古代的机械巨人」或其效果文本中记载有「古代的机械巨人」卡名的怪兽
	return c:IsCode(83104731) or aux.IsCodeListed(c,83104731)
end
