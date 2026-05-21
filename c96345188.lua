--RR－ミミクリー・レイニアス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的回合的自己主要阶段才能发动1次。自己场上的全部「急袭猛禽」怪兽的等级上升1星。
-- ②：这张卡被送去墓地的回合的自己主要阶段，把墓地的这张卡除外才能发动。从卡组把「急袭猛禽-模拟伯劳」以外的1张「急袭猛禽」卡加入手卡。
function c96345188.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的回合的自己主要阶段才能发动1次。自己场上的全部「急袭猛禽」怪兽的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c96345188.lvcon)
	e1:SetTarget(c96345188.lvtg)
	e1:SetOperation(c96345188.lvop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的回合的自己主要阶段，把墓地的这张卡除外才能发动。从卡组把「急袭猛禽-模拟伯劳」以外的1张「急袭猛禽」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,96345188)
	e2:SetCondition(c96345188.thcon)
	-- 把墓地的这张卡除外作为发动效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c96345188.thtg)
	e2:SetOperation(c96345188.thop)
	c:RegisterEffect(e2)
	if not c96345188.global_check then
		c96345188.global_check=true
		-- ①：这张卡召唤·特殊召唤的回合的自己主要阶段才能发动1次。自己场上的全部「急袭猛禽」怪兽的等级上升1星。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 召唤成功时，给自身添加已召唤的标记
		ge1:SetOperation(aux.sumreg)
		ge1:SetLabel(96345188)
		-- 注册用于检测通常召唤成功的全局效果
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(96345188)
		-- 注册用于检测特殊召唤成功的全局效果
		Duel.RegisterEffect(ge2,0)
	end
end
-- 效果①的发动条件：这张卡在召唤·特殊召唤的回合
function c96345188.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(96345188)>0
end
-- 过滤条件：自己场上表侧表示且有等级的「急袭猛禽」怪兽
function c96345188.filter(c)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsSetCard(0xba)
end
-- 效果①的发动准备（检查场上是否存在满足条件的「急袭猛禽」怪兽）
function c96345188.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示且有等级的「急袭猛禽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96345188.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果①的处理：使自己场上的全部「急袭猛禽」怪兽等级上升1星
function c96345188.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示且有等级的「急袭猛禽」怪兽
	local g=Duel.GetMatchingGroup(c96345188.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 等级上升1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 效果②的发动条件：这张卡被送去墓地的回合
function c96345188.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张卡被送去墓地的回合是否为当前回合，且不是因为从除外状态回到墓地
	return e:GetHandler():GetTurnID()==Duel.GetTurnCount() and not e:GetHandler():IsReason(REASON_RETURN)
end
-- 过滤条件：卡组中「急袭猛禽-模拟伯劳」以外的「急袭猛禽」卡片，且能加入手卡
function c96345188.thfilter(c)
	return c:IsSetCard(0xba) and not c:IsCode(96345188) and c:IsAbleToHand()
end
-- 效果②的发动准备（检查卡组并设置检索的操作信息）
function c96345188.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「急袭猛禽-模拟伯劳」以外的「急袭猛禽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c96345188.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果的处理是将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组将1张「急袭猛禽-模拟伯劳」以外的「急袭猛禽」卡加入手卡并给对方确认
function c96345188.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「急袭猛禽」卡
	local g=Duel.SelectMatchingCard(tp,c96345188.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡通过效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
