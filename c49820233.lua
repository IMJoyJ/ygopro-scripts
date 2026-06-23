--EMガトリングール
-- 效果：
-- 「娱乐伙伴」怪兽＋5星以上的暗属性怪兽
-- 「娱乐伙伴 机炮食尸鬼」的效果1回合只能使用1次。
-- ①：这张卡融合召唤成功的场合才能发动。给与对方为场上的卡数量×200伤害。这张卡用灵摆怪兽为素材作融合召唤的场合，再选对方场上1只怪兽破坏，给与对方那只怪兽的原本攻击力数值的伤害。
function c49820233.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足「娱乐伙伴」系列且为暗属性5星以上的怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x9f),aux.FilterBoolFunction(c49820233.ffilter),true)
	-- ①：这张卡融合召唤成功的场合才能发动。给与对方为场上的卡数量×200伤害。这张卡用灵摆怪兽为素材作融合召唤的场合，再选对方场上1只怪兽破坏，给与对方那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49820233,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,49820233)
	e1:SetCondition(c49820233.damcon)
	e1:SetTarget(c49820233.damtg)
	e1:SetOperation(c49820233.damop)
	c:RegisterEffect(e1)
	-- ①：这张卡融合召唤成功的场合才能发动。给与对方为场上的卡数量×200伤害。这张卡用灵摆怪兽为素材作融合召唤的场合，再选对方场上1只怪兽破坏，给与对方那只怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c49820233.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 过滤满足暗属性且等级不低于5的怪兽
function c49820233.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(5)
end
-- 判断此卡是否为融合召唤成功
function c49820233.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 设置连锁处理信息，确定伤害值并判断是否需要破坏对方怪兽
function c49820233.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测场上是否有卡存在以发动效果
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)>0 end
	-- 获取场上卡的数量用于计算伤害
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 设定连锁影响的玩家为目标玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息为对目标玩家造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
	if e:GetLabel()==1 then
		-- 获取对方场上的怪兽组用于破坏效果
		local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
		-- 设置连锁操作信息为破坏对方场上一只怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 处理效果发动后的操作，包括造成伤害和可能的破坏与二次伤害
function c49820233.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取场上卡的数量用于计算伤害
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 判断是否可以发动伤害效果并执行
	if ct>0 and Duel.Damage(p,ct*200,REASON_EFFECT)>0 then
		if e:GetLabel()==1 then
			-- 提示选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 从对方场上选择一只怪兽作为破坏对象
			local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
			if g:GetCount()>0 then
				-- 中断当前效果处理，使后续效果视为错时处理
				Duel.BreakEffect()
				-- 显示被选为对象的动画效果
				Duel.HintSelection(g)
				-- 判断破坏是否成功并执行后续伤害
				if Duel.Destroy(g,REASON_EFFECT)~=0 then
					local dam=g:GetFirst():GetBaseAttack()
					-- 对目标玩家造成等同于被破坏怪兽攻击力的伤害
					Duel.Damage(p,dam,REASON_EFFECT)
				end
			end
		end
	end
end
-- 检查融合素材中是否有灵摆怪兽，若有则标记效果触发
function c49820233.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsFusionType,1,nil,TYPE_PENDULUM) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
