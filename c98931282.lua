--D－HERO ドレッドノートサーヴァント
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌特召·选场上卡破坏并检索「幽闭的钟楼」效果、②墓地特召触发弹对方场上卡回卡组顶效果
function s.initial_effect(c)
	-- 注册关联卡名列表：「幽闭的钟楼」
	aux.AddCodeList(c,24094653)
	-- ①：自己场上有「命运英雄」怪兽或场地魔法卡存在的场合才能发动。这张卡从手牌特殊召唤。那之后，可以选自己场上1张卡破坏，从卡组把1张「幽闭的钟楼」加入手牌。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：等级8以上的「命运英雄」怪兽在自己场上特殊召唤的场合，把墓地的这张卡除外，以对方场上1张卡为对象才能发动。那张卡回到持有者卡组最上方。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tdcon)
	-- Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 条件过滤：自己场上表侧表示的「命运英雄」怪兽或场地魔法卡
function s.cfilter(c)
	return (c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) or c:IsType(TYPE_FIELD)) and c:IsFaceup()
end
-- ①效果发动条件检查
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在表侧表示的「命运英雄」怪兽或场地魔法卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①效果发动准备：检查怪兽区域空位及自身特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 检索过滤条件：可以加入手牌的「幽闭的钟楼」
function s.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- ①效果处理：特殊召唤自身，之后可选自己场上1张卡破坏并检索「幽闭的钟楼」
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身与连锁关联并成功特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断自己场上是否存在可破坏的卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
		-- 判断卡组是否存在可检索的「幽闭的钟楼」
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否选择发动后续破坏并检索效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 分隔效果处理逻辑
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择自己场上1张卡
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
		if g:GetCount()>0 then
			-- 显示选中的卡片提示
			Duel.HintSelection(g)
			-- 成功破坏选中的卡时
			if Duel.Destroy(g,REASON_EFFECT)~=0 then
				-- 提示玩家选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				-- 从卡组选择1张「幽闭的钟楼」
				local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
				if sg:GetCount()>0 then
					-- 将选中的卡加入手牌
					Duel.SendtoHand(sg,nil,REASON_EFFECT)
					-- 向对方玩家确认加入手牌的卡
					Duel.ConfirmCards(1-tp,sg)
				end
			end
		end
	end
end
-- 触发条件过滤：自己特殊召唤成功的表侧表示8星以上的「命运英雄」怪兽
function s.cfilter2(c,tp)
	return c:IsFaceup() and c:IsLevel(8) and c:IsSetCard(0xc008) and c:IsSummonPlayer(tp)
end
-- ②效果发动条件：判定是否有满足条件的8星以上「命运英雄」特殊召唤
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil,tp)
end
-- ②效果发动准备与目标选择：选择对方场上1张卡返回卡组
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() and chkc:IsControler(1-tp) end
	-- 发动条件检查：对方场上是否存在可返回卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上1张卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：把选中的卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ②效果处理：将选中的卡返回持有者卡组最上方
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsOnField() then
		-- 将目标卡片放置在持有者卡组最上方
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
