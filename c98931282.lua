--D－HERO ドレッドノートサーヴァント
local s,id,o=GetID()
-- 注册关联卡名以及手卡的起动效果和墓地的诱发效果
function s.initial_effect(c)
	-- 记录这张卡上记载的卡名「幽狱的钟楼」
	aux.AddCodeList(c,24094653)
	-- 自己场上有「命运英雄」怪兽或场地魔法卡表侧表示存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以把场上1张卡破坏，从卡组把1张「幽狱的钟楼」加入手卡。
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
	-- 自己场上有8星「命运英雄」怪兽特殊召唤的场合，把墓地的这张卡除外，以对方场上1张卡为对象才能发动。那张卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tdcon)
	-- 设置将这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 判断是否为表侧表示的「命运英雄」怪兽或场地魔法卡
function s.cfilter(c)
	return (c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) or c:IsType(TYPE_FIELD)) and c:IsFaceup()
end
-- 判断自己场上是否存在表侧表示的「命运英雄」怪兽或场地魔法卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否至少存在1张符合条件的卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 判断是否有可用的怪兽区域并且这张卡能否被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否还有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，预计从手卡特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 判断卡片是否为「幽狱的钟楼」并且可以加入手卡
function s.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果处理，特殊召唤这张卡，然后可以选场上1张卡破坏并检索「幽狱的钟楼」
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果这张卡特殊召唤成功
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 并且场上存在可以被破坏的卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
		-- 并且卡组中存在可以加入手卡的「幽狱的钟楼」
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 并且玩家选择发动后续效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 中断效果处理，使前后的处理视为不同时发生
		Duel.BreakEffect()
		-- 向玩家提示请选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择场上1张卡
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
		if g:GetCount()>0 then
			-- 为选中的卡显示被选为对象的动画
			Duel.HintSelection(g)
			-- 如果成功破坏了选中的卡
			if Duel.Destroy(g,REASON_EFFECT)~=0 then
				-- 向玩家提示请选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				-- 让玩家从卡组选择1张「幽狱的钟楼」
				local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
				if sg:GetCount()>0 then
					-- 将选中的「幽狱的钟楼」加入手卡
					Duel.SendtoHand(sg,nil,REASON_EFFECT)
					-- 向对方确认加入手卡的卡
					Duel.ConfirmCards(1-tp,sg)
				end
			end
		end
	end
end
-- 判断是否为自己场上表侧表示特殊召唤的8星「命运英雄」怪兽
function s.cfilter2(c,tp)
	return c:IsFaceup() and c:IsLevel(8) and c:IsSetCard(0xc008) and c:IsSummonPlayer(tp)
end
-- 判断是否有符合条件的8星怪兽特殊召唤成功
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil,tp)
end
-- 判断对方场上是否存在可以回到卡组的卡并设置取对象和操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1张可以回到卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择对方场上1张卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，预计使1张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理，将选中的目标卡回到卡组最上方
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsOnField() then
		-- 将选中的目标卡回到卡组最上方
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
