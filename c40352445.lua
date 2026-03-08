--凶導の白騎士
-- 效果：
-- 「凶导的福音」降临
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
-- ②：对方把魔法·陷阱·怪兽的效果发动的场合才能发动。从自己的额外卡组把1只怪兽送去墓地，把对方的额外卡组确认，把那之内的1只怪兽送去墓地。这张卡的攻击力直到回合结束时上升送去墓地的怪兽的攻击力合计数值的一半。
function c40352445.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c40352445.splimit)
	c:RegisterEffect(e1)
	-- ②：对方把魔法·陷阱·怪兽的效果发动的场合才能发动。从自己的额外卡组把1只怪兽送去墓地，把对方的额外卡组确认，把那之内的1只怪兽送去墓地。这张卡的攻击力直到回合结束时上升送去墓地的怪兽的攻击力合计数值的一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40352445,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,40352445)
	e2:SetCondition(c40352445.tgcon)
	e2:SetTarget(c40352445.tgtg)
	e2:SetOperation(c40352445.tgop)
	c:RegisterEffect(e2)
end
-- 效果作用：限制自己从额外卡组特殊召唤怪兽
function c40352445.splimit(e,c,tp,sumtp,sumpos)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 效果作用：判断是否为对方发动效果
function c40352445.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
-- 效果作用：设置发动条件，检查双方额外卡组是否有可送去墓地的怪兽
function c40352445.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查自己额外卡组是否有可送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,nil)
		-- 效果作用：检查对方额外卡组是否有可送去墓地的怪兽
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,1,nil) end
	-- 效果作用：设置连锁操作信息，确定要处理的卡为双方额外卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,PLAYER_ALL,LOCATION_EXTRA)
end
-- 效果作用：执行效果处理流程，包括选择并送去墓地怪兽、确认对方额外卡组、计算攻击力提升值
function c40352445.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 效果作用：从自己额外卡组选择1只怪兽送去墓地
	local tc1=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	-- 效果作用：确认第一只怪兽成功送去墓地后继续处理后续流程
	if tc1 and Duel.SendtoGrave(tc1,REASON_EFFECT)>0 and tc1:IsLocation(LOCATION_GRAVE) then
		local atk=tc1:GetAttack()
		-- 效果作用：获取对方额外卡组的所有怪兽
		local rg=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
		if #rg>0 then
			-- 效果作用：确认对方额外卡组的怪兽
			Duel.ConfirmCards(tp,rg,true)
			-- 效果作用：提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local tc2=rg:FilterSelect(tp,Card.IsAbleToGrave,1,1,nil):GetFirst()
			-- 效果作用：洗切对方额外卡组
			Duel.ShuffleExtra(1-tp)
			-- 效果作用：确认第二只怪兽成功送去墓地后更新攻击力总和
			if tc2 and Duel.SendtoGrave(tc2,REASON_EFFECT)>0 and tc2:IsLocation(LOCATION_GRAVE) then
				atk=atk+tc2:GetAttack()
			end
		end
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 效果作用：使自身攻击力上升送去墓地的怪兽攻击力合计的一半
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(math.floor(atk/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
