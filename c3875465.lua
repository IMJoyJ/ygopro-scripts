--家電機塊世界エレクトリリカル・ワールド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把场地魔法卡以外的1张「机块」卡加入手卡。
-- ②：1回合1次，自己对「机块」连接怪兽的连接召唤成功的场合才能发动。从自己墓地选1只「机块」怪兽加入手卡。
-- ③：1回合1次，自己或者对方的怪兽的攻击宣言时才能发动。选自己场上1只「机块」怪兽，那个位置向其他的自己的主要怪兽区域移动。
function c3875465.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把场地魔法卡以外的1张「机块」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,3875465+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c3875465.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己对「机块」连接怪兽的连接召唤成功的场合才能发动。从自己墓地选1只「机块」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3875465,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c3875465.thcon)
	e2:SetTarget(c3875465.thtg)
	e2:SetOperation(c3875465.thop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己或者对方的怪兽的攻击宣言时才能发动。选自己场上1只「机块」怪兽，那个位置向其他的自己的主要怪兽区域移动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3875465,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c3875465.mvtg)
	e3:SetOperation(c3875465.mvop)
	c:RegisterEffect(e3)
end
-- 定义①效果检索用的过滤条件：从自己卡组中筛选出不是场地魔法卡、属于「机块」系列且能够加入手卡的卡。
function c3875465.thfilter1(c)
	return not c:IsType(TYPE_FIELD) and c:IsSetCard(0x14b) and c:IsAbleToHand()
end
-- ①效果的发动时的效果处理：若自己卡组存在符合条件的「机块」卡且玩家选择发动检索，则从卡组选1张「机块」卡加入手卡，并让对方确认。
function c3875465.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足 thfilter1（非场地魔法卡、属于「机块」、能加入手卡）的卡，作为可选择的检索候选集合。
	local g=Duel.GetMatchingGroup(c3875465.thfilter1,tp,LOCATION_DECK,0,nil)
	-- 若候选集合不为空，并且玩家在弹出的是否检索提示中选择了“是”，则执行后续检索处理。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(3875465,0)) then  --"是否从卡组把「机块」卡加入手卡？"
		-- 向玩家显示“请选择要加入手牌的卡”的选择提示（HINT_SELECTMSG），准备选择卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将玩家选择的1张「机块」卡以效果原因（REASON_EFFECT）送入其持有者手卡，即完成加入手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对手确认刚刚加入手卡的那张卡（公开信息给对方）。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 定义②效果的触发条件过滤函数：特殊召唤成功的怪兽需为表侧表示、属于「机块」系列、以连接召唤方式召唤、且召唤玩家是自己。
function c3875465.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x14b) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsSummonPlayer(tp)
end
-- ②效果的发动条件：本次特殊召唤成功的事件组（eg）中存在至少1只满足 cfilter 的自己连接召唤的「机块」连接怪兽。
function c3875465.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c3875465.cfilter,1,nil,tp)
end
-- 定义②效果从墓地加入手卡的过滤条件：属于「机块」系列且为怪兽卡，并且能够被加入手卡。
function c3875465.thfilter2(c)
	return c:IsSetCard(0x14b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动时点判定与操作信息设置：确认自己墓地存在至少1只符合条件的「机块」怪兽，并设置本次效果将1只怪兽从墓地加入手卡。
function c3875465.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法检测（chk==0）：确认自己墓地存在至少1只满足 thfilter2 的「机块」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c3875465.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置效果操作信息：本次效果是回手牌效果，目标是从自己墓地取1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：从自己墓地选择1只符合条件的「机块」怪兽加入手卡；选择时应用王家长眠之谷过滤器，排除受其影响的卡。
function c3875465.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要加入手牌的卡”的提示，准备选择墓地怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地中筛选出满足 thfilter2 且不受王家长眠之谷影响的「机块」怪兽，并让玩家选择其中1张作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c3875465.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的墓地「机块」怪兽以效果原因送入其持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 定义③效果可移动的怪兽条件：自己场上表侧表示的「机块」怪兽。
function c3875465.mvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x14b)
end
-- ③效果的发动条件：自己场上存在表侧表示的「机块」怪兽，且自己的主要怪兽区域存在可用的空位用于移动。
function c3875465.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否存在至少1只表侧表示的「机块」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c3875465.mvfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己的主要怪兽区域是否有空位（作为移动目标位置），若没有可用空位则条件不成立。
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
end
-- ③效果处理：选择自己场上1只表侧表示的「机块」怪兽，再选择自己主要怪兽区域中的1个空位，将该怪兽移动到那个位置。
function c3875465.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次确认自己主要怪兽区域有空位，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	-- 提示玩家选择要移动位置的怪兽（HINT_SELECTMSG）。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(3875465,3))  --"请选择要移动位置的怪兽"
	-- 从自己主要怪兽区域选择1只符合条件的表侧表示「机块」怪兽作为移动对象。
	local g=Duel.SelectMatchingCard(tp,c3875465.mvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要移动到的位置（HINTMSG_TOZONE）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
		-- 从自己的主要怪兽区域中选择1个可用的空位（由玩家点击选择），返回其位置标记（位运算表示的格子）。
		local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		local nseq=math.log(s,2)
		-- 将选中的「机块」怪兽移动到目标主要怪兽区域位置（移动格子）。
		Duel.MoveSequence(g:GetFirst(),nseq)
	end
end
