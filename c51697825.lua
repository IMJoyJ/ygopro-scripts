--ジャック・イン・ザ・ハンド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把3只卡名不同的1星怪兽给对方观看，对方从那之中选1只加入自身手卡。自己从剩下的卡之中选1只加入手卡，剩余回到卡组。
function c51697825.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把3只卡名不同的1星怪兽给对方观看，对方从那之中选1只加入自身手卡，自己从剩下的怪兽之中选1只加入手卡，剩余回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,51697825+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c51697825.target)
	e1:SetOperation(c51697825.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：只选择等级为1的怪兽，并且该怪兽既能被加入自己手牌，也能被加入对方手牌，以保证后续处理中双方都能合法将选中的卡加入手牌。
function c51697825.thfilter(c,tp)
	return c:IsLevel(1) and c:IsAbleToHand() and c:IsAbleToHand(1-tp)
end
-- 效果发动时的合法性检查：从卡组中寻找所有满足条件的1星怪兽，若其中卡名不同的种类数不足3，则不能发动；同时登记操作信息，表明本效果会从卡组将卡加入手牌。
function c51697825.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取我方卡组中所有满足条件的1星怪兽（等级1且可加入任一方手牌）作为候选组。
	local g=Duel.GetMatchingGroup(c51697825.thfilter,tp,LOCATION_DECK,0,nil,tp)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 end
	-- 登记操作信息：本效果涉及将卡从卡组加入手牌，目标玩家为双方，预计处理数量为1张，用于后续连锁时相关判定（如星尘龙等效果的检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_DECK)
end
-- 效果处理：从卡组选出3只卡名不同的1星怪兽给对方确认，对方选择1只加入其手牌，若处理成功，自己再从剩余卡中选择1只加入手牌，其余卡片自动留在卡组。
function c51697825.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新获取卡组中所有满足条件的1星怪兽作为本次选择池。
	local g=Duel.GetMatchingGroup(c51697825.thfilter,tp,LOCATION_DECK,0,nil,tp)
	-- 向己方玩家发送“请选择要加入手牌的卡”的提示信息，准备选择要展示的3只怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方玩家从候选组中选择3张卡，且所选卡名必须互不相同（通过aux.dncheck判定），不可取消，数量必须恰好为3张。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	if sg then
		-- 将选出的3只怪兽卡展示给对方玩家确认，即“给对方观看”的效果处理。
		Duel.ConfirmCards(1-tp,sg)
		-- 向对方玩家发送“请选择要加入手牌的卡”的提示信息，让对方从展示的3只怪兽中选择1只加入自身手牌。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local oc=sg:Select(1-tp,1,1,nil):GetFirst()
		oc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方选择的卡加入对方手牌；若加入成功且该卡仍处于手牌区，则继续执行后续由己方选择卡牌的处理。
		if Duel.SendtoHand(oc,1-tp,REASON_EFFECT)~=0 and oc:IsLocation(LOCATION_HAND) then
			sg:RemoveCard(oc)
			-- 在对方选完后，向己方玩家发送“请选择要加入手牌的卡”的提示信息，准备从剩余卡中选择1张加入手牌。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sc=sg:Select(tp,1,1,nil):GetFirst()
			sc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
			-- 将己方选择的卡加入己方手牌，完成‘自己从剩下的怪兽之中选1只加入手卡’的处理。
			Duel.SendtoHand(sc,tp,REASON_EFFECT)
		end
	end
end
