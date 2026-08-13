--ARG☆S－GiantKilling
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把1只「阿尔戈☆群星」怪兽加入手卡。自己的怪兽区域有永续陷阱卡存在的场合或者持有把自身作为怪兽特殊召唤效果的永续陷阱卡在自己的魔法与陷阱区域存在的场合，可以再进行1只战士族怪兽的召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以包含自己场上的「阿尔戈☆群星」永续陷阱卡的场上2张卡为对象才能发动。那些卡回到手卡。
local s,id,o=GetID()
-- 注册该卡的①②两个效果：e1为速攻魔法效果的检索并可能追加召唤，e2为墓地除外自身、取对象回手的起动效果；并共享同名卡1回合1次的次数限制。
function s.initial_effect(c)
	-- ①：从卡组把1只「阿尔戈☆群星」怪兽加入手卡。自己的怪兽区域有永续陷阱卡存在的场合或者持有把自身作为怪兽特殊召唤效果的永续陷阱卡在自己的魔法与陷阱区域存在的场合，可以再进行1只战士族怪兽的召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH|CATEGORY_TOHAND|CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以包含自己场上的「阿尔戈☆群星」永续陷阱卡的场上2张卡为对象才能发动。那些卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	-- 设置效果②的发动代价为把墓地中的这张卡除外（使用辅助函数aux.bfgcost将自身除外作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg1)
	e2:SetOperation(s.thop1)
	c:RegisterEffect(e2)
end
-- 定义检索过滤函数：卡组中「阿尔戈☆群星」怪兽且可以被加入手卡的卡。
function s.thfilter(c)
	return c:IsSetCard(0x1c1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动条件与处理信息设置：检查卡组是否存在可检索对象，并设置本次操作为从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）判断卡组中是否存在至少1张满足s.thfilter的「阿尔戈☆群星」怪兽，作为是否允许发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将从卡组把1张卡加入手卡（目标数量为1，位置为卡组），供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义追加召唤的过滤函数：可用于无祭品通常召唤（IsSummonable(true,nil)）且种族为战士族的怪兽。
function s.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsRace(RACE_WARRIOR)
end
-- 定义追加召唤条件的检测函数：存在表侧表示的永续陷阱卡；该卡如果在怪兽区域则直接满足，如果在魔陷区域则还需是持有把自身特殊召唤为怪兽效果的永续陷阱卡，且具备怪兽基本特征（等级/种族/属性/攻守任一）。
function s.chkfilter(c)
	return c:IsAllTypes(TYPE_CONTINUOUS|TYPE_TRAP) and c:IsFaceup() and
		(c:IsLocation(LOCATION_MZONE) or
			-- 检查该永续陷阱卡的效果中是否包含特殊召唤类别（CATEGORY_SPECIAL_SUMMON），用于判断是否为“持有把自身作为怪兽特殊召唤效果的永续陷阱卡”。
			c:IsEffectProperty(aux.EffectCategoryFilter(CATEGORY_SPECIAL_SUMMON)) and
			(c:GetOriginalLevel()>0
			or bit.band(c:GetOriginalRace(),0x3fffffff)~=0
			or bit.band(c:GetOriginalAttribute(),0x7f)~=0
			or c:GetBaseAttack()>0
			or c:GetBaseDefense()>0))
end
-- 效果①处理：从卡组将1只「阿尔戈☆群星」怪兽加入手卡并给对方确认；若场上满足追加召唤条件且玩家选择是，则额外进行1只战士族怪兽的通常召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示，将提示消息写入选择缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组选择1张满足s.thfilter条件的「阿尔戈☆群星」怪兽作为检索对象。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，原因记为效果处理（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的检索卡，确认检索内容。
		Duel.ConfirmCards(1-tp,g)
		-- 判断手牌或主要怪兽区域是否存在至少1只可以通常召唤的战士族怪兽，作为能否进行追加召唤的候选。
		if Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
			-- 判断我方场上（怪兽区域或魔陷区域）是否存在至少1张满足s.chkfilter的永续陷阱卡，即满足追加召唤的前置条件。
			and Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_MZONE+LOCATION_SZONE,0,1,nil)
			-- 向玩家询问是否进行追加召唤（使用Stringid(id,2)的提示文本），等待玩家选择是或否。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否进行召唤？"
			-- 显示“请选择要召唤的卡”的选择提示，让玩家选择要追加召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 从手牌和主要怪兽区域中选择1只满足s.sumfilter的战士族怪兽作为追加召唤的对象。
			local sg=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
			-- 洗切手牌，因选择过程中可能改变了手牌顺序或查看过手牌，需要重置洗牌检测状态。
			Duel.ShuffleHand(tp)
			if sg:GetCount()>0 then
				-- 中断当前效果处理，使后续的召唤不视为与检索同时处理，避免卡时点，保证召唤成功时的时点能正确触发。
				Duel.BreakEffect()
				-- 将选中的战士族怪兽进行追加通常召唤：ignore_count=true表示忽略每回合通常召唤次数限制，e=nil表示按一般通常召唤规则处理。
				Duel.Summon(tp,sg:GetFirst(),true,nil)
			end
		end
	end
end
-- 定义效果②的对象过滤函数：场上可回手且能被当前效果选择为对象的卡。
function s.filter(c,e)
	return c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 定义“自己场上的『阿尔戈☆群星』永续陷阱卡”的判断函数：该卡的控制者是自己、表侧表示、永续陷阱类型且卡名属于「阿尔戈☆群星」。
function s.thfilters(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsAllTypes(TYPE_CONTINUOUS|TYPE_TRAP) and c:IsSetCard(0x1c1)
end
-- 定义子组选择校验函数：在选出的2张卡中，至少有1张是自己场上的「阿尔戈☆群星」永续陷阱卡。
function s.sgselect(g,tp)
	return g:IsExists(s.thfilters,1,nil,tp)
end
-- 效果②的发动条件、对象选择及操作信息设置：从全场选择包含自己场上「阿尔戈☆群星」永续陷阱卡在内的2张卡为对象，并设定为回到手卡。
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 取得场上所有满足s.filter（可回手且可成为效果对象）的卡，作为可选对象的集合。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.sgselect,2,2,tp) end
	-- 显示“请选择要返回手牌的卡”的选择提示，让玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:SelectSubGroup(tp,s.sgselect,false,2,2,tp)
	-- 将最终选择的2张卡设置为当前连锁的取对象目标，使它们与效果建立联系，结算时可以通过该联系获取。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：将所选2张卡作为本次效果确定返回手牌的卡，数量为2，位置为场上，为效果处理提供依据。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,0,0)
end
-- 效果②结算：获取与当前连锁相关的目标卡，将它们送回持有者手牌。
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡（即发动时选择的目标卡），用于后续回手处理。
	local g=Duel.GetTargetsRelateToChain()
	if #g>0 then
		-- 将取回的目标卡加入其持有者的手牌，原因记为效果处理（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
