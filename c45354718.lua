--LL－バード・コール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组选1只「抒情歌鸲」怪兽加入手卡或送去墓地。那之后，可以把和那只怪兽卡名不同的1只「抒情歌鸲」怪兽从手卡特殊召唤。
function c45354718.initial_effect(c)
	-- 效果原文：①：从卡组选1只「抒情歌鸲」怪兽加入手卡或送去墓地。那之后，可以把和那只怪兽卡名不同的1只「抒情歌鸲」怪兽从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45354718,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,45354718+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c45354718.target)
	e1:SetOperation(c45354718.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选卡组中满足条件的「抒情歌鸲」怪兽（可加入手卡或送去墓地）
function c45354718.filter(c)
	return c:IsSetCard(0xf7) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 效果处理的target函数，检查是否满足发动条件（卡组中存在符合条件的怪兽）
function c45354718.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的卡组中是否存在至少1张满足filter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c45354718.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 过滤函数，用于筛选手卡中满足条件的「抒情歌鸲」怪兽（卡名与之前选择的怪兽不同，且可特殊召唤）
function c45354718.spfilter(c,e,tp,code)
	return c:IsSetCard(0xf7) and c:IsType(TYPE_MONSTER) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理的activate函数，执行具体效果：从卡组选择1只「抒情歌鸲」怪兽加入手卡或送去墓地，之后可特殊召唤手卡中不同卡名的「抒情歌鸲」怪兽
function c45354718.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡（从卡组中选择）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1张满足filter条件的卡
	local g=Duel.SelectMatchingCard(tp,c45354718.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	local res=false
	-- 判断该卡是否可加入手卡，若不可送去墓地则优先选择加入手卡
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将该卡加入手卡，并确认对方可见
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
			-- 向对方玩家确认该卡已加入手卡
			Duel.ConfirmCards(1-tp,tc)
			res=true
		end
	else
		-- 将该卡送去墓地
		if Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
			res=true
		end
	end
	-- 判断是否满足特殊召唤条件（有空场、手卡中有符合条件的怪兽、玩家选择特殊召唤）
	if res and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足spfilter条件的怪兽
		and Duel.IsExistingMatchingCard(c45354718.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,tc:GetCode())
		-- 询问玩家是否选择特殊召唤手卡中的怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(45354718,1)) then  --"是否从手卡特殊召唤卡名不同的怪兽？"
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡（从手卡中选择）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡中选择1张满足spfilter条件的卡
		local g2=Duel.SelectMatchingCard(tp,c45354718.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetCode())
		-- 将选中的卡以正面表示方式特殊召唤到场上
		Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
	end
end
