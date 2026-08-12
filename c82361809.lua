--スケアクロー・ライヒハート
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以从手卡往自己场上的「恐吓爪牙族」怪兽的相邻的或者相同纵列的自己的主要怪兽区域特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「恐吓爪牙族」魔法·陷阱卡加入手卡。场上有守备表示怪兽3只以上存在的场合，再让自己可以从卡组抽1张。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特殊召唤规则，②召唤·特殊召唤成功时检索「恐吓爪牙族」魔陷（若场上有3只以上守备表示怪兽则可再抽1张）
function c82361809.initial_effect(c)
	-- ①：这张卡可以从手卡往自己场上的「恐吓爪牙族」怪兽的相邻的或者相同纵列的自己的主要怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.hspcon)
	e1:SetValue(s.hspval)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「恐吓爪牙族」魔法·陷阱卡加入手卡。场上有守备表示怪兽3只以上存在的场合，再让自己可以从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82361809,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,82361809+o)
	e2:SetTarget(c82361809.thtg)
	e2:SetOperation(c82361809.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的「恐吓爪牙族」怪兽
function s.cfilter(c)
	return c:IsSetCard(0x17a) and c:IsFaceup()
end
-- 获取可以进行特殊召唤的区域（自己场上「恐吓爪牙族」怪兽的相邻或相同纵列的区域掩码）
function s.getzone(tp)
	local zone=0
	-- 获取自己场上所有表侧表示的「恐吓爪牙族」怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历这些「恐吓爪牙族」怪兽
	for tc in aux.Next(g) do
		local seq=tc:GetSequence()
		if seq==5 or seq==6 then
			-- 若怪兽在额外怪兽区域，则将其相同纵列的主要怪兽区域（通过MZoneSequence转换）加入可用区域掩码
			zone=zone|(1<<aux.MZoneSequence(seq))
		else
			if seq>0 then zone=zone|(1<<(seq-1)) end
			if seq<4 then zone=zone|(1<<(seq+1)) end
		end
	end
	return zone
end
-- 特殊召唤规则的条件判定：检查是否存在可用的特殊召唤区域
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=s.getzone(tp)
	-- 检查在计算出的可用区域掩码中，是否至少有一个空余的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 特殊召唤规则的值函数：指定特殊召唤到计算出的可用区域掩码中
function s.hspval(e,c)
	local tp=c:GetControler()
	return 0,s.getzone(tp)
end
-- 过滤条件：卡组中可加入手牌的「恐吓爪牙族」魔法·陷阱卡
function c82361809.thfilter(c)
	return c:IsSetCard(0x17a) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的靶向处理（Target）：检查卡组中是否存在可检索的卡，并设置检索的操作信息
function c82361809.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「恐吓爪牙族」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c82361809.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的执行处理（Operation）：将检索卡加入手牌，并根据场上守备表示怪兽数量决定是否抽卡
function c82361809.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「恐吓爪牙族」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c82361809.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 检查玩家当前是否可以抽卡
		if Duel.IsPlayerCanDraw(tp,1)
			-- 检查双方场上的守备表示怪兽数量是否在3只以上
			and Duel.GetMatchingGroupCount(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)>=3
			-- 询问玩家是否选择进行抽卡
			and Duel.SelectYesNo(tp,aux.Stringid(82361809,1)) then  --"是否抽卡？"
			-- 中断当前效果处理，使后续的抽卡处理与检索处理不视为同时进行
			Duel.BreakEffect()
			-- 洗切玩家的卡组
			Duel.ShuffleDeck(tp)
			-- 玩家从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
