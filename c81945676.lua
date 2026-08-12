--メメント・メイス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方主要阶段，自己场上有「冥骸合龙-莫忘冥地王灵」存在的场合，把这张卡从手卡丢弃，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
-- ②：自己主要阶段才能发动。自己场上1只「莫忘」怪兽破坏，从卡组把「莫忘心钥精」以外的1张「莫忘」卡加入手卡。
local s,id,o=GetID()
-- 这个卡名的①②的效果1回合各能使用1次。注册卡片效果
function s.initial_effect(c)
	-- ①：对方主要阶段，自己场上有「冥骸合龙-莫忘冥地王灵」存在的场合，把这张卡从手卡丢弃，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(s.concon)
	e1:SetCost(s.concost)
	e1:SetTarget(s.contg)
	e1:SetOperation(s.conop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。自己场上1只「莫忘」怪兽破坏，从卡组把「莫忘心钥精」以外的1张「莫忘」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「冥骸合龙-莫忘冥地王灵」
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(23288411)
end
-- 效果①的发动条件判定
function s.concon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 判定是否为对方玩家的主要阶段
	return Duel.GetTurnPlayer()==1-tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
		-- 判定自己场上是否存在「冥骸合龙-莫忘冥地王灵」
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤对方场上可以改变控制权的表侧表示怪兽
function s.tfilter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 效果①的消耗判定与执行
function s.concost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动成本将这张卡从手牌丢弃
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 效果①的对象判定与选择
function s.contg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tfilter(chkc) end
	-- 判定对方场上是否存在可改变控制权的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.tfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为改变该怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果①的效果处理（得到控制权）
function s.conop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用效果，则直到结束阶段得到其控制权
	if tc:IsRelateToEffect(e) then Duel.GetControl(tc,tp,PHASE_END,1) end
end
-- 过滤自己场上表侧表示的「莫忘」怪兽
function s.dfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a1)
end
-- 过滤卡组中「莫忘心钥精」以外的「莫忘」卡片
function s.filter(c)
	return c:IsSetCard(0x1a1) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 效果②的对象判定与处理信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有表侧表示的「莫忘」怪兽
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,0,nil)
	-- 判定自己场上是否有「莫忘」怪兽可破坏，且卡组中是否有可检索的「莫忘」卡
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为破坏自己场上1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（破坏并检索）
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧表示的「莫忘」怪兽
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 执行破坏，若未成功破坏则效果处理终止
	if Duel.Destroy(g,REASON_EFFECT)<1 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「莫忘心钥精」以外的「莫忘」卡
	local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
