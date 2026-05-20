--ベアルクティ－メガビリス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，从手卡把这张卡以外的1只7星以上的怪兽解放才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己若非持有等级的怪兽则不能特殊召唤。
-- ②：自己场上有其他的「北极天熊」怪兽存在的状态，这张卡特殊召唤成功的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
function c81108658.initial_effect(c)
	-- 注册北极天熊系列怪兽共有的手卡特殊召唤效果
	local e1=aux.AddUrsarcticSpSummonEffect(c)
	e1:SetDescription(aux.Stringid(81108658,0))
	e1:SetCountLimit(1,81108658)
	-- ②：自己场上有其他的「北极天熊」怪兽存在的状态，这张卡特殊召唤成功的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81108658,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,81108659)
	e2:SetCondition(c81108658.rmcon)
	e2:SetTarget(c81108658.rmtg)
	e2:SetOperation(c81108658.rmop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「北极天熊」怪兽
function c81108658.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x163)
end
-- 定义②号效果的发动条件函数
function c81108658.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在除自身以外的表侧表示「北极天熊」怪兽
	return Duel.IsExistingMatchingCard(c81108658.confilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 定义②号效果的靶向与目标选择函数
function c81108658.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 效果发动时的可行性检查：对方墓地是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 在系统界面提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息，表示该效果包含除外操作，操作对象为选中的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 定义②号效果的实际处理函数
function c81108658.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
