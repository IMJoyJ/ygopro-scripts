--超魔導竜騎士－ドラグーン・オブ・レッドアイズ
-- 效果：
-- 「黑魔术师」＋「真红眼黑龙」或者龙族效果怪兽
-- ①：这张卡不会被效果破坏，双方不能把这张卡作为效果的对象。
-- ②：自己主要阶段才能发动（这个效果在1回合中可以使用最多有作为这张卡的融合素材的通常怪兽数量的次数）。对方场上1只怪兽破坏，给与对方那个原本攻击力数值的伤害。
-- ③：1回合1次，卡的效果发动时，丢弃1张手卡才能发动。那个发动无效并破坏，这张卡的攻击力上升1000。
function c37818794.initial_effect(c)
	-- 添加融合召唤手续，使用卡号为46986414的怪兽和1个满足条件的怪兽为融合素材
	aux.AddFusionProcCodeFun(c,46986414,{74677422,c37818794.mfilter},1,true,true)
	c:EnableReviveLimit()
	-- ①：这张卡不会被效果破坏，双方不能把这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动（这个效果在1回合中可以使用最多有作为这张卡的融合素材的通常怪兽数量的次数）。对方场上1只怪兽破坏，给与对方那个原本攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37818794,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c37818794.descon)
	e3:SetTarget(c37818794.destg)
	e3:SetOperation(c37818794.desop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，卡的效果发动时，丢弃1张手卡才能发动。那个发动无效并破坏，这张卡的攻击力上升1000。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(37818794,1))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c37818794.discon)
	e4:SetCost(c37818794.discost)
	e4:SetTarget(c37818794.distg)
	e4:SetOperation(c37818794.disop)
	c:RegisterEffect(e4)
	-- 融合召唤成功时，记录融合素材中通常怪兽数量到FlagEffect 37818795
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c37818794.matcon)
	e5:SetOperation(c37818794.matop)
	c:RegisterEffect(e5)
	-- 融合召唤成功时，记录融合素材中通常怪兽数量到e5的Label
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_MATERIAL_CHECK)
	e6:SetValue(c37818794.valcheck)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
c37818794.material_setcode=0x3b
-- 融合检查函数，判断是否有真红眼黑龙作为融合素材
function c37818794.red_eyes_fusion_check(tp,sg,fc)
	return sg:IsExists(Card.IsFusionCode,1,nil,74677422)
end
-- 过滤函数，筛选龙族效果怪兽
function c37818794.mfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_EFFECT)
end
-- 效果发动条件，判断是否拥有可用次数
function c37818794.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffectLabel(37818795) and e:GetHandler():GetFlagEffectLabel(37818795)>0
end
-- 设置效果目标，检查是否有对方怪兽可破坏且未超过使用次数
function c37818794.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查对方场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		and c:GetFlagEffect(37818794)<c:GetFlagEffectLabel(37818795) end
	c:RegisterFlagEffect(37818794,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	-- 获取对方场上所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，指定要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，指定要给予的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果处理函数，选择并破坏对方怪兽，给予其攻击力数值的伤害
function c37818794.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		local atk=g:GetFirst():GetTextAttack()
		if atk<0 then atk=0 end
		-- 显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 破坏选中的怪兽
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			-- 给予对方该怪兽攻击力数值的伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
-- 效果发动条件，判断是否未被战斗破坏且连锁可无效
function c37818794.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该卡未被战斗破坏且连锁可无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 效果消耗函数，丢弃1张手牌作为代价
function c37818794.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 提示选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择丢弃的手牌
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手牌送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 效果目标函数，设置连锁无效和破坏操作信息
function c37818794.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定要无效的连锁
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，指定要破坏的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数，使连锁无效并破坏，提升攻击力
function c37818794.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断连锁是否成功无效且满足破坏条件
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 提升该卡攻击力1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 融合召唤成功时的条件判断，判断是否为融合召唤且有融合素材
function c37818794.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()>0
end
-- 融合召唤成功时的处理，将融合素材数量记录到FlagEffect 37818795
function c37818794.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(37818795,RESET_EVENT+RESETS_STANDARD,0,1,e:GetLabel())
end
-- 融合素材检查函数，统计融合素材中通常怪兽数量并记录到Label
function c37818794.valcheck(e,c)
	local g=c:GetMaterial()
	local ct=g:FilterCount(Card.IsFusionType,nil,TYPE_NORMAL)
	e:GetLabelObject():SetLabel(ct)
end
