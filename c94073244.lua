--空牙団の撃手 ドンパ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把「空牙团的击手 砰帕」以外的1只「空牙团」怪兽特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，自己场上有「空牙团」怪兽特殊召唤的场合，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
function c94073244.initial_effect(c)
	-- ①：自己主要阶段才能发动。从手卡把「空牙团的击手 砰帕」以外的1只「空牙团」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94073244,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,94073244)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c94073244.sptg)
	e1:SetOperation(c94073244.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，自己场上有「空牙团」怪兽特殊召唤的场合，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94073244,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,94073245)
	e2:SetCondition(c94073244.descon)
	e2:SetTarget(c94073244.destg)
	e2:SetOperation(c94073244.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手牌中除「空牙团的击手 砰帕」以外的「空牙团」怪兽
function c94073244.spfilter(c,e,tp)
	return c:IsSetCard(0x114) and not c:IsCode(94073244) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检查
function c94073244.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的「空牙团」怪兽
		and Duel.IsExistingMatchingCard(c94073244.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的执行：从手牌特殊召唤1只「空牙团」怪兽
function c94073244.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已无可用怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只满足条件的「空牙团」怪兽
	local g=Duel.SelectMatchingCard(tp,c94073244.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己场上表侧表示的「空牙团」怪兽
function c94073244.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x114) and c:IsControler(tp)
end
-- 效果②的发动条件：自己场上有「空牙团」怪兽特殊召唤（不含自身）
function c94073244.descon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c94073244.cfilter,1,nil,tp)
end
-- 效果②的发动准备：选择场上1张表侧表示的卡作为对象
function c94073244.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为对象的表侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：破坏选定的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的执行：破坏作为对象的卡
function c94073244.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将该卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
