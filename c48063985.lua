--聖霊獣騎 カンナホーク
-- 效果：
-- 「灵兽使」怪兽＋「精灵兽」怪兽
-- 把自己场上的上记的卡除外的场合才能特殊召唤。
-- ①：1回合1次，以自己的除外状态的2张「灵兽」卡为对象才能发动。那些卡回到墓地，从卡组把1张「灵兽」卡加入手卡。
-- ②：自己·对方回合，让这张卡回到额外卡组，以自己的除外状态的1只「灵兽使」怪兽和1只「精灵兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
function c48063985.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足「灵兽使」和「精灵兽」种族的怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10b5),aux.FilterBoolFunction(Card.IsFusionSetCard,0x20b5),true)
	-- 添加接触融合特殊召唤规则，需要将自己场上的怪兽除外作为召唤代价
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_MZONE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- ①：1回合1次，以自己的除外状态的2张「灵兽」卡为对象才能发动。那些卡回到墓地，从卡组把1张「灵兽」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，让这张卡回到额外卡组，以自己的除外状态的1只「灵兽使」怪兽和1只「精灵兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
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
	-- 将自身送去卡组作为cost，用于效果②的发动
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
-- 过滤器函数：判断目标是否为正面表示且属于「灵兽」种族
function c48063985.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb5)
end
-- 过滤器函数：判断目标是否为「灵兽」种族且能加入手牌
function c48063985.thfilter(c)
	return c:IsSetCard(0xb5) and c:IsAbleToHand()
end
-- 检查效果①的发动条件：确认场上是否存在2张除外状态的「灵兽」卡和1张可加入手牌的「灵兽」卡
function c48063985.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c48063985.tgfilter(chkc) end
	-- 检查效果①的发动条件：确认场上是否存在2张除外状态的「灵兽」卡
	if chk==0 then return Duel.IsExistingTarget(c48063985.tgfilter,tp,LOCATION_REMOVED,0,2,nil)
		-- 检查效果①的发动条件：确认场上是否存在1张可加入手牌的「灵兽」卡
		and Duel.IsExistingMatchingCard(c48063985.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方提示该效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择2张除外状态的「灵兽」卡作为对象
	local g=Duel.SelectTarget(tp,c48063985.tgfilter,tp,LOCATION_REMOVED,0,2,2,nil)
	-- 设置操作信息，指定将2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,2,0,0)
	-- 设置操作信息，指定从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数：将选中的卡送去墓地并从卡组检索1张卡加入手牌
function c48063985.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的目标卡组，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将目标卡组送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张「灵兽」卡加入手牌
		local sg=Duel.SelectMatchingCard(tp,c48063985.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
-- 效果②的发动费用处理函数：将自身送去卡组作为召唤代价
function c48063985.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
	-- 将自身送去卡组作为召唤代价
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_COST)
end
-- 过滤器函数：判断目标是否为正面表示且属于「灵兽使」种族并能特殊召唤
function c48063985.filter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10b5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查是否存在满足条件的「精灵兽」怪兽作为对象
		and Duel.IsExistingTarget(c48063985.filter2,tp,LOCATION_REMOVED,0,1,c,e,tp)
end
-- 过滤器函数：判断目标是否为正面表示且属于「精灵兽」种族并能特殊召唤
function c48063985.filter2(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x20b5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 检查效果②的发动条件：确认未受青眼精灵龙影响、场上存在足够怪兽区、且存在满足条件的「灵兽使」怪兽作为对象
function c48063985.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查效果②的发动条件：确认场上存在至少1个可用怪兽区
		and Duel.GetMZoneCount(tp,e:GetHandler())>1
		-- 检查效果②的发动条件：确认存在满足条件的「灵兽使」怪兽作为对象
		and Duel.IsExistingTarget(c48063985.filter1,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向对方提示该效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只除外状态的「灵兽使」怪兽作为对象
	local g1=Duel.SelectTarget(tp,c48063985.filter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只除外状态的「精灵兽」怪兽作为对象
	local g2=Duel.SelectTarget(tp,c48063985.filter2,tp,LOCATION_REMOVED,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	-- 设置操作信息，指定将2只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 效果②的处理函数：将选中的2只怪兽特殊召唤
function c48063985.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取连锁中被选择的目标卡组，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	if g:GetCount()<=ft then
		-- 将目标卡组特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	else
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将选中的卡特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		g:Sub(sg)
		-- 将剩余卡送去墓地
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
