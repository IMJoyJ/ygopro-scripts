--モンスターアソート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组选种族·属性·等级是相同的1只通常怪兽和1只效果怪兽给对方观看，对方从那之中随机选1只。那1只怪兽加入自己手卡，剩余回到卡组。
function c23270035.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组选种族·属性·等级是相同的1只通常怪兽和1只效果怪兽给对方观看，对方从那之中随机选1只。那1只怪兽加入自己手卡，剩余回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,23270035+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c23270035.target)
	e1:SetOperation(c23270035.activate)
	c:RegisterEffect(e1)
end
-- 判断怪兽c是否为通常怪兽，并在当前候选组g中确认存在至少一只与c种族·属性·等级相同且为效果怪兽的其他卡，用于保证选出的2张卡符合条件。
function c23270035.filter(c,g)
	return g:IsExists(c23270035.filter2,1,c,c) and c:IsType(TYPE_NORMAL)
end
-- 判断效果怪兽c与基准怪兽cc的种族、属性、等级是否完全相同，且c必须是效果怪兽。
function c23270035.filter2(c,cc)
	return c:IsRace(cc:GetRace()) and c:IsAttribute(cc:GetAttribute()) and c:IsLevel(cc:GetLevel()) and c:IsType(TYPE_EFFECT)
end
-- SelectSubGroup的选择完成条件：已选出的卡组g中至少存在一只通常怪兽，能在组内找到另一只与其种族·属性·等级相同的效果怪兽，从而满足一组2张的要求。
function c23270035.fselect(g)
	return g:IsExists(c23270035.filter,1,nil,g)
end
-- 筛选卡组中可作为检索对象的怪兽卡，要求是怪兽且能够加入手卡（即未受到不能加入手卡的限制）。
function c23270035.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的合法性检查：从卡组筛选可加入手卡的怪兽，并确认能选出2张满足“一只通常怪兽与一只效果怪兽种族·属性·等级相同”的卡；满足则把操作信息设置为检索卡组中1张卡加入手卡。
function c23270035.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得己方卡组中所有能够加入手卡的怪兽卡，作为后续选择的候选集合。
	local g=Duel.GetMatchingGroup(c23270035.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:CheckSubGroup(c23270035.fselect,2,2) end
	-- 设置本连锁的操作信息：将处理从卡组把1张卡加入手卡的检索效果，具体对象留到效果处理时确定，因此targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选出符合条件的2张怪兽给对方确认；对方随机选择其中1张，将该卡加入自己手卡，剩余卡放回卡组并洗切卡组。
function c23270035.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次取得己方卡组中所有能够加入手卡的怪兽卡，作为操作阶段的候选集合（处理时重新获取，防止发动后卡组发生变化）。
	local g=Duel.GetMatchingGroup(c23270035.thfilter,tp,LOCATION_DECK,0,nil)
	-- 向玩家发出选择提示，提示内容为选择要加入手牌的卡，用于SelectSubGroup的选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local sg=g:SelectSubGroup(tp,c23270035.fselect,false,2,2)
	if sg and #sg==2 then
		-- 将选出的2张怪兽卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
		local tg=sg:RandomSelect(1-tp,1)
		-- 洗切己方卡组，使未选中的卡回到卡组并随机化。
		Duel.ShuffleDeck(tp)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将随机选中的那张卡加入其持有者的手卡（此效果下即自己），处理原因为效果。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
