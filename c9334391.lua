--宝玉の絆
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「宝玉兽」怪兽加入手卡，从卡组选和那只怪兽卡名不同的1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c9334391.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只「宝玉兽」怪兽加入手卡，从卡组选和那只怪兽卡名不同的1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,9334391+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c9334391.target)
	e1:SetOperation(c9334391.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中可以加入手卡的「宝玉兽」怪兽，且卡组中必须存在另一只与之卡名不同的「宝玉兽」怪兽
function c9334391.thfilter(c,tp)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		-- 检查卡组中是否存在至少1张与该怪兽卡名不同的、可以放置到魔陷区的「宝玉兽」怪兽
		and Duel.IsExistingMatchingCard(c9334391.plfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 过滤卡组中与指定卡名不同、且未被禁止放置到魔陷区的「宝玉兽」怪兽
function c9334391.plfilter(c,code)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsCode(code) and not c:IsForbidden()
end
-- 效果发动的目标过滤与可行性检查（检查魔陷区空位数以及卡组中是否存在满足条件的「宝玉兽」怪兽组合）
function c9334391.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=0
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=1 end
	-- 在发动检查时，确认自己的魔法与陷阱区域有可用的空位（若此卡从手卡发动，则需预留该卡占用的1个魔陷格）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>ft
		-- 在发动检查时，确认卡组中存在可检索的「宝玉兽」怪兽（且卡组中还有另一只不同名的「宝玉兽」怪兽可供放置）
		and Duel.IsExistingMatchingCard(c9334391.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置连锁信息，表明该效果包含“从卡组将1张卡加入手卡”的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数（依次处理检索「宝玉兽」怪兽加入手卡，以及将另一只不同名「宝玉兽」怪兽在魔陷区表侧表示放置）
function c9334391.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足检索条件的「宝玉兽」怪兽
	local g1=Duel.SelectMatchingCard(tp,c9334391.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	-- 若成功选择怪兽，则将其加入玩家手卡
	if g1:GetCount()>0 and Duel.SendtoHand(g1,nil,REASON_EFFECT)~=0
		and g1:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方玩家展示加入手卡的怪兽
		Duel.ConfirmCards(1-tp,g1)
		-- 检查魔法与陷阱区域是否还有空位，若无空位则不处理后续放置效果
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 让玩家从卡组选择1只与加入手卡的怪兽卡名不同的「宝玉兽」怪兽
		local g2=Duel.SelectMatchingCard(tp,c9334391.plfilter,tp,LOCATION_DECK,0,1,1,nil,g1:GetFirst():GetCode())
		local tc=g2:GetFirst()
		if tc then
			-- 将选中的怪兽在自己的魔法与陷阱区域表侧表示放置
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 当作永续魔法卡使用
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			tc:RegisterEffect(e1)
		end
	end
end
