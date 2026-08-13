--EMガトリングール
-- 效果：
-- 「娱乐伙伴」怪兽＋5星以上的暗属性怪兽
-- 「娱乐伙伴 机炮食尸鬼」的效果1回合只能使用1次。
-- ①：这张卡融合召唤成功的场合才能发动。给与对方为场上的卡数量×200伤害。这张卡用灵摆怪兽为素材作融合召唤的场合，再选对方场上1只怪兽破坏，给与对方那只怪兽的原本攻击力数值的伤害。
function c49820233.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加融合召唤手续：可以以1只「娱乐伙伴」怪兽和1只满足ffilter（5星以上暗属性）的怪兽作为融合素材进行融合召唤。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x9f),aux.FilterBoolFunction(c49820233.ffilter),true)
	-- 「娱乐伙伴 机炮食尸鬼」的效果1回合只能使用1次。①：这张卡融合召唤成功的场合才能发动。给与对方为场上的卡数量×200伤害。这张卡用灵摆怪兽为素材作融合召唤的场合，再选对方场上1只怪兽破坏，给与对方那只怪兽的原本攻击力数值的伤害。
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
	-- 这张卡用灵摆怪兽为素材作融合召唤的场合。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c49820233.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 该过滤函数用于筛选融合素材：怪兽必须是暗属性且等级在5星以上（对应效果中的「5星以上的暗属性怪兽」）。
function c49820233.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(5)
end
-- 效果发动条件：这张卡融合召唤成功时才能发动（e:GetHandler()为这张卡，检测其召唤方式为融合召唤）。
function c49820233.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果发动时的目标处理和伤害/破坏信息设定：若场上存在卡则效果可发动；计算场上卡数量作为伤害值，将对方玩家设为伤害对象；若融合素材含有灵摆怪兽，则额外将对方场上1只怪兽设为破坏候选。
function c49820233.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：场上必须存在至少1张卡（因为伤害为场上卡数×200，场上无卡时伤害为0）。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)>0 end
	-- 获取场上所有卡的数量，用于计算给对方造成的伤害。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 将当前连锁的伤害对象玩家设为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置操作信息：该效果包含伤害效果，伤害值为ct×200，伤害对象为对方玩家。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
	if e:GetLabel()==1 then
		-- 获取对方场上的全部怪兽（LOCATION_MZONE）作为可能被破坏的候选集合。
		local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
		-- 设置操作信息：该效果包含破坏效果，破坏对象为对方场上的怪兽集合，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理：先给对方造成场上卡数×200的伤害；若伤害成功且使用了灵摆素材，则选对方场上1只怪兽破坏，成功破坏后再给与对方那只怪兽原本攻击力数值的伤害。
function c49820233.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象玩家，即承受伤害的玩家（对方）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新获取场上卡的数量，用于计算伤害。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 如果场上有卡且伤害成功造成（伤害值>0），则继续执行灵摆素材时的追加处理。
	if ct>0 and Duel.Damage(p,ct*200,REASON_EFFECT)>0 then
		if e:GetLabel()==1 then
			-- 显示选择提示信息，提示玩家选择要破坏的卡（HINTMSG_DESTROY）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择对方场上的1只怪兽作为破坏对象。
			local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
			if g:GetCount()>0 then
				-- 中断当前效果处理，使后续破坏与伤害处理视为不同时处理，避免错过时点。
				Duel.BreakEffect()
				-- 为选中的怪兽显示被选为对象的动画，并记录其为对象。
				Duel.HintSelection(g)
				-- 将选择的怪兽破坏；若破坏成功，则继续给与对方该怪兽原本攻击力数值的伤害。
				if Duel.Destroy(g,REASON_EFFECT)~=0 then
					local dam=g:GetFirst():GetBaseAttack()
					-- 给与对方玩家该怪兽原本攻击力数值的伤害。
					Duel.Damage(p,dam,REASON_EFFECT)
				end
			end
		end
	end
end
-- 素材检查函数：融合召唤成功时，检查实际使用的融合素材中是否存在灵摆怪兽；若存在则把e1的标签设为1（表示本次融合使用了灵摆素材），否则设为0。
function c49820233.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsFusionType,1,nil,TYPE_PENDULUM) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
