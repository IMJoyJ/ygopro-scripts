--起爆獣ヴァルカノン
-- 效果：
-- 机械族怪兽＋炎族怪兽
-- 这张卡融合召唤成功时，选择对方场上存在的1只怪兽才能发动。选择的对方怪兽和这张卡破坏送去墓地。那之后，给与对方基本分送去墓地的对方怪兽的攻击力数值的伤害。
function c10365322.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，要求使用1只机械族怪兽和1只炎族怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),aux.FilterBoolFunction(Card.IsRace,RACE_PYRO),true)
	-- 这张卡融合召唤成功时，选择对方场上存在的1只怪兽才能发动。选择的对方怪兽和这张卡破坏送去墓地。那之后，给与对方基本分送去墓地的对方怪兽的攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10365322,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c10365322.descon)
	e2:SetTarget(c10365322.destg)
	e2:SetOperation(c10365322.desop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为融合召唤成功
function c10365322.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 设置效果的发动目标选择函数
function c10365322.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查是否对方场上存在怪兽可作为效果对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 设置效果处理时将要破坏的卡组信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置效果处理时将要造成伤害的目标和伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 设置效果的发动处理函数
function c10365322.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果选择的目标卡
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end
	if not tc:IsControler(1-tp) then return end
	local dg=Group.FromCards(c,tc)
	-- 将此卡与选择的对方怪兽一起破坏，若都成功破坏则继续处理
	if Duel.Destroy(dg,REASON_EFFECT)==2 and tc:IsLocation(LOCATION_GRAVE) and c:IsLocation(LOCATION_GRAVE) then
		local d=tc:GetTextAttack()
		if d>0 then
			-- 中断当前效果处理，使后续效果视为错时点处理
			Duel.BreakEffect()
			-- 对对方玩家造成等同于被破坏怪兽攻击力的伤害
			Duel.Damage(1-tp,d,REASON_EFFECT)
		end
	end
end
