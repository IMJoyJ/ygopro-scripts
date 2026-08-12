--ベアルクティ－メガポーラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，从手卡把这张卡以外的1只7星以上的怪兽解放才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己若非持有等级的怪兽则不能特殊召唤。
-- ②：自己场上有其他的「北极天熊」怪兽存在的状态，这张卡特殊召唤成功的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c28715905.initial_effect(c)
	-- 注册一个可在主要阶段发动的快速特殊召唤效果
	local e1=aux.AddUrsarcticSpSummonEffect(c)
	e1:SetDescription(aux.Stringid(28715905,0))
	e1:SetCountLimit(1,28715905)
	-- 自己场上有其他的「北极天熊」怪兽存在的状态，这张卡特殊召唤成功的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28715905,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,28715906)
	e2:SetCondition(c28715905.descon)
	e2:SetTarget(c28715905.destg)
	e2:SetOperation(c28715905.desop)
	c:RegisterEffect(e2)
end
-- 判断场上是否存在其他「北极天熊」怪兽
function c28715905.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x163)
end
-- 判断是否满足效果发动条件
function c28715905.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1只其他「北极天熊」怪兽
	return Duel.IsExistingMatchingCard(c28715905.confilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 设置效果的目标选择函数
function c28715905.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张魔法·陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置效果的处理信息，确定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 设置效果的处理函数
function c28715905.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
