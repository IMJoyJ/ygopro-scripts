--エッジインプ・トマホーク
-- 效果：
-- 「锋利小鬼·战斧」的①②的效果1回合各能使用1次。
-- ①：把手卡1只「锋利小鬼」怪兽送去墓地才能发动。给与对方800伤害。
-- ②：从卡组把「锋利小鬼·战斧」以外的1只「锋利小鬼」怪兽送去墓地才能发动。直到结束阶段，这张卡当作和送去墓地的怪兽同名卡使用。
function c97567736.initial_effect(c)
	-- ①：把手卡1只「锋利小鬼」怪兽送去墓地才能发动。给与对方800伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97567736,0))  --"给与对方800伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,97567736)
	e1:SetCost(c97567736.damcost)
	e1:SetTarget(c97567736.damtg)
	e1:SetOperation(c97567736.damop)
	c:RegisterEffect(e1)
	-- ②：从卡组把「锋利小鬼·战斧」以外的1只「锋利小鬼」怪兽送去墓地才能发动。直到结束阶段，这张卡当作和送去墓地的怪兽同名卡使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97567736,1))  --"复制卡名"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,97567737)
	e2:SetCost(c97567736.tgcost)
	e2:SetOperation(c97567736.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中可以送去墓地的「锋利小鬼」怪兽
function c97567736.cfilter(c)
	return c:IsSetCard(0xc3) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动代价：将手卡1只「锋利小鬼」怪兽送去墓地
function c97567736.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在满足条件的「锋利小鬼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c97567736.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手卡中满足条件的「锋利小鬼」怪兽作为发动代价
	Duel.DiscardHand(tp,c97567736.cfilter,1,1,REASON_COST)
end
-- 效果①的发动准备：设置对方玩家为伤害对象，并设置伤害数值和操作信息
function c97567736.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为800
	Duel.SetTargetParam(800)
	-- 设置当前连锁的操作信息为：给与对方玩家800点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果①的效果处理：获取目标玩家和伤害数值，并给与对方伤害
function c97567736.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 过滤条件：卡组中「锋利小鬼·战斧」以外的可以送去墓地的「锋利小鬼」怪兽
function c97567736.tgfilter(c)
	return c:IsSetCard(0xc3) and not c:IsCode(97567736) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果②的发动代价：从卡组将1只「锋利小鬼·战斧」以外的「锋利小鬼」怪兽送去墓地，并记录该怪兽的卡号
function c97567736.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的「锋利小鬼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c97567736.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的「锋利小鬼」怪兽
	local g=Duel.SelectMatchingCard(tp,c97567736.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetCode())
end
-- 效果②的效果处理：使这张卡直到结束阶段当作送去墓地的怪兽的同名卡使用，并注册结束阶段重置该效果的延迟效果
function c97567736.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 直到结束阶段，这张卡当作和送去墓地的怪兽同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(e:GetLabel())
	c:RegisterEffect(e1)
	-- 直到结束阶段，这张卡当作和送去墓地的怪兽同名卡使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97567736,2))  --"当作同名卡使用"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e2:SetLabelObject(e1)
	e2:SetOperation(c97567736.rstop)
	c:RegisterEffect(e2)
end
-- 结束阶段重置效果的处理：重置卡名变更效果，并向对方玩家提示
function c97567736.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 在场上对这张卡进行选中提示（显示选中框）
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家提示该卡的效果已适用/处理
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
