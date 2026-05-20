--クリフォート・ツール
-- 效果：
-- ←9 【灵摆】 9→
-- ①：自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
-- ②：1回合1次，支付800基本分才能发动。从卡组把「机壳工具 丑恶」以外的1张「机壳」卡加入手卡。
-- 【怪兽描述】
-- 正在准备以副本模式启动系统...
-- C:\sophia\sefiroth.exe 执行中发生错误。
-- 正在试图执行来自未知发布者的以下程序。
-- C:\tierra\qliphoth.exe 您想允许执行吗? <Y/N>...[Y]
-- 以自律模式启动系统。
function c65518099.initial_effect(c)
	-- 启用灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c65518099.splimit)
	c:RegisterEffect(e2)
	-- ②：1回合1次，支付800基本分才能发动。从卡组把「机壳工具 丑恶」以外的1张「机壳」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65518099,0))  --"卡组检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c65518099.cost)
	e3:SetTarget(c65518099.target)
	e3:SetOperation(c65518099.operation)
	c:RegisterEffect(e3)
end
-- 限制特殊召唤的怪兽必须是「机壳」怪兽
function c65518099.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xaa)
end
-- 效果的发动代价（Cost）处理，检查并支付800基本分
function c65518099.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 玩家支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 过滤卡组中「机壳工具 丑恶」以外的「机壳」卡片且能加入手牌
function c65518099.filter(c)
	return c:IsSetCard(0xaa) and not c:IsCode(65518099) and c:IsAbleToHand()
end
-- 效果的发动检测与效果分类注册，检查卡组中是否存在符合条件的卡，并设置检索操作信息
function c65518099.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c65518099.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的处理信息为从自己卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理，从卡组选择1张符合条件的卡加入手牌并给对方确认
function c65518099.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c65518099.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
