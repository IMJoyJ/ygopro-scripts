--ブラック・アロー
-- 效果：
-- 选择自己场上表侧表示存在的1只怪兽发动。直到结束阶段时，那只怪兽的攻击力下降500，攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。选择怪兽战斗破坏怪兽送去墓地时，给与对方基本分破坏怪兽的原本守备力数值的伤害。
function c88341502.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只怪兽发动。直到结束阶段时，那只怪兽的攻击力下降500，攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。选择怪兽战斗破坏怪兽送去墓地时，给与对方基本分破坏怪兽的原本守备力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件为伤害步骤中伤害计算前以外的时机
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c88341502.target)
	e1:SetOperation(c88341502.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的对象选择与合法性检测函数
function c88341502.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在可以作为效果对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数，为选择的怪兽适用攻击力下降、贯穿以及战斗破坏给与伤害的效果
function c88341502.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 直到结束阶段时，那只怪兽的攻击力下降500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 选择怪兽战斗破坏怪兽送去墓地时，给与对方基本分破坏怪兽的原本守备力数值的伤害。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetDescription(aux.Stringid(88341502,0))  --"伤害"
		e3:SetCategory(CATEGORY_DAMAGE)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e3:SetCode(EVENT_BATTLE_DESTROYING)
		e3:SetCondition(c88341502.damcon)
		e3:SetTarget(c88341502.damtg)
		e3:SetOperation(c88341502.damop)
		e3:SetReset(RESET_PHASE+PHASE_END)
		e3:SetLabelObject(tc)
		-- 将战斗破坏怪兽时给与伤害的效果注册给发动玩家
		Duel.RegisterEffect(e3,tp)
		tc:RegisterFlagEffect(88341502,RESET_EVENT+0x1020000+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判定是否满足被选择的怪兽通过战斗破坏怪兽并送去墓地的条件
function c88341502.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local bc=tc:GetBattleTarget()
	return eg:IsContains(tc) and tc:GetFlagEffect(88341502)~=0
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
-- 战斗破坏给与伤害效果的靶向与操作信息设置函数
function c88341502.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local def=e:GetLabelObject():GetBattleTarget():GetBaseDefense()
	if def<0 then def=0 end
	-- 设置给与伤害的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置给与伤害的参数为被破坏怪兽的原本守备力
	Duel.SetTargetParam(def)
	-- 设置当前连锁的操作信息为给与对方原本守备力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,def)
end
-- 战斗破坏给与伤害效果的实际执行函数
function c88341502.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的伤害目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与目标玩家相应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
