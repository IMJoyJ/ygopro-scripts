--月光黒羊
-- 效果：
-- ①：可以把这张卡从手卡丢弃，从以下效果选择1个发动。
-- ●从自己墓地把「月光黑羊」以外的1只「月光」怪兽加入手卡。
-- ●从卡组把1张「融合」加入手卡。
-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从自己的额外卡组（表侧）·墓地把「月光黑羊」以外的1只「月光」怪兽加入手卡。
function c11317977.initial_effect(c)
	-- ①：可以把这张卡从手卡丢弃，从以下效果选择1个发动。●从自己墓地把「月光黑羊」以外的1只「月光」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11317977,0))  --"墓地回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c11317977.cost)
	e1:SetTarget(c11317977.thtg)
	e1:SetOperation(c11317977.thop)
	c:RegisterEffect(e1)
	-- ①：可以把这张卡从手卡丢弃，从以下效果选择1个发动。●从卡组把1张「融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11317977,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(c11317977.cost)
	e2:SetTarget(c11317977.sctg)
	e2:SetOperation(c11317977.scop)
	c:RegisterEffect(e2)
	-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从自己的额外卡组（表侧）·墓地把「月光黑羊」以外的1只「月光」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(c11317977.thcon2)
	e3:SetTarget(c11317977.thtg2)
	e3:SetOperation(c11317977.thop2)
	c:RegisterEffect(e3)
end
-- 效果①的发动代价（丢弃手牌中的这张卡）与操作提示
function c11317977.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将作为效果发动代价的此卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	-- 向对方玩家提示本卡所选择发动的具体效果提示信息
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 过滤条件：自己墓地中存在且可以加入手牌的「月光黑羊」以外的「月光」怪兽
function c11317977.thfilter(c)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER) and not c:IsCode(11317977) and c:IsAbleToHand()
end
-- 效果①选择墓地回收时的效果目标与合法性检测
function c11317977.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在进行合法性检测时，确认自己墓地是否存在可回收的「月光」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c11317977.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁处理信息：将墓地中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①选择墓地回收时的效果处理（从墓地选择1张「月光」怪兽加入手牌）
function c11317977.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择一张需要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地选择一只满足条件的「月光」怪兽
	local g=Duel.SelectMatchingCard(tp,c11317977.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己卡组中存在且可以加入手牌的「融合」魔法卡
function c11317977.scfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果①选择卡组检索时的效果目标与合法性检测
function c11317977.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在进行合法性检测时，确认自己卡组是否存在「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c11317977.scfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①选择卡组检索时的效果处理（从卡组检索「融合」加入手牌）
function c11317977.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择一张需要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择一张「融合」
	local g=Duel.SelectMatchingCard(tp,c11317977.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「融合」加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件判断（作为融合素材被送去墓地且不为回收状态）
function c11317977.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤条件：自己额外卡组表侧表示的灵摆「月光」怪兽或墓地中的「月光」怪兽（「月光黑羊」除外）
function c11317977.thfilter2(c)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER) and not c:IsCode(11317977) and c:IsAbleToHand()
		and ((c:IsFaceup() and c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_PENDULUM)) or c:IsLocation(LOCATION_GRAVE))
end
-- 效果②的发动目标与合法性检测
function c11317977.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在进行合法性检测时，确认自己额外卡组或墓地是否存在满足过滤条件的「月光」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c11317977.thfilter2,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁处理信息：将墓地或额外卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 效果②的效果处理（从额外卡组或墓地回收1只「月光」怪兽加入手牌）
function c11317977.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择一张需要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从受到「王家长眠之谷」过滤影响后的墓地/额外卡组选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11317977.thfilter2),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
