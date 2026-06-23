--森の聖騎士 ワンコ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「童话故事 序章 启程的曙光」加入手卡。自己的场上或墓地有「童话故事 序章 启程的曙光」存在的场合，作为代替让自己也能抽1张。
-- ②：只要场地区域有卡存在，对方怪兽不能选择其他怪兽作为攻击对象。
-- ③：这张卡被战斗破坏时才能发动。让把这张卡破坏的怪兽的攻击力下降500。
local s,id,o=GetID()
-- 初始化效果函数，注册所有效果
function s.initial_effect(c)
	-- 记录该卡拥有「童话故事 序章 启程的曙光」的卡名
	aux.AddCodeList(c,43236494)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「童话故事 序章 启程的曙光」加入手卡。
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
	-- ②：只要场地区域有卡存在，对方怪兽不能选择其他怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetCondition(s.indescon)
	e3:SetValue(s.atlimit)
	c:RegisterEffect(e3)
	-- ③：这张卡被战斗破坏时才能发动。让把这张卡破坏的怪兽的攻击力下降500。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
-- 检索过滤器函数，用于筛选卡组中可加入手牌的「童话故事 序章 启程的曙光」
function s.thfilter(c)
	return c:IsCode(43236494) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，判断是否满足发动条件
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在「童话故事 序章 启程的曙光」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 判断场上或墓地是否存在「童话故事 序章 启程的曙光」
		or Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceupEx,Card.IsCode),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,43236494)
			-- 判断玩家是否可以抽卡
			and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁操作信息，提示将要从卡组检索一张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，根据条件选择检索或抽卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上或墓地是否存在「童话故事 序章 启程的曙光」
	local dr=Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceupEx,Card.IsCode),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,43236494)
		-- 判断玩家是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1)
	-- 判断是否满足检索条件并询问是否抽卡
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and (not dr or not Duel.SelectYesNo(tp,aux.Stringid(id,3))) then  --"是否作为代替而抽卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择一张「童话故事 序章 启程的曙光」加入手牌
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	elseif dr then
		-- 让玩家抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 判断场地区域是否存在卡
function s.indescon(e)
	-- 判断场地区域是否存在卡
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 设置攻击限制函数，使对方怪兽不能选择该卡作为攻击对象
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 判断被战斗破坏的怪兽是否参与了战斗
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	return rc:IsRelateToBattle()
end
-- 效果处理函数，使破坏该卡的怪兽攻击力下降500
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	if rc:IsRelateToBattle() and rc:IsType(TYPE_MONSTER) then
		-- 设置攻击力下降500的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
	end
end
