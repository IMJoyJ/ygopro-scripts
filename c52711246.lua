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
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己主要阶段才能发动。从自己墓地以及自己场上的表侧表示怪兽之中选1只怪兽除外。那之后，那种类对应的以下效果各能适用。
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
-- 过滤满足条件的怪兽：可以除外、是怪兽卡、在墓地或场上正面表示
function c52711246.filter(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 检查是否有满足条件的怪兽，用于判断效果是否可以发动
function c52711246.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的怪兽，用于判断效果是否可以发动
	if chk==0 then return Duel.IsExistingMatchingCard(c52711246.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息，提示将要除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE+LOCATION_GRAVE)
end
-- 处理效果的发动和执行过程
function c52711246.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张卡进行除外
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c52711246.filter),tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	local b1=tc:IsRace(RACE_ZOMBIE)
	local b2=tc:IsAttribute(ATTRIBUTE_FIRE)
	local b3=tc:IsType(TYPE_SYNCHRO)
	-- 将选中的卡除外
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 获取场上所有正面表示的怪兽
		local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		-- 获取场上的魔法·陷阱卡
		local g2=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		-- 获取场上的怪兽
		local g3=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 如果该卡为不死族且场上存在怪兽，则询问是否发动攻击力上升效果
		if b1 and #g1>0 and Duel.SelectYesNo(tp,aux.Stringid(52711246,1)) then  --"是否把全部怪兽的攻击力上升？"
			local t1=g1:GetFirst()
			while t1 do
				-- 给选中的怪兽增加300攻击力
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
		-- 如果该卡为炎属性且场上有魔法·陷阱卡，则询问是否发动破坏效果
		if b2 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(52711246,2)) then  --"是否把魔法·陷阱卡破坏？"
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local t2=g2:Select(tp,1,1,nil)
			-- 显示选中的卡被选为对象的动画效果
			Duel.HintSelection(t2)
			-- 破坏选中的卡
			Duel.Destroy(t2,REASON_EFFECT)
		end
		-- 如果该卡为同调类型且场上有怪兽，则询问是否发动破坏效果
		if b3 and #g3>0 and Duel.SelectYesNo(tp,aux.Stringid(52711246,3)) then  --"是否把怪兽破坏？"
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local t3=g3:Select(tp,1,1,nil)
			-- 显示选中的卡被选为对象的动画效果
			Duel.HintSelection(t3)
			-- 破坏选中的卡
			Duel.Destroy(t3,REASON_EFFECT)
		end
	end
end
