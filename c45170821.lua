--V・HERO アドレイション
-- 效果：
-- 「英雄」怪兽×2
-- ①：1回合1次，以对方场上1只表侧表示怪兽和这张卡以外的自己场上1只「英雄」怪兽为对象才能发动。那只对方怪兽的攻击力·守备力直到回合结束时下降那只自己怪兽的攻击力数值。
function c45170821.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：用2只满足「英雄」字段的怪兽作为融合素材来进行融合召唤。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x8),2,true)
	-- ①：1回合1次，以对方场上1只表侧表示怪兽和这张卡以外的自己场上1只「英雄」怪兽为对象才能发动。那只对方怪兽的攻击力·守备力直到回合结束时下降那只自己怪兽的攻击力数值。
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
-- 定义筛选自己场上「英雄」怪兽的过滤函数：该卡必须表侧表示且拥有「英雄」字段（0x8）。
function c45170821.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8)
end
-- 取对象效果的目标选择函数：在连锁询问对象合法性时直接拒绝，表示不能由其他效果任意替换对象；在发动条件判定时，确认场上存在满足条件的对方表侧怪兽和己方「英雄」怪兽。
function c45170821.valtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件判定：对方场上至少存在1只表侧表示怪兽，且该怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		-- 发动条件判定：自己场上至少存在1只除这张卡以外的表侧表示「英雄」怪兽，且该怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c45170821.sfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向操作玩家显示“请选择对方的卡”的提示消息，用于选择对方场上的表侧表示怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象，并将其登记为当前连锁的对象；g1保存所选怪兽。
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 向操作玩家显示“请选择自己的卡”的提示消息，用于选择自己场上的「英雄」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上1只满足「英雄」字段且不是这张卡本身的表侧表示怪兽作为效果对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,c45170821.sfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 效果处理：从连锁对象中分别取出对方怪兽和己方怪兽，若两者都仍表侧表示且与效果相关，则计算己方怪兽当前攻击力，将其相反数作为下降数值，使对方怪兽的攻击力与守备力直到回合结束时下降该数值。
function c45170821.valop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中本效果发动时选择的对象卡组，其中包含对方怪兽和己方怪兽两张卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local o=e:GetLabelObject()
	local s=g:GetFirst()
	if s==o then s=g:GetNext() end
	if s:IsFaceup() and o:IsFaceup() and s:IsRelateToEffect(e) and o:IsRelateToEffect(e) then
		local val=s:GetAttack()*-1
		-- 那只对方怪兽的攻击力·守备力直到回合结束时下降那只自己怪兽的攻击力数值。
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
