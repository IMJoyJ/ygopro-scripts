--艮神鬼門 三千世界
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上的里侧表示卡任意数量为对象才能发动。那些里侧表示卡数量的场地魔法卡以外的「艮神鬼」卡从卡组加入手卡（同名卡最多1张）。那之后，作为对象的里侧表示卡送去墓地。
-- ②：自己场上有「艮神鬼」怪兽以及里侧表示卡存在的状态，场上有卡被盖放的场合，以场上1张卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动效果以及①②效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上的里侧表示卡任意数量为对象才能发动。那些里侧表示卡数量的场地魔法卡以外的「艮神鬼」卡从卡组加入手卡（同名卡最多1张）。那之后，作为对象的里侧表示卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：自己场上有「艮神鬼」怪兽以及里侧表示卡存在的状态，场上有卡被盖放的场合，以场上1张卡为对象才能发动。那张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SSET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_MSET)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_CHANGE_POS)
	e5:SetCondition(s.thcon2)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetCondition(s.thcon2)
	c:RegisterEffect(e6)
end
-- 过滤卡组中除场地魔法卡以外、可以加入手卡的「艮神鬼」卡
function s.thfilter(c)
	return c:IsSetCard(0x1e4) and not c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 过滤场上可以送去墓地的里侧表示卡
function s.tgfilter(c)
	return c:IsFacedown() and c:IsAbleToGrave()
end
-- ①效果的目标选择与发动条件判定：以自己场上任意数量的里侧表示卡为对象
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取卡组中满足条件的「艮神鬼」卡片组
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	-- 判定卡组中存在不同名「艮神鬼」卡且自己场上存在可作为对象的里侧表示卡
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要作为对象送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1到ct张里侧表示卡作为对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,ct,nil)
	-- 设置操作信息：将所选对象送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	-- 设置操作信息：从卡组将等同于对象数量的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,g:GetCount(),tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组将对象数量的同名卡最多1张的「艮神鬼」卡加入手卡，那之后将对象送去墓地
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中满足条件的「艮神鬼」卡片组
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 获取与连锁相关且仍为里侧表示的对象卡片组
	local sg=Duel.GetTargetsRelateToChain():Filter(Card.IsFacedown,nil)
	local sct=sg:GetCount()
	if sct>0 and g:GetClassCount(Card.GetCode)>=sct then
		-- 提示玩家选择要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择与对象数量相等且卡名互不相同的「艮神鬼」卡
		local tg=g:SelectSubGroup(tp,aux.dncheck,false,sct,sct)
		if tg then
			-- 将选择的「艮神鬼」卡加入手卡
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tg)
			if tg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
				-- 将作为对象的里侧表示卡送去墓地
				Duel.SendtoGrave(sg,REASON_EFFECT)
			end
		end
	end
end
-- 过滤自己场上表侧表示的「艮神鬼」怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1e4)
end
-- 判定魔陷/怪兽盖放时自己场上是否存在「艮神鬼」怪兽以及里侧表示卡
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己怪兽区是否存在「艮神鬼」表侧表示怪兽（排除触发事件卡）
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,eg)
		-- 判定自己场上是否存在里侧表示卡（排除触发事件卡）
		and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,0,1,eg)
end
-- 判定表示形式变更或特殊召唤为里侧守备时，场上是否有卡盖放且自己场上存在「艮神鬼」怪兽与里侧卡
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己怪兽区是否存在「艮神鬼」表侧表示怪兽（排除触发事件卡）
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,eg)
		-- 判定自己场上是否存在里侧表示卡（排除触发事件卡）
		and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,0,1,eg)
		and eg:IsExists(Card.IsFacedown,1,nil)
end
-- ②效果的目标选择与发动条件判定：以场上1张卡为对象
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 判定场上是否存在可以回到手卡的目标卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1张卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将所选对象卡返回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理：将作为对象的场上的卡回到手卡
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 将目标卡片返回手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
