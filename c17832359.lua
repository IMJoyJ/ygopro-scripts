--森の聖騎士 ワンコ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「童话故事 序章 启程的曙光」加入手卡。自己的场上或墓地有「童话故事 序章 启程的曙光」存在的场合，作为代替让自己也能抽1张。
-- ②：只要场地区域有卡存在，对方怪兽不能选择其他怪兽作为攻击对象。
-- ③：这张卡被战斗破坏时才能发动。让把这张卡破坏的怪兽的攻击力下降500。
local s,id,o=GetID()
-- 注册本卡的全部效果：①用e1/e2分别登记召唤·特殊召唤成功时的检索或代替抽卡效果（e1为召唤，e2为克隆的特殊召唤），②用e3登记场地有卡时限制对方攻击对象的永续效果，③用e4登记被战斗破坏后降低破坏者攻击力的诱发效果，并通过aux.AddCodeList登记关联卡名43236494。
function s.initial_effect(c)
	-- 将卡号43236494（童话故事 序章 启程的曙光）加入本卡的“记载卡名”列表，用于处理“从卡组把那张卡加入手卡”等关联卡名的效果。
	aux.AddCodeList(c,43236494)
	-- 对应①效果：这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「童话故事 序章 启程的曙光」加入手卡。自己的场上或墓地有「童话故事 序章 启程的曙光」存在的场合，作为代替让自己也能抽1张。（此处e1先注册召唤成功时的诱发效果，e2再克隆为特殊召唤成功时的诱发效果）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH|CATEGORY_TOHAND|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 对应②效果：②：只要场地区域有卡存在，对方怪兽不能选择其他怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetCondition(s.indescon)
	e3:SetValue(s.atlimit)
	c:RegisterEffect(e3)
	-- 对应③效果：③：这张卡被战斗破坏时才能发动。让把这张卡破坏的怪兽的攻击力下降500。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
-- 定义检索过滤函数：候选卡必须是卡号43236494的「童话故事 序章 启程的曙光」，且能够加入手卡；用于卡组检索时选卡。
function s.thfilter(c)
	return c:IsCode(43236494) and c:IsAbleToHand()
end
-- 效果发动的合法性判定：满足“卡组存在可检索的「童话故事 序章 启程的曙光」”或“自己场上·墓地有表侧表示的那张卡且自己可以抽1张”时，效果可以发动。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0（发动时点）检查：卡组是否存在1张满足s.thfilter的卡（即「童话故事 序章 启程的曙光」且可加入手卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 或检查：自己场上·墓地是否存在1张卡号为43236494的「童话故事 序章 启程的曙光」（这里用IsFaceupEx判定场上表侧表示/墓地中可确认状态）。
		or Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceupEx,Card.IsCode),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,43236494)
			-- 并且自己具备抽1张卡的能力（不受不能抽卡效果影响）；该条件与上一行共同构成“代替抽卡”的发动可行性。
			and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息：本连锁可能从卡组将1张卡加入手卡，使相关效果能正确检测到CATEGORY_TOHAND；因处理时检索对象不确定，targets传nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理①效果：先计算是否满足代替抽卡条件dr；若卡组有检索对象且（dr不成立或玩家选择不代替抽卡），则从卡组选「童话故事 序章 启程的曙光」加入手卡并给对方确认；否则若dr成立则自己抽1张。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算dr：检查自己场上或墓地是否存在卡号43236494的「童话故事 序章 启程的曙光」，作为能否“代替抽卡”的判断条件之一。
	local dr=Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceupEx,Card.IsCode),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,43236494)
		-- dr还要求自己可以抽1张卡；与上一行共同决定是否能够执行代替抽卡。
		and Duel.IsPlayerCanDraw(tp,1)
	-- 执行分支：当卡组存在检索对象，且（不满足代替抽卡条件，或玩家选择不代替抽卡）时进行检索；否则若dr成立则改为抽卡。
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and (not dr or not Duel.SelectYesNo(tp,aux.Stringid(id,3))) then  --"是否作为代替而抽卡？"
		-- 为玩家显示选择提示，使其从卡组选择一张要加入手牌的卡（对应“请选择要加入手牌的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张满足s.thfilter的卡（即「童话故事 序章 启程的曙光」）作为检索对象。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 将选中的卡以效果原因加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将检索加入手卡的卡展示给对方玩家确认，保证信息透明。
			Duel.ConfirmCards(1-tp,g)
		end
	elseif dr then
		-- 自己以效果原因抽1张卡，作为“代替检索”的抽卡处理。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 定义②效果的适用条件：双方场地区域合计存在至少1张卡（任意卡）时，该攻击限制效果适用。
function s.indescon(e)
	-- 检查双方场地区域（LOCATION_FZONE）是否存在至少1张卡；有则满足②效果的条件。
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 定义攻击对象选择限制：对方怪兽选择攻击对象时，候选怪兽c不能是「汪汪」以外的卡，即对方怪兽只能选择「汪汪」作为攻击对象。
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 定义③效果的发动条件：本卡被战斗破坏时，获取导致其破坏的怪兽rc；若rc仍与本次战斗相关（未被从处理中移除），才可发动。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	return rc:IsRelateToBattle()
end
-- 定义③效果处理：取破坏本卡的怪兽，若其仍在场且为怪兽，则为其注册一个攻击力下降500的效果，并在离场/标准重置后失效。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	if rc:IsRelateToBattle() and rc:IsType(TYPE_MONSTER) then
		-- 对应③效果原文：让把这张卡破坏的怪兽的攻击力下降500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
	end
end
