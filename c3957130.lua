--トゥリスヴァレル・ドラゴン
-- 效果：
-- 包含「弹丸」怪兽的龙族·暗属性怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把「速射扳机」「重型扳机」「双式扳机」的其中1张加入手卡。
-- ②：以自己场上1张表侧表示卡和自己墓地1只龙族·暗属性怪兽为对象才能发动。作为对象的场上的卡破坏，作为对象的墓地的怪兽加入手卡。
local s,id,o=GetID()
-- 初始化函数：登记关联卡名、设置连接召唤手续、启用苏生限制，并注册①检索效果和②破坏回手两个效果。
function s.initial_effect(c)
	-- 登记本卡效果文本中出现的三张卡（速射扳机、重型扳机、双式扳机），使此卡被视为记载了这些卡名。
	aux.AddCodeList(c,67526112,20071842,38129297)
	-- 设置连接召唤手续：使用2～99只满足s.mfilter的怪兽作为连接素材，且素材组需满足s.lcheck（至少包含1只「弹丸」怪兽）。
	aux.AddLinkProcedure(c,s.mfilter,2,99,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从卡组把「速射扳机」「重型扳机」「双式扳机」的其中1张加入手卡。
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
	-- ②：以自己场上1张表侧表示卡和自己墓地1只龙族·暗属性怪兽为对象才能发动。作为对象的场上的卡破坏，作为对象的墓地的怪兽加入手卡。
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
-- 连接素材过滤：素材必须可作为暗属性连接素材，且是龙族连接素材或拥有「弹丸」怪兽相关效果。
function s.mfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_DARK) and (c:IsLinkRace(RACE_DRAGON) or c:IsHasEffect(77189532))
end
-- 素材组检查：连接素材中必须至少存在1只「弹丸」系列怪兽。
function s.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x102)
end
-- ①效果的发动条件：这张卡以连接召唤方式特殊召唤成功。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索对象过滤：卡名为「速射扳机」「重型扳机」「双式扳机」之一，且可加入手卡。
function s.thfilter(c)
	return c:IsCode(67526112,20071842,38129297) and c:IsAbleToHand()
end
-- ①效果的发动目标：进行合法性检查并设置操作信息，表示将从卡组把1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若是发动判定阶段（chk==0），检查自己卡组是否存在至少1张符合条件的检索对象。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 将本次效果的操作信息登记为：从卡组把1张卡加入手卡，供其他卡检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1张符合条件的卡加入手卡，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张满足s.thfilter的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 墓地对象过滤：龙族、暗属性、怪兽，且可加入手卡。
function s.thfilter2(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动目标：检查能否选择场上表侧表示卡和墓地符合条件的龙族暗属性怪兽，并选择这两个对象。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 若为发动判定，检查自己场上是否存在至少1张表侧表示卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil)
		-- 同时检查自己墓地是否存在至少1只符合条件的龙族暗属性怪兽。
		and Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示卡作为破坏对象。
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只龙族暗属性怪兽作为加入手牌的对象。
	local g2=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记效果信息：破坏对象g1（1张）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 登记效果信息：将g2加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end
-- ②效果处理：先取回两个对象并保证顺序；若场上对象仍关联且被成功破坏，且墓地对象仍关联且不受王家长眠之谷影响，则将墓地对象加入手卡并展示。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的两个对象卡，分别赋给tc1、tc2。
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	-- 判断条件：场上对象仍与此效果关联，且破坏成功；墓地对象仍关联且不受王家长眠之谷影响，则继续回手。
	if tc1:IsRelateToChain() and Duel.Destroy(tc1,REASON_EFFECT)>0 and tc2:IsRelateToChain() and aux.NecroValleyFilter()(tc2) then
		-- 将墓地对象加入其持有者的手卡。
		Duel.SendtoHand(tc2,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡。
		Duel.ConfirmCards(1-tp,tc2)
	end
end
