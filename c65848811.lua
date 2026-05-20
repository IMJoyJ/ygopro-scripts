--H・C 強襲のハルベルト
-- 效果：
-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：这张卡给与对方战斗伤害时才能发动。从卡组把1张「英豪」卡加入手卡。
function c65848811.initial_effect(c)
	-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c65848811.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- ③：这张卡给与对方战斗伤害时才能发动。从卡组把1张「英豪」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65848811,0))  --"卡组检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(c65848811.thcon)
	e3:SetTarget(c65848811.thtg)
	e3:SetOperation(c65848811.thop)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则的条件函数：检查自己场上没有怪兽、对方场上有怪兽，且自己场上有可用的怪兽区域
function c65848811.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽数量是否大于0
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 检索效果的发动条件：受到战斗伤害的玩家不是自己（即给与对方战斗伤害时）
function c65848811.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤函数：卡组中属于「英豪」字段且可以加入手牌的卡
function c65848811.filter(c)
	return c:IsSetCard(0x6f) and c:IsAbleToHand()
end
-- 检索效果的靶点函数：检查卡组中是否存在满足条件的卡，并设置检索的操作信息
function c65848811.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0（发动准备）：检查卡组中是否存在至少1张可以加入手牌的「英豪」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c65848811.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数：从卡组选择1张「英豪」卡加入手牌并给对方确认
function c65848811.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「英豪」卡
	local g=Duel.SelectMatchingCard(tp,c65848811.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
