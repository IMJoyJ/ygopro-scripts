--LL－バード・コール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组选1只「抒情歌鸲」怪兽加入手卡或送去墓地。那之后，可以把和那只怪兽卡名不同的1只「抒情歌鸲」怪兽从手卡特殊召唤。
function c45354718.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组选1只「抒情歌鸲」怪兽加入手卡或送去墓地。那之后，可以把和那只怪兽卡名不同的1只「抒情歌鸲」怪兽从手卡特殊召唤。
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
-- 筛选卡组中满足条件的「抒情歌鸲」怪兽：属于字段0xf7、是怪兽，并且当前可以加入手卡或送去墓地（即不受“不能加入手卡/不能送去墓地”的限制）。
function c45354718.filter(c)
	return c:IsSetCard(0xf7) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 效果发动时的合法性检查：确定效果是否满足发动条件，此处检查卡组中是否存在至少1只可被选择处理的「抒情歌鸲」怪兽。
function c45354718.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0（发动判定阶段）时，若卡组中存在至少1只符合条件的「抒情歌鸲」怪兽，则返回true允许效果发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c45354718.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 定义后续特殊召唤的筛选条件：手卡中的「抒情歌鸲」怪兽，卡名与最初选出的怪兽不同，且能够被当前效果特殊召唤（满足召唤条件和苏生限制）。
function c45354718.spfilter(c,e,tp,code)
	return c:IsSetCard(0xf7) and c:IsType(TYPE_MONSTER) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理的主流程：从卡组选择1只「抒情歌鸲」怪兽，让玩家选择将其加入手卡或送去墓地；若处理成功且场上/手卡条件允许，再询问玩家是否从手卡特殊召唤1只卡名不同的「抒情歌鸲」怪兽。
function c45354718.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家发送选择卡片的提示，显示“请选择要操作的卡”，用于接下来的卡组选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从己方卡组中选择1张满足filter条件的「抒情歌鸲」怪兽（效果处理时选卡，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c45354718.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	local res=false
	-- 判断该卡的处理方式：若其可以加入手卡，并且（不能送去墓地或玩家选择“加入手卡”选项），则后续执行加入手卡；否则执行送去墓地。
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将选中的「抒情歌鸲」怪兽加入其持有者的手卡；若实际加入成功且该卡确实位于手卡，则记为处理成功（res=true）。
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
			-- 向对方玩家展示刚刚加入手卡的卡片，以确认选择并处理了正确的卡。
			Duel.ConfirmCards(1-tp,tc)
			res=true
		end
	else
		-- 将选中的「抒情歌鸲」怪兽送去墓地；若实际送入成功且该卡确实位于墓地，则记为处理成功（res=true）。
		if Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
			res=true
		end
	end
	-- 检查是否满足后续特殊召唤的前置条件：之前的加入手卡/送去墓地处理成功，且己方主要怪兽区域有空位。
	if res and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只与已选怪兽卡名不同的「抒情歌鸲」怪兽，且该怪兽能够被当前效果特殊召唤。
		and Duel.IsExistingMatchingCard(c45354718.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,tc:GetCode())
		-- 询问玩家是否从手卡特殊召唤卡名不同的「抒情歌鸲」怪兽，选择“是”才继续后续特召处理。
		and Duel.SelectYesNo(tp,aux.Stringid(45354718,1)) then  --"是否从手卡特殊召唤卡名不同的怪兽？"
		-- 中断当前效果处理，使接下来的特殊召唤被视为单独的处理步骤（与之前的操作错开时点）。
		Duel.BreakEffect()
		-- 向当前玩家发送选择特殊召唤卡片的提示，显示“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡中选择1张满足spfilter条件的「抒情歌鸲」怪兽（与已选怪兽卡名不同，且可被当前效果特殊召唤）。
		local g2=Duel.SelectMatchingCard(tp,c45354718.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetCode())
		-- 将选中的「抒情歌鸲」怪兽以表侧表示特殊召唤到己方场上，并正常检查其召唤条件和苏生限制。
		Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
	end
end
