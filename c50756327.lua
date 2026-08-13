--魔導原典 クロウリー
-- 效果：
-- 魔法师族怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把「魔导书」卡3种类给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩下的卡回到卡组。
-- ②：只要这张卡在怪兽区域存在，自己在5星以上的魔法师族怪兽召唤的场合需要的解放可以不用。这个效果1回合只能适用1次。
function c50756327.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加连接召唤手续：使用2只魔法师族连接怪兽作为连接素材（代码通过IsLinkRace过滤，实际限定素材为魔法师族连接怪兽）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_SPELLCASTER),2,2)
	-- ①：这张卡连接召唤成功的场合才能发动。从卡组把「魔导书」卡3种类给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩下的卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50756327,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,50756327)
	e1:SetCondition(c50756327.thcon)
	e1:SetTarget(c50756327.thtg)
	e1:SetOperation(c50756327.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己在5星以上的魔法师族怪兽召唤的场合需要的解放可以不用。这个效果1回合只能适用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50756327,1))  --"不用解放召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCountLimit(1)
	e2:SetCondition(c50756327.ntcon)
	e2:SetTarget(c50756327.nttg)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：这张卡以连接召唤方式特殊召唤成功时才满足。
function c50756327.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 筛选条件：卡名属于「魔导书」系列，并且可以被加入手卡。
function c50756327.thfilter(c)
	return c:IsSetCard(0x106e) and c:IsAbleToHand()
end
-- 发动时检查卡组中是否存在至少3种类不同的「魔导书」卡，并设置本次效果将要把1张卡从卡组加入手卡的操作信息。
function c50756327.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 从卡组中取得所有满足「魔导书」且可加入手卡的卡，用于后续种类数判定。
		local dg=Duel.GetMatchingGroup(c50756327.thfilter,tp,LOCATION_DECK,0,nil)
		return dg:GetClassCount(Card.GetCode)>=3
	end
	-- 设置操作信息：本次效果会从卡组将1张卡加入手卡（用于连锁检测和效果提示）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行①效果处理：从符合条件的「魔导书」卡中选出3种类给对方确认，对方随机选1张加入手卡，之后洗切卡组（剩余卡留在卡组）。
function c50756327.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理阶段重新从卡组取得所有符合条件的「魔导书」卡，作为本次选择的候选集合。
	local g=Duel.GetMatchingGroup(c50756327.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 then
		-- 向操作者显示选择提示，要求其选出要展示给对方确认的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从候选卡中选出3张卡名互不相同的「魔导书」卡（即3种类），展示给对方。
		local sg1=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
		-- 将选出的3张「魔导书」卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg1)
		local cg=sg1:RandomSelect(1-tp,1)
		local tc=cg:GetFirst()
		tc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方随机选中的那张卡加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 洗切卡组，对应效果中“剩下的卡回到卡组”的卡组洗切处理。
		Duel.ShuffleDeck(tp)
	end
end
-- 定义②效果的召唤手续条件：若未指定具体怪兽则视为可适用；指定怪兽时，要求本次召唤为不需解放的召唤且己方主要怪兽区有空位。
function c50756327.ntcon(e,c,minc)
	if c==nil then return true end
	-- 返回是否满足“无解放召唤且场上主要怪兽区有空位”的适用条件。
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 规定②效果适用的召唤对象：等级5以上且种族为魔法师族的怪兽。
function c50756327.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_SPELLCASTER)
end
