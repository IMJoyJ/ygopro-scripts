--ジャック・イン・ザ・ハンド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把3只卡名不同的1星怪兽给对方观看，对方从那之中选1只加入自身手卡。自己从剩下的卡之中选1只加入手卡，剩余回到卡组。
function c51697825.initial_effect(c)
	-- 初始化卡片效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,51697825+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c51697825.target)
	e1:SetOperation(c51697825.activate)
	c:RegisterEffect(e1)
end
-- ①：自己·对方的战斗阶段才能发动。从自己的手卡·卡组·场上·墓地把融合怪兽卡决定的融合素材怪兽除外，把以「暗黑骑士 盖亚」怪兽为融合素材的那1只融合怪兽从额外卡组融合召唤。这个效果在「螺旋枪杀」的效果适用的战斗阶段发动的场合，也能把对方场上的怪兽作为融合素材。
function c51697825.thfilter(c,tp)
	return c:IsLevel(1) and c:IsAbleToHand() and c:IsAbleToHand(1-tp)
end
-- 过滤条件：可作为融合素材除外的怪兽
function c51697825.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 过滤条件：以「盖亚」怪兽为素材的融合怪兽
	local g=Duel.GetMatchingGroup(c51697825.thfilter,tp,LOCATION_DECK,0,nil,tp)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 end
	-- 发动条件与操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_DECK)
end
-- 判断「螺旋枪杀」效果是否适用
function c51697825.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否存在可融合召唤的合法素材与怪兽
	local g=Duel.GetMatchingGroup(c51697825.thfilter,tp,LOCATION_DECK,0,nil,tp)
	-- 设置操作信息：融合召唤
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 设置操作信息：除外融合素材
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	if sg then
		-- 效果处理函数
		Duel.ConfirmCards(1-tp,sg)
		-- 提示选择要融合召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local oc=sg:Select(1-tp,1,1,nil):GetFirst()
		oc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 选择要融合召唤的怪兽
		if Duel.SendtoHand(oc,1-tp,REASON_EFFECT,1-tp)~=0 and oc:IsLocation(LOCATION_HAND) then
			sg:RemoveCard(oc)
			-- 选择融合素材
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sc=sg:Select(tp,1,1,nil):GetFirst()
			sc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
			-- 除外融合素材并进行融合召唤
			Duel.SendtoHand(sc,tp,REASON_EFFECT)
		end
	end
end
