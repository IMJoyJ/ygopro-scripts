--凶導の白騎士
-- 效果：
-- 「凶导的福音」降临
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
-- ②：对方把魔法·陷阱·怪兽的效果发动的场合才能发动。从自己的额外卡组把1只怪兽送去墓地，把对方的额外卡组确认，把那之内的1只怪兽送去墓地。这张卡的攻击力直到回合结束时上升送去墓地的怪兽的攻击力合计数值的一半。
function c40352445.initial_effect(c)
	-- 注册卡片密码31002402（凶导的福音）到本卡的关系卡片列表中
	aux.AddCodeList(c,31002402)
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
-- 特殊召唤限制的过滤函数，限制特殊召唤的范围为额外卡组
function c40352445.splimit(e,c,tp,sumtp,sumpos)
	return c:IsLocation(LOCATION_EXTRA)
end
-- ②号效果的发动条件判定函数，检查是否为对方发动的效果连锁
function c40352445.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
-- ②号效果的发动靶指向（Target）函数，检查双方额外卡组是否有可送去墓地的怪兽，并设定连锁操作信息
function c40352445.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的额外卡组中是否存在能够送去墓地的怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,nil)
		-- 检查对方的额外卡组中是否存在能够送去墓地的怪兽卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,1,nil) end
	-- 设置当前连锁的操作信息，将双方额外卡组中的各1张怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,PLAYER_ALL,LOCATION_EXTRA)
end
-- ②号效果的执行逻辑（Operation）函数，从双方额外卡组各将1只怪兽送去墓地并上升本卡攻击力
function c40352445.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向我方玩家提示信息：“请选择要送去墓地的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让我方玩家从自己的额外卡组中选择1只可以送去墓地的怪兽
	local tc1=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	-- 判断我方的额外怪兽是否成功被效果送入墓地
	if tc1 and Duel.SendtoGrave(tc1,REASON_EFFECT)>0 and tc1:IsLocation(LOCATION_GRAVE) then
		local atk=tc1:GetAttack()
		-- 获取对方额外卡组的卡片集合
		local rg=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
		if #rg>0 then
			-- 让我方玩家确认对方额外卡组的所有卡片
			Duel.ConfirmCards(tp,rg,true)
			-- 向我方玩家提示信息：“请选择要送去墓地的卡”
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local tc2=rg:FilterSelect(tp,Card.IsAbleToGrave,1,1,nil):GetFirst()
			-- 洗切对方的额外卡组
			Duel.ShuffleExtra(1-tp)
			-- 判断对方的额外怪兽是否成功被效果送入墓地
			if tc2 and Duel.SendtoGrave(tc2,REASON_EFFECT)>0 and tc2:IsLocation(LOCATION_GRAVE) then
				atk=atk+tc2:GetAttack()
			end
		end
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 这张卡的攻击力直到回合结束时上升送去墓地的怪兽的攻击力合计数值的一半。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(math.floor(atk/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
