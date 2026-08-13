--妖神－不知火
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 自己对「妖神-不知火」1回合只能有1次特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。从自己墓地以及自己场上的表侧表示怪兽之中选1只怪兽除外。那之后，那种类对应的以下效果各能适用。
-- ●不死族：自己场上的全部怪兽的攻击力上升300。
-- ●炎属性：选场上1张魔法·陷阱卡破坏。
-- ●同调：选场上1只怪兽破坏。
function c52711246.initial_effect(c)
	c:SetSPSummonOnce(52711246)
	-- 设置该卡的同调召唤手续：调整＋调整以外的怪兽1只以上（此处调整不限条件，调整以外也不限条件）；配合SetSPSummonOnce，自己对「妖神-不知火」1回合只能有1次特殊召唤。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- “①：1回合1次，自己主要阶段才能发动。从自己墓地以及自己场上的表侧表示怪兽之中选1只怪兽除外。那之后，那种类对应的以下效果各能适用。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52711246,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c52711246.target)
	e1:SetOperation(c52711246.operation)
	c:RegisterEffect(e1)
end
-- 定义除外的候选卡条件：必须是怪兽卡、可以被除外，并且位于自己墓地或是自己场上表侧表示的怪兽（即“自己墓地以及自己场上的表侧表示怪兽”）。
function c52711246.filter(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 效果发动时的目标判定和操作信息设置：检查是否有可除外的候选卡；若有，则设置本次发动将除外1只怪兽。
function c52711246.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）：在自己场上表侧表示怪兽或自己墓地中是否存在至少1只满足c52711246.filter的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c52711246.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息：本次效果为除外1只怪兽，候选范围为LOCATION_MZONE+LOCATION_GRAVE，用于后续“除外”相关的判定与连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE+LOCATION_GRAVE)
end
-- 效果处理：选择1张符合条件的怪兽除外，然后根据其种类依次询问是否适用“不死族攻击力上升”“炎属性破坏魔陷”“同调破坏怪兽”三种分支效果。
function c52711246.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要除外的卡”的选择提示，供玩家从候选范围中选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上表侧表示怪兽或自己墓地中，选出1张同时满足filter且不受王家长眠之谷影响的怪兽卡；通过NecroValleyFilter保证墓地除外不受王谷限制。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c52711246.filter),tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	local b1=tc:IsRace(RACE_ZOMBIE)
	local b2=tc:IsAttribute(ATTRIBUTE_FIRE)
	local b3=tc:IsType(TYPE_SYNCHRO)
	-- 将选中的怪兽表侧表示除外；若除外成功（返回值不为0），才继续处理后续的种族/属性/同调分支。
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 获取自己场上全部表侧表示的怪兽，作为“不死族：自己场上的全部怪兽的攻击力上升300”的效果对象。
		local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		-- 获取场上（双方）所有魔法·陷阱卡，作为“炎属性：选场上1张魔法·陷阱卡破坏”的候选对象。
		local g2=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		-- 获取场上（双方）所有怪兽，作为“同调：选场上1只怪兽破坏”的候选对象。
		local g3=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 若被除外的怪兽是不死族且自己场上有表侧表示怪兽，则询问玩家是否适用攻击力上升效果（对应原文“●不死族：自己场上的全部怪兽的攻击力上升300。”）。
		if b1 and #g1>0 and Duel.SelectYesNo(tp,aux.Stringid(52711246,1)) then  --"是否把全部怪兽的攻击力上升？"
			local t1=g1:GetFirst()
			while t1 do
				-- “●不死族：自己场上的全部怪兽的攻击力上升300。”
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(300)
				t1:RegisterEffect(e1)
				t1=g1:GetNext()
			end
		end
		-- 若被除外的怪兽是炎属性且场上有魔法·陷阱卡，则询问玩家是否适用破坏效果（对应原文“●炎属性：选场上1张魔法·陷阱卡破坏。”）。
		if b2 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(52711246,2)) then  --"是否把魔法·陷阱卡破坏？"
			-- 中断当前效果链，使之后的破坏处理与之前的除外/攻击力上升处理不在同一时点进行，避免造成错时点。
			Duel.BreakEffect()
			-- 显示“请选择要破坏的卡”的选择提示，供玩家选择要破坏的魔法·陷阱卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local t2=g2:Select(tp,1,1,nil)
			-- 为被选中的破坏对象显示“被选为对象”的动画，并记录该卡成为效果对象。
			Duel.HintSelection(t2)
			-- 将选择的那张魔法·陷阱卡以效果原因破坏。
			Duel.Destroy(t2,REASON_EFFECT)
		end
		-- 若被除外的怪兽是同调怪兽且场上有怪兽，则询问玩家是否适用破坏怪兽效果（对应原文“●同调：选场上1只怪兽破坏。”）。
		if b3 and #g3>0 and Duel.SelectYesNo(tp,aux.Stringid(52711246,3)) then  --"是否把怪兽破坏？"
			-- 中断当前效果链，使之后的破坏处理与之前的处理分支不在同一时点进行，避免造成错时点。
			Duel.BreakEffect()
			-- 显示“请选择要破坏的卡”的选择提示，供玩家选择要破坏的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local t3=g3:Select(tp,1,1,nil)
			-- 为被选中的破坏对象显示“被选为对象”的动画，并记录该卡成为效果对象。
			Duel.HintSelection(t3)
			-- 将选择的那只怪兽以效果原因破坏。
			Duel.Destroy(t3,REASON_EFFECT)
		end
	end
end
