--ベアルクティ－メガタナス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，从手卡把这张卡以外的1只7星以上的怪兽解放才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己若非持有等级的怪兽则不能特殊召唤。
-- ②：自己场上有其他的「北极天熊」怪兽存在的状态，这张卡特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
function c54700519.initial_effect(c)
	-- 注册「北极天熊」怪兽共有的手卡特殊召唤效果（效果①）。
	local e1=aux.AddUrsarcticSpSummonEffect(c)
	e1:SetDescription(aux.Stringid(54700519,0))
	e1:SetCountLimit(1,54700519)
	-- ②：自己场上有其他的「北极天熊」怪兽存在的状态，这张卡特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54700519,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,54700520)
	e2:SetCondition(c54700519.poscon)
	e2:SetTarget(c54700519.postg)
	e2:SetOperation(c54700519.posop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「北极天熊」怪兽。
function c54700519.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x163)
end
-- 效果②的发动条件：自己场上存在除自身以外的其他「北极天熊」怪兽。
function c54700519.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在除这张卡以外的表侧表示「北极天熊」怪兽。
	return Duel.IsExistingMatchingCard(c54700519.confilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤条件：对方场上表侧表示且可以变成里侧表示的怪兽。
function c54700519.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果②的发动准备与目标选择（选择对方场上1只表侧表示怪兽为对象）。
function c54700519.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c54700519.posfilter(chkc) end
	-- 检查对方场上是否存在至少1只满足条件的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c54700519.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上1只表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c54700519.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该效果包含改变表示形式的操作。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果②的效果处理（将作为对象的怪兽变成里侧守备表示）。
function c54700519.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时作为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽变成里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
