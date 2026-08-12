--グローアップ・ブルーム
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只5星以上的不死族怪兽加入手卡。场地区域有「不死世界」存在的场合，也能不加入手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
function c92964816.initial_effect(c)
	-- ①：这张卡被送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只5星以上的不死族怪兽加入手卡。场地区域有「不死世界」存在的场合，也能不加入手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetDescription(aux.Stringid(92964816,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,92964816)
	-- 将墓地的这张卡除外作为发动的代价
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c92964816.target)
	e1:SetOperation(c92964816.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中5星以上的不死族怪兽，并根据是否满足特殊召唤条件来判断其是否可以加入手卡或特殊召唤
function c92964816.filter(c,e,tp,chk)
	return c:IsLevelAbove(5) and c:IsRace(RACE_ZOMBIE)
		and (c:IsAbleToHand() or chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果发动的目标选择与合法性检测
function c92964816.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查场地区域是否存在「不死世界」且自己场上是否有可用的怪兽区域
		local res=Duel.IsEnvironment(4064256,PLAYER_ALL,LOCATION_FZONE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的5星以上不死族怪兽
		return Duel.IsExistingMatchingCard(c92964816.filter,tp,LOCATION_DECK,0,1,nil,e,tp,res)
	end
end
-- 效果处理，从卡组选择1只5星以上的不死族怪兽，根据场上是否存在「不死世界」决定是加入手卡还是特殊召唤
function c92964816.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，再次检查场地区域是否存在「不死世界」且自己场上是否有可用的怪兽区域
	local res=Duel.IsEnvironment(4064256,PLAYER_ALL,LOCATION_FZONE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 给玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足条件的5星以上不死族怪兽
	local tc=Duel.SelectMatchingCard(tp,c92964816.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,res):GetFirst()
	if tc then
		if res and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断该怪兽是否无法加入手卡，或者玩家在提示中选择将其特殊召唤
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选择的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选择的怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 让对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		end
	end
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c92964816.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册直到回合结束生效的特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家不能特殊召唤不死族以外的怪兽
function c92964816.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_ZOMBIE)
end
