--スカーレッド・ノヴァ・ドラゴン
-- 效果：
-- 调整2只＋「红莲魔龙」
-- ①：这张卡的攻击力上升自己墓地的调整数量×500。
-- ②：场上的这张卡不会被对方的效果破坏。
-- ③：对方怪兽的攻击宣言时，以那1只攻击怪兽为对象才能发动。场上的这张卡除外，那次攻击无效。
-- ④：这张卡的③的效果除外的回合的结束阶段发动。这张卡特殊召唤。
function c97489701.initial_effect(c)
	-- 在素材代码列表中添加「红莲魔龙」的卡片密码
	aux.AddMaterialCodeList(c,70902743)
	-- 添加同调召唤手续：调整2只 + 「红莲魔龙」1只
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),aux.Tuner(nil),nil,aux.FilterBoolFunction(Card.IsCode,70902743),1,1)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升自己墓地的调整数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c97489701.atkval)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(c97489701.indval)
	c:RegisterEffect(e3)
	-- ③：对方怪兽的攻击宣言时，以那1只攻击怪兽为对象才能发动。场上的这张卡除外，那次攻击无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(97489701,0))  --"攻击无效"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c97489701.nacon)
	e4:SetTarget(c97489701.natg)
	e4:SetOperation(c97489701.naop)
	c:RegisterEffect(e4)
	-- ④：这张卡的③的效果除外的回合的结束阶段发动。这张卡特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(97489701,1))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_REMOVED)
	e5:SetCountLimit(1)
	e5:SetCondition(c97489701.spcon)
	e5:SetTarget(c97489701.sptg)
	e5:SetOperation(c97489701.spop)
	c:RegisterEffect(e5)
	-- 调整2只＋「红莲魔龙」
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetCode(21142671)
	c:RegisterEffect(e6)
end
c97489701.material_type=TYPE_SYNCHRO
-- 计算攻击力上升数值的辅助函数
function c97489701.atkval(e,c)
	-- 获取自己墓地中调整怪兽的数量并乘以500
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_TUNER)*500
end
-- 判断是否为对方卡片效果的辅助函数
function c97489701.indval(e,re,tp)
	return e:GetHandler():GetControler()~=tp
end
-- 攻击无效效果的发动条件检查函数
function c97489701.nacon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前进行攻击宣言的怪兽是否由对方控制
	return Duel.GetAttacker():GetControler()~=tp
end
-- 攻击无效效果的对象选择与可行性检查函数
function c97489701.natg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 在效果处理前，确认指向的对象是否仍为当前的攻击怪兽
	if chkc then return chkc==Duel.GetAttacker() end
	-- 在发动阶段，检查自身是否可以除外以及攻击怪兽是否可以作为效果对象
	if chk==0 then return e:GetHandler():IsAbleToRemove() and Duel.GetAttacker():IsCanBeEffectTarget(e)
		and not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 将当前的攻击怪兽设为效果的目标对象
	Duel.SetTargetCard(Duel.GetAttacker())
	-- 设置操作信息：将自身除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 攻击无效效果的执行函数
function c97489701.naop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前的攻击
	Duel.NegateAttack()
	local c=e:GetHandler()
	-- 若自身仍存在于场上，则将其表侧表示除外，并注册回合结束时特召的标志
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
		c:RegisterFlagEffect(97489701,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 特殊召唤效果的发动条件检查函数：检查自身是否带有因自身效果除外的标记
function c97489701.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(97489701)~=0
end
-- 特殊召唤效果的可行性检查与操作信息设置函数
function c97489701.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行函数
function c97489701.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到自己的场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
