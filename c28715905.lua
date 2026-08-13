--ベアルクティ－メガポーラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，从手卡把这张卡以外的1只7星以上的怪兽解放才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己若非持有等级的怪兽则不能特殊召唤。
-- ②：自己场上有其他的「北极天熊」怪兽存在的状态，这张卡特殊召唤成功的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c28715905.initial_effect(c)
	-- 调用通用函数为北极天熊怪兽注册①效果（双方主要阶段解放手牌7星以上怪兽进行特殊召唤的效果），并返回效果对象e1。
	local e1=aux.AddUrsarcticSpSummonEffect(c)
	e1:SetDescription(aux.Stringid(28715905,0))
	e1:SetCountLimit(1,28715905)
	-- ②：自己场上有其他的「北极天熊」怪兽存在的状态，这张卡特殊召唤成功的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
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
-- 定义过滤器：判断怪兽是否表侧表示且属于「北极天熊」系列（0x163），用于检查自己场上是否存在其他北极天熊怪兽。
function c28715905.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x163)
end
-- 定义②效果的发动条件：自己场上存在其他表侧表示且属于「北极天熊」系列的怪兽（不包含这张卡自身）。
function c28715905.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（LOCATION_MZONE）是否存在至少1张满足confilter条件的表侧表示「北极天熊」怪兽，且该怪兽不是效果持有者本身。
	return Duel.IsExistingMatchingCard(c28715905.confilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 定义②效果发动时的目标选择与操作信息设置：取对象为对方场上的1张魔法·陷阱卡，并标记为破坏效果。
function c28715905.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 效果发动时确认能否选择对象：检查对方场上是否存在至少1张魔法·陷阱卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 向玩家显示选择提示“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张魔法·陷阱卡作为效果对象，并自动将所选卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置操作信息：本次连锁将破坏1张卡，目标为已选择的g，为其他卡/效果响应破坏提供依据。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义②效果处理时的操作：取回之前选择的对象卡，若该卡仍与效果相关则将其破坏。
function c28715905.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中②效果选择的对象卡（对方场上的魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
