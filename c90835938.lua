--聖夜に煌めく竜
-- 效果：
-- ①：这张卡从手卡的召唤·特殊召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：场上的这张卡不会被和暗属性怪兽的战斗破坏，不会被暗属性怪兽的效果破坏。
-- ③：1回合1次，这张卡向对方怪兽攻击的伤害步骤开始时才能发动。那只对方怪兽直到结束阶段除外。这个效果发动的场合，这张卡只再1次可以继续攻击。
function c90835938.initial_effect(c)
	-- ①：这张卡从手卡的召唤·特殊召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90835938,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(c90835938.descon)
	e1:SetTarget(c90835938.destg)
	e1:SetOperation(c90835938.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡不会被和暗属性怪兽的战斗破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c90835938.indes)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(c90835938.efilter)
	c:RegisterEffect(e4)
	-- ③：1回合1次，这张卡向对方怪兽攻击的伤害步骤开始时才能发动。那只对方怪兽直到结束阶段除外。这个效果发动的场合，这张卡只再1次可以继续攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(90835938,1))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_START)
	e5:SetCountLimit(1)
	e5:SetCondition(c90835938.rmcon)
	e5:SetTarget(c90835938.rmtg)
	e5:SetOperation(c90835938.rmop)
	c:RegisterEffect(e5)
end
-- 判定这张卡是否是从手卡召唤·特殊召唤成功
function c90835938.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 破坏效果的对象选择与发动准备
function c90835938.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以作为破坏对象的目标卡片
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行处理
function c90835938.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判定与之进行战斗的怪兽是否为暗属性
function c90835938.indes(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
-- 判定对其发动效果的怪兽是否为暗属性（包含对场上及非场上怪兽属性的判定）
function c90835938.efilter(e,re)
	if not re:IsActiveType(TYPE_MONSTER) then return false end
	local rc=re:GetHandler()
	if (re:IsActivated() and rc:IsRelateToEffect(re) or not re:IsHasProperty(EFFECT_FLAG_FIELD_ONLY))
		and (rc:IsFaceup() or not rc:IsLocation(LOCATION_MZONE)) then
		return rc:IsAttribute(ATTRIBUTE_DARK)
	else
		return rc:GetOriginalAttribute()&ATTRIBUTE_DARK~=0
	end
end
-- 判定是否为自身向对方怪兽发动攻击的伤害步骤开始时
function c90835938.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	-- 验证攻击怪兽为自身，且存在对方控制的被攻击怪兽
	return Duel.GetAttacker()==c and bc and bc:IsControler(1-tp)
end
-- 除外效果的发动准备，确认被攻击怪兽是否可以除外
function c90835938.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc and bc:IsRelateToBattle() and bc:IsAbleToRemove() end
	-- 设置效果处理信息为除外该对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
-- 除外效果的执行处理，并在结束阶段将怪兽归还，同时允许追加一次攻击
function c90835938.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=e:GetLabelObject()
	-- 确认被攻击怪兽仍处于战斗状态且由对方控制，并将其暂时除外
	if bc and bc:IsRelateToBattle() and bc:IsControler(1-tp) and Duel.Remove(bc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 那只对方怪兽直到结束阶段除外。这个效果发动的场合，这张卡只再1次可以继续攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(bc)
		e1:SetCountLimit(1)
		e1:SetOperation(c90835938.retop)
		-- 注册在回合结束阶段将除外怪兽归还场上的延迟效果
		Duel.RegisterEffect(e1,tp)
	end
	if c:IsRelateToEffect(e) and c:IsChainAttackable() then
		-- 使这张卡可以再进行1次攻击
		Duel.ChainAttack()
	end
end
-- 结束阶段将暂时除外的怪兽归还场上的效果处理
function c90835938.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂时除外的怪兽以原本的表示形式返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
