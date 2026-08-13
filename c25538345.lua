--幻影騎士団ティアースケイル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡才能发动。除「幻影骑士团 破洞鳞甲」外的1只「幻影骑士团」怪兽或1张「幻影」魔法·陷阱卡从卡组送去墓地。
-- ②：这张卡在墓地存在，从自己墓地有其他的「幻影骑士团」怪兽或「幻影」魔法·陷阱卡被除外的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c25538345.initial_effect(c)
	-- ①效果：丢弃1张手卡才能发动。除「幻影骑士团 破洞鳞甲」外的1只「幻影骑士团」怪兽或1张「幻影」魔法·陷阱卡从卡组送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25538345,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,25538345)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c25538345.sgcost)
	e1:SetTarget(c25538345.sgtg)
	e1:SetOperation(c25538345.sgop)
	c:RegisterEffect(e1)
	-- ②效果：这张卡在墓地存在，从自己墓地有其他的「幻影骑士团」怪兽或「幻影」魔法·陷阱卡被除外的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25538345,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,25538346)
	e2:SetCondition(c25538345.sscon)
	e2:SetTarget(c25538345.sstg)
	e2:SetOperation(c25538345.ssop)
	c:RegisterEffect(e2)
end
-- ①效果的代价：丢弃1张手卡。chk==0时检查手牌是否有可丢弃的卡，满足则执行丢弃1张手卡作为发动代价。
function c25538345.sgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则检查：确认自己手牌中存在至少1张可以丢弃的卡，用于判断能否支付①效果的代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：从手牌选择1张可以丢弃的卡丢弃，丢弃原因为代价（REASON_COST+REASON_DISCARD）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义检索/送去墓地的筛选条件：卡名不是「幻影骑士团 破洞鳞甲」自身，且满足以下任一：①「幻影骑士团」怪兽；②「幻影」魔法·陷阱卡，并且该卡可以被送去墓地。
function c25538345.filter(c)
	return not c:IsCode(25538345) and ((c:IsSetCard(0x10db) and c:IsType(TYPE_MONSTER)) or (c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP)))
		and c:IsAbleToGrave()
end
-- ①效果的发动目标与操作信息设定：若卡组存在符合条件的卡即可发动，并预登记“从卡组把1张卡送去墓地”的操作信息。
function c25538345.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 规则检查：卡组中是否存在至少1张满足c25538345.filter条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c25538345.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果处理将把1张卡送去墓地，目标范围为对方/自己的卡组（tp的卡组），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：由玩家从卡组选择1张符合条件的卡，将其送去墓地。
function c25538345.sgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要送去墓地的卡”的提示信息，用于选择卡片的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中选择1张满足c25538345.filter条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c25538345.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义②触发条件的筛选：被除外的卡必须是从持有者tp的墓地离开（即之前位于墓地且控制权属于tp），并且是「幻影骑士团」怪兽或「幻影」魔法·陷阱卡（不包含本卡自己除外的情况，因为后续sscon要求至少1张其他卡）。
function c25538345.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
		and ((c:IsSetCard(0x10db) and c:IsType(TYPE_MONSTER)) or (c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP)))
end
-- ②效果的发动条件：本次除外事件中存在至少1张从自己墓地离开的符合条件的「幻影骑士团」怪兽或「幻影」魔法·陷阱卡。
function c25538345.sscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c25538345.cfilter,1,nil,tp)
end
-- ②效果的发动目标条件：自己主要怪兽区有空位，且墓地中的这张卡能够被特殊召唤。
function c25538345.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则检查：主要怪兽区是否存在至少1个空位，用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次效果处理将把这张卡特殊召唤，对象为本卡的持有者/控制者的怪兽区。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：将墓地的这张卡特殊召唤；若成功，给它附加“离场时除外”的永续效果。
function c25538345.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联且特殊召唤成功后才附加离场除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- ②效果中“这个效果特殊召唤的这张卡从场上离开的场合除外”：为这张卡设置离场时不去墓地而是除外的不被无效的永续效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
