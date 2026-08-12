--V・HERO アドレイション
-- 效果：
-- 「英雄」怪兽×2
-- ①：1回合1次，以对方场上1只表侧表示怪兽和这张卡以外的自己场上1只「英雄」怪兽为对象才能发动。那只对方怪兽的攻击力·守备力直到回合结束时下降那只自己怪兽的攻击力数值。
function c45170821.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个满足「融合怪兽的种族为英雄」条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x8),2,true)
	-- ①：1回合1次，以对方场上1只表侧表示怪兽和这张卡以外的自己场上1只「英雄」怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45170821,0))  --"攻守下降"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c45170821.valtg)
	e2:SetOperation(c45170821.valop)
	c:RegisterEffect(e2)
end
c45170821.material_setcode=0x8
-- 筛选自己场上表侧表示的「英雄」怪兽
function c45170821.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8)
end
-- 设置效果的发动条件，判断是否满足选择对象的条件
function c45170821.valtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断对方场上是否存在1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		-- 判断自己场上是否存在1只「英雄」怪兽
		and Duel.IsExistingTarget(c45170821.sfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家提示选择对方怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 向玩家提示选择己方怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上1只「英雄」怪兽作为效果对象
	Duel.SelectTarget(tp,c45170821.sfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 效果处理函数，使对方怪兽的攻守下降
function c45170821.valop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local o=e:GetLabelObject()
	local s=g:GetFirst()
	if s==o then s=g:GetNext() end
	if s:IsFaceup() and o:IsFaceup() and s:IsRelateToEffect(e) and o:IsRelateToEffect(e) then
		local val=s:GetAttack()*-1
		-- 将对方怪兽的攻击力下降自己场上怪兽的攻击力数值
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(val)
		o:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		o:RegisterEffect(e2)
	end
end
