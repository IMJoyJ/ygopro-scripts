--暗黒の招来神
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤时才能发动。把「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只或者有那其中任意种的卡名记述的1张「暗黑之招来神」以外的卡从卡组加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只攻击力和守备力是0的恶魔族怪兽召唤。
function c81034083.initial_effect(c)
	-- 注册卡片效果中记述的特定卡片密码（神炎皇 乌利亚、降雷皇 哈蒙、幻魔皇 拉比艾尔），以便其他卡片进行检测
	aux.AddCodeList(c,6007213,32491822,69890967)
	-- ①：这张卡召唤时才能发动。把「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只或者有那其中任意种的卡名记述的1张「暗黑之招来神」以外的卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81034083,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,81034083)
	e1:SetTarget(c81034083.thtg)
	e1:SetOperation(c81034083.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只攻击力和守备力是0的恶魔族怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81034083,1))  --"使用「暗黑之招来神」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetTarget(c81034083.exstg)
	c:RegisterEffect(e2)
end
-- 过滤卡组中满足条件的卡片：卡名为「三幻魔」之一，或者记述了「三幻魔」任意卡名且非「暗黑之招来神」的卡，且该卡能加入手牌
function c81034083.thfilter(c)
	return (c:IsCode(6007213,32491822,69890967)
		-- 判断卡片效果文本中是否记述了「神炎皇 乌利亚」、「降雷皇 哈蒙」或「幻魔皇 拉比艾尔」的卡名
		or ((aux.IsCodeListed(c,6007213) or aux.IsCodeListed(c,32491822) or aux.IsCodeListed(c,69890967))
		and not c:IsCode(81034083))) and c:IsAbleToHand()
end
-- ①号效果的发动准备阶段，检查卡组中是否存在可检索的卡，并设置操作信息
function c81034083.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检测卡组中是否存在至少1张满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c81034083.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理的操作信息，声明该效果包含从卡组将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的处理阶段，让玩家从卡组选择1张符合条件的卡加入手牌并向对方展示
function c81034083.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端向发动效果的玩家显示“请选择要加入手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c81034083.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片通过效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片向对方玩家进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤额外召唤效果的目标怪兽，限定为攻击力和守备力均为0的恶魔族怪兽
function c81034083.exstg(e,c)
	return c:IsRace(RACE_FIEND) and c:IsAttack(0) and c:IsDefense(0)
end
