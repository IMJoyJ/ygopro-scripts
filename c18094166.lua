--V・HERO ファリス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1只其他的「英雄」怪兽才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「幻影英雄 独善人」以外的1只「幻影英雄」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。这个效果的发动后，直到回合结束时自己不是「英雄」怪兽不能从额外卡组特殊召唤。
function c18094166.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从手卡丢弃1只其他的「英雄」怪兽才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18094166,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,18094166)
	e1:SetCost(c18094166.spcost)
	e1:SetTarget(c18094166.sptg)
	e1:SetOperation(c18094166.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「幻影英雄 独善人」以外的1只「幻影英雄」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。这个效果的发动后，直到回合结束时自己不是「英雄」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18094166,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,18094167)
	e2:SetTarget(c18094166.target)
	e2:SetOperation(c18094166.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- ①效果的代价筛选条件：要求是「英雄」怪兽且可以丢弃，用于从手卡丢弃1只其他的「英雄」怪兽。
function c18094166.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8) and c:IsDiscardable()
end
-- ①效果的代价处理：从手卡丢弃1只满足条件的其他「英雄」怪兽作为发动代价；若满足条件则支付，否则不能发动。
function c18094166.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认手卡中存在至少1只可丢弃的「英雄」怪兽（排除这张卡自身），以满足“丢弃1只其他的「英雄」怪兽”的代价要求。
	if chk==0 then return Duel.IsExistingMatchingCard(c18094166.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际支付代价：从手卡丢弃1只其他「英雄」怪兽，丢弃原因记为代价丢弃。
	Duel.DiscardHand(tp,c18094166.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- ①效果的发动条件检测：自己场上有可用的怪兽区域，且这张卡可以从手卡被特殊召唤；满足条件才可发动。
function c18094166.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己场上是否有空闲的主要怪兽区域，用于从手卡特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记本连锁将进行特殊召唤操作，对象为这张卡自身，方便后续效果连锁的判定（如召唤时点诱发等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：若发动成功且这张卡仍与效果关联（没有离场等），则将其从手卡特殊召唤到自己场上。
function c18094166.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上，特殊召唤成功。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果检索对象的筛选条件：卡名含「幻影英雄」字段的怪兽，不能是禁止卡，也不能是「幻影英雄 独善人」自身。
function c18094166.filter(c)
	return c:IsSetCard(0x5008) and c:IsType(TYPE_MONSTER) and not c:IsForbidden() and not c:IsCode(18094166)
end
-- ②效果的发动条件：确认卡组中存在符合筛选条件的「幻影英雄」怪兽，且自己魔法与陷阱区域有空位。
function c18094166.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组中是否存在至少1只符合条件的「幻影英雄」怪兽（除「幻影英雄 独善人」自身外）。
	if chk==0 then return Duel.IsExistingMatchingCard(c18094166.filter,tp,LOCATION_DECK,0,1,nil)
		-- 同时检测自己魔法与陷阱区域是否有至少1个空位，用于放置从卡组选择的卡。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- ②效果的处理：若魔陷区有空位，则从卡组选择1只符合条件的「幻影英雄」怪兽，以表侧表示放置到自己的魔陷区，并使其变为永续陷阱卡；随后给自己附加本回合不能从额外卡组特殊召唤非「英雄」怪兽的自肃效果。
function c18094166.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认自己魔法与陷阱区域有空位（因为发动后可能变化），没有空位则无法放置。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 向操作玩家发送选卡提示，提示文字为“请选择要放置到场上的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 让玩家从自己的卡组选出1张符合条件的「幻影英雄」怪兽，用于放置到魔陷区。
		local g=Duel.SelectMatchingCard(tp,c18094166.filter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的卡移动到自己的魔法与陷阱区域，以表侧表示放置，并立即使该卡的效果适用。
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 当作永续陷阱卡使用。
			local e1=Effect.CreateEffect(c)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是「英雄」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c18094166.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果作为场地型效果注册到当前玩家：直到回合结束，自己不能从额外卡组特殊召唤非「英雄」怪兽。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃的判定：当要特殊召唤的怪兽不属于「英雄」字段且位于额外卡组时，禁止特殊召唤。
function c18094166.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x8) and c:IsLocation(LOCATION_EXTRA)
end
