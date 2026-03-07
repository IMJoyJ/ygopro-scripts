--トゥリスヴァレル・ドラゴン
-- 效果：
-- 包含「弹丸」怪兽的龙族·暗属性怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把「速射扳机」「重型扳机」「双式扳机」的其中1张加入手卡。
-- ②：以自己场上1张表侧表示卡和自己墓地1只龙族·暗属性怪兽为对象才能发动。作为对象的场上的卡破坏，作为对象的墓地的怪兽加入手卡。
local s,id,o=GetID()
-- 初始化效果函数，注册连接召唤手续、设置复活限制并创建两个效果
function s.initial_effect(c)
	-- 记录该卡包含「弹丸」怪兽的卡号
	aux.AddCodeList(c,67526112,20071842,38129297)
	-- 设置连接召唤条件：使用2~99个满足s.mfilter条件的怪兽作为连接素材，并通过s.lcheck验证连接素材中包含「弹丸」卡
	aux.AddLinkProcedure(c,s.mfilter,2,99,s.lcheck)
	c:EnableReviveLimit()
	-- 效果①：这张卡连接召唤的场合才能发动。从卡组把「速射扳机」「重型扳机」「双式扳机」的其中1张加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 效果②：以自己场上1张表侧表示卡和自己墓地1只龙族·暗属性怪兽为对象才能发动。作为对象的场上的卡破坏，作为对象的墓地的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收效果"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end
-- 连接素材过滤函数：筛选暗属性龙族或具有77189532效果的怪兽
function s.mfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_DARK) and (c:IsLinkRace(RACE_DRAGON) or c:IsHasEffect(77189532))
end
-- 连接素材检查函数：判断连接素材中是否包含「弹丸」卡
function s.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x102)
end
-- 效果①发动条件：确认该卡是通过连接召唤方式特殊召唤的
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤函数：筛选「速射扳机」「重型扳机」「双式扳机」卡并可加入手牌
function s.thfilter(c)
	return c:IsCode(67526112,20071842,38129297) and c:IsAbleToHand()
end
-- 效果①的发动准备阶段：检查卡组是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：准备将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的发动处理：选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的墓地目标过滤函数：筛选龙族·暗属性怪兽
function s.thfilter2(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备阶段：检查场上是否存在表侧表示卡，墓地是否存在龙族·暗属性怪兽
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查场上是否存在表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查墓地是否存在龙族·暗属性怪兽
		and Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上表侧表示卡
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择墓地龙族·暗属性怪兽
	local g2=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：准备破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 设置操作信息：准备将1张卡从墓地加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end
-- 效果②的发动处理：破坏对象卡并把对象怪兽加入手牌
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标卡
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	-- 判断目标卡是否有效并满足破坏条件
	if tc1:IsRelateToChain() and Duel.Destroy(tc1,REASON_EFFECT)>0 and tc2:IsRelateToChain() and aux.NecroValleyFilter()(tc2) then
		-- 将墓地怪兽加入手牌
		Duel.SendtoHand(tc2,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc2)
	end
end
