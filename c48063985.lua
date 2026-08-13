--聖霊獣騎 カンナホーク
-- 效果：
-- 「灵兽使」怪兽＋「精灵兽」怪兽
-- 把自己场上的上记的卡除外的场合才能特殊召唤。
-- ①：1回合1次，以自己的除外状态的2张「灵兽」卡为对象才能发动。那些卡回到墓地，从卡组把1张「灵兽」卡加入手卡。
-- ②：自己·对方回合，让这张卡回到额外卡组，以自己的除外状态的1只「灵兽使」怪兽和1只「精灵兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
function c48063985.initial_effect(c)
	c:EnableReviveLimit()
	-- 为圣灵兽骑 雷鹰注册融合召唤手续：素材为「灵兽使」怪兽1只与「精灵兽」怪兽1只，使这张卡可以通过融合召唤出场。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10b5),aux.FilterBoolFunction(Card.IsFusionSetCard,0x20b5),true)
	-- 为这张卡注册接触融合特殊召唤手续：将自己场上满足除外代价条件的上述素材怪兽除外（正面表示、作为代价）来进行接触融合特殊召唤，对应“把自己场上的上记的卡除外的场合才能特殊召唤”。
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_MZONE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 把自己场上的上记的卡除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己的除外状态的2张「灵兽」卡为对象才能发动。那些卡回到墓地，从卡组把1张「灵兽」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48063985,0))  --"回收除外的卡并检索"
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c48063985.thtg)
	e3:SetOperation(c48063985.thop)
	c:RegisterEffect(e3)
	-- ②：自己·对方回合，让这张卡回到额外卡组，以自己的除外状态的1只「灵兽使」怪兽和1只「精灵兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(48063985,1))  --"回到额外卡组并特殊召唤除外的怪兽"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c48063985.spcost)
	e4:SetTarget(c48063985.sptg)
	e4:SetOperation(c48063985.spop)
	c:RegisterEffect(e4)
end
-- 定义①的取对象筛选条件：对象必须是表侧表示的「灵兽」卡（包含「灵兽使」和「精灵兽」字段的卡）。
function c48063985.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb5)
end
-- 定义检索筛选条件：从卡组选择1张「灵兽」卡且能够加入手卡。
function c48063985.thfilter(c)
	return c:IsSetCard(0xb5) and c:IsAbleToHand()
end
-- ①的发动条件与取对象合法性判定：确认自己除外区存在至少2张表侧「灵兽」卡可作为对象，且卡组存在至少1张可加入手卡的「灵兽」卡，满足后才能发动。
function c48063985.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c48063985.tgfilter(chkc) end
	-- 发动条件前半：检查自己除外区是否存在至少2张满足tgfilter条件的「灵兽」卡，且它们能成为此效果的对象。
	if chk==0 then return Duel.IsExistingTarget(c48063985.tgfilter,tp,LOCATION_REMOVED,0,2,nil)
		-- 发动条件后半：检查卡组中是否存在至少1张满足thfilter条件的「灵兽」卡可作为检索对象。
		and Duel.IsExistingMatchingCard(c48063985.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示己方发动了该效果，显示效果描述文字，使对方明确当前连锁的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 给己方玩家发送“请选择要送去墓地的卡”的选择提示（用于后续选择除外区的「灵兽」卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让己方玩家从自己除外区选择2张满足tgfilter条件的「灵兽」卡，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c48063985.tgfilter,tp,LOCATION_REMOVED,0,2,2,nil)
	-- 设定操作信息：本效果会把对象组g（2张卡）送去墓地，供其他效果（如星尘龙等）连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,2,0,0)
	-- 设定操作信息：本效果处理后会将1张卡从卡组加入手牌，因具体卡在效果处理时才确定，故targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①的效果处理：将对象「灵兽」卡送回墓地；然后从卡组选1张「灵兽」卡加入手牌，并向对方展示。
function c48063985.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的取对象卡组，并过滤出仍与本次效果有联系的卡（未因离场等导致关系重置）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 把仍关联的对象卡送去墓地，原因包含效果送回（REASON_RETURN），对应“那些卡回到墓地”。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
		-- 给己方玩家发送“请选择要加入手牌的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让己方玩家从卡组选择1张满足thfilter条件的「灵兽」卡。
		local sg=Duel.SelectMatchingCard(tp,c48063985.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 将选择的「灵兽」卡加入其持有者的手牌，原因记为效果。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家展示本次加入手牌的卡，确保对方确认检索结果。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
-- ②的发动代价：检查这张卡能否回到额外卡组，并以其回到额外卡组作为发动代价；对应“让这张卡回到额外卡组”。
function c48063985.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
	-- 实际支付代价：将雷鹰从场上送回额外卡组（REASON_COST），用于发动②。
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_COST)
end
-- 定义「灵兽使」对象怪兽的筛选条件：表侧表示、属于「灵兽使」字段且可被特殊召唤；同时必须还能在除外区找到1只可特召的「精灵兽」怪兽与之配对。
function c48063985.filter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10b5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 在筛选灵兽使时，连带确认除外区还存在至少1只满足filter2的「精灵兽」怪兽，以保证可以同时选出2只对象。
		and Duel.IsExistingTarget(c48063985.filter2,tp,LOCATION_REMOVED,0,1,c,e,tp)
end
-- 定义「精灵兽」对象怪兽的筛选条件：表侧表示、属于「精灵兽」字段且可被特殊召唤为表侧守备表示。
function c48063985.filter2(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x20b5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②的发动条件与取对象判定：检查没有青眼精灵龙限制、场上至少有2个可用怪兽区、且除外区存在可特召的「灵兽使」+「精灵兽」组合；满足后才可发动。
function c48063985.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 发动条件之一：这张卡（雷鹰）离开场上后，自己场上至少要有2个可用怪兽区，才能容纳2只特殊召唤的怪兽。
		and Duel.GetMZoneCount(tp,e:GetHandler())>1
		-- 发动条件之二：己方除外区存在至少1只满足filter1的「灵兽使」怪兽（filter1内部已连带确认有对应的「精灵兽」）。
		and Duel.IsExistingTarget(c48063985.filter1,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向对方玩家提示己方发动了②效果，显示效果描述文字。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 给己方玩家发送“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让己方玩家从除外区选择1只满足filter1的「灵兽使」怪兽，并登记为对象。
	local g1=Duel.SelectTarget(tp,c48063985.filter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 再次发送“请选择要特殊召唤的卡”的选择提示，用于选择第二张对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让己方玩家从除外区选择1只满足filter2的「精灵兽」怪兽，并排除刚才已选的灵兽使；随后将两组对象合并为对象组。
	local g2=Duel.SelectTarget(tp,c48063985.filter2,tp,LOCATION_REMOVED,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	-- 设定操作信息：本效果处理时会将对象组g1中的2只怪兽进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- ②的效果处理：根据可用怪兽区数量，将对象怪兽尽可能以表侧守备表示特殊召唤；如果因格子不足无法全部特召，则选择可特召的部分，其余规则送去墓地。
function c48063985.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得己方当前可用怪兽区数量，用于判断能否同时特殊召唤2只怪兽。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 取得当前连锁的对象卡组，并过滤出仍与效果有联系的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	if g:GetCount()<=ft then
		-- 若可用格子足够，将对象怪兽全部以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	else
		-- 当可用格子不足时，给己方玩家发送“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将玩家选出的部分对象怪兽以表侧守备表示特殊召唤。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		g:Sub(sg)
		-- 因场上没有可用怪兽区而无法特殊召唤的剩余对象卡，根据规则送去墓地。
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
