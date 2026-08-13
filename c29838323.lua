--水晶機巧－シストバーン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1只「水晶机巧」调整特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族同调怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从卡组把「水晶机巧-紫晶龙」以外的1只「水晶机巧」怪兽加入手卡。
function c29838323.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1只「水晶机巧」调整特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29838323,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,29838323)
	e1:SetTarget(c29838323.sptg)
	e1:SetOperation(c29838323.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把「水晶机巧-紫晶龙」以外的1只「水晶机巧」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29838323,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,29838323)
	-- 设置②效果的发动代价：把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c29838323.thtg)
	e2:SetOperation(c29838323.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：用于选择①效果的对象，要求卡为表侧表示。
function c29838323.desfilter(c)
	return c:IsFaceup()
end
-- 过滤函数：用于选择卡组中的「水晶机巧」调整，要求属于「水晶机巧」系列、是调整怪兽且满足特殊召唤条件。
function c29838323.spfilter(c,e,tp)
	return c:IsSetCard(0xea) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定与目标选择：根据主要怪兽区空位决定可破坏对象所在区域，需存在1张表侧表示的卡可破坏且卡组有可特殊召唤的「水晶机巧」调整；满足后选择破坏对象并设置破坏与特殊召唤的操作信息。
function c29838323.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(e:GetLabel()) and chkc:IsControler(tp) and c29838323.desfilter(chkc) end
	if chk==0 then
		-- 获取自己主要怪兽区的可用空位数量，用于判断特殊召唤时是否需要调整可选区域（若无空位则只能选择怪兽区的卡破坏以腾出区域）。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<-1 then return false end
		local loc=LOCATION_ONFIELD
		if ft==0 then loc=LOCATION_MZONE end
		e:SetLabel(loc)
		-- 检查自己场上（按空位情况可能是全场或仅主要怪兽区）是否存在1张表侧表示的卡作为破坏对象。
		return Duel.IsExistingTarget(c29838323.desfilter,tp,loc,0,1,nil)
			-- 同时确认卡组中存在1只可特殊召唤的「水晶机巧」调整怪兽，以满足①效果的发动条件。
			and Duel.IsExistingMatchingCard(c29838323.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 向当前玩家发送“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从符合条件的位置选择1张表侧表示的自身卡作为破坏对象，并将该卡登记为效果对象。
	local g=Duel.SelectTarget(tp,c29838323.desfilter,tp,e:GetLabel(),0,1,1,nil)
	-- 设置破坏的操作信息：本次效果将破坏1张已选择的对象卡，用于连锁处理判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置特殊召唤的操作信息：本次效果将从卡组特殊召唤1只怪兽（具体目标在处理时选择），用于连锁处理判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：先取对象，若对象仍关联且已被效果破坏，且自己主要怪兽区有空位，则从卡组特殊召唤1只「水晶机巧」调整；最后适用自肃效果，直到回合结束前自己不能从额外卡组特殊召唤非机械族同调怪兽。
function c29838323.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡仍与效果关联、已因效果破坏成功，且自己主要怪兽区仍有空位，满足这些条件才继续特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向当前玩家发送“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的「水晶机巧」调整怪兽作为特殊召唤的对象。
		local g=Duel.SelectMatchingCard(tp,c29838323.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是机械族同调怪兽不能从额外卡组特殊召唤。②：把墓地的这张卡除外才能发动。从卡组把「水晶机巧-紫晶龙」以外的1只「水晶机巧」怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c29838323.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述自肃效果注册为场地效果，并指定影响当前玩家，持续到这回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的限制条件：从额外卡组只能特殊召唤机械族同调怪兽，其他额外卡组怪兽不能特殊召唤。
function c29838323.splimit(e,c)
	return not (c:IsRace(RACE_MACHINE) and c:IsType(TYPE_SYNCHRO)) and c:IsLocation(LOCATION_EXTRA)
end
-- 检索过滤条件：用于从卡组选择「水晶机巧-紫晶龙」以外的「水晶机巧」怪兽，且该卡可以加入手牌。
function c29838323.thfilter(c)
	return c:IsSetCard(0xea) and c:IsType(TYPE_MONSTER) and not c:IsCode(29838323) and c:IsAbleToHand()
end
-- ②效果的发动条件判定：卡组中存在满足检索条件的「水晶机巧」怪兽；并设置从卡组将1张卡加入手牌的操作信息。
function c29838323.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认卡组中是否有至少1只满足条件的「水晶机巧」怪兽，没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c29838323.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将从卡组把1张卡加入手牌，用于连锁处理判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组选择1只符合条件的「水晶机巧」怪兽加入手牌，并向对方展示加入的卡片。
function c29838323.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家发送“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的「水晶机巧」怪兽作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,c29838323.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示这次加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
