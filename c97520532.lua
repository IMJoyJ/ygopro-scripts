--ギミック・パペット－キメラ・ドール
-- 效果：
-- 机械族怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡是已连接召唤的场合才能发动。从卡组选1只「机关傀儡」怪兽加入手卡或送去墓地。自己场上的怪兽只有「机关傀儡」怪兽的场合，可以再从手卡把1只「机关傀儡」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族超量怪兽不能从额外卡组特殊召唤。
function c97520532.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：机械族怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,2)
	-- ①：这张卡是已连接召唤的场合才能发动。从卡组选1只「机关傀儡」怪兽加入手卡或送去墓地。自己场上的怪兽只有「机关傀儡」怪兽的场合，可以再从手卡把1只「机关傀儡」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97520532,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,97520532)
	e1:SetCondition(c97520532.thcon)
	e1:SetTarget(c97520532.thtg)
	e1:SetOperation(c97520532.thop)
	c:RegisterEffect(e1)
end
-- 连接召唤成功的场合才能发动的条件判断
function c97520532.thcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤卡组中可以加入手卡或送去墓地的「机关傀儡」怪兽
function c97520532.thfilter(c)
	return c:IsSetCard(0x1083) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 效果发动的目标确认与操作信息设置
function c97520532.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡或送去墓地的「机关傀儡」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c97520532.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息：从卡组将卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁信息：从卡组将卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤非「机关傀儡」怪兽或里侧表示的怪兽（用于判断场上是否只有「机关傀儡」怪兽）
function c97520532.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x1083)
end
-- 过滤手卡中可以特殊召唤的「机关傀儡」怪兽
function c97520532.spfilter(c,e,tp)
	return c:IsSetCard(0x1083) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：从卡组选1只「机关傀儡」怪兽加入手卡或送去墓地，若满足条件则可以再从手卡特殊召唤1只「机关傀儡」怪兽
function c97520532.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择1只满足条件的「机关傀儡」怪兽
	local g1=Duel.SelectMatchingCard(tp,c97520532.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g1:GetCount()>0 then
		local tc=g1:GetFirst()
		local res=false
		-- 如果该卡只能加入手卡，或者玩家在“加入手卡”和“送去墓地”中选择了“加入手卡”
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将选中的怪兽加入手卡，并确认是否成功加入手卡
			if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
				-- 给对方玩家确认加入手卡的卡
				Duel.ConfirmCards(1-tp,tc)
				res=true
			end
		else
			-- 将选中的怪兽送去墓地，并确认是否成功送去墓地
			if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
				res=true
			end
		end
		-- 获取手卡中可以特殊召唤的「机关傀儡」怪兽组
		local g2=Duel.GetMatchingGroup(c97520532.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 如果前一个操作成功且自己场上有可用的怪兽区域
		if res and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己场上是否只有「机关傀儡」怪兽，并让玩家选择是否从手卡特殊召唤
			and not Duel.IsExistingMatchingCard(c97520532.cfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(97520532,2)) then  --"是否从手卡特殊召唤？"
			-- 中断当前效果，使后续的特殊召唤处理与之前的检索/送墓处理不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g2:Select(tp,1,1,nil)
			-- 将选中的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是机械族超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c97520532.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内限制特殊召唤的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能从额外卡组特殊召唤机械族超量怪兽
function c97520532.splimit(e,c)
	return not (c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
