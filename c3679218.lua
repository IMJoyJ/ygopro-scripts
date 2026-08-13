--トロイメア・マーメイド
-- 效果：
-- 「梦幻崩影·人鱼」以外的「幻崩」怪兽1只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合，丢弃1张手卡才能发动。从卡组把1只「幻崩」怪兽特殊召唤。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以从卡组抽1张。
-- ②：只要这张卡在怪兽区域存在，场上的不在互相连接状态的怪兽的攻击力·守备力下降1000。
function c3679218.initial_effect(c)
	-- 为这张卡添加连接召唤手续：以1只满足matfilter条件的怪兽作为连接素材（即「梦幻崩影·人鱼」以外的「幻崩」怪兽1只）。
	aux.AddLinkProcedure(c,c3679218.matfilter,1,1)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡连接召唤成功的场合，丢弃1张手卡才能发动。从卡组把1只「幻崩」怪兽特殊召唤。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3679218,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,3679218)
	e1:SetCondition(c3679218.spcon)
	e1:SetCost(c3679218.spcost)
	e1:SetTarget(c3679218.sptg)
	e1:SetOperation(c3679218.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，场上的不在互相连接状态的怪兽的攻击力·守备力下降1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c3679218.atktg)
	e2:SetValue(-1000)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 连接素材过滤条件：素材怪兽必须是可作为连接素材时带有「幻崩」字段（IsLinkSetCard(0x112)），且不是卡号3679218的「梦幻崩影·人鱼」自身，即「梦幻崩影·人鱼」以外的「幻崩」怪兽1只。
function c3679218.matfilter(c)
	return c:IsLinkSetCard(0x112) and not c:IsLinkCode(3679218)
end
-- ①效果的发动条件：这张卡以连接召唤方式召唤成功的场合才能发动。
function c3679218.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果的发动代价：丢弃1张手卡。该函数先检查能否支付，再执行丢弃1张手卡，丢弃理由为代价和丢弃。
function c3679218.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk==0）确认手牌中存在至少1张可以丢弃的卡，以保证可以支付丢弃1张手卡的代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：从手牌选择并丢弃1张可以丢弃的卡，丢弃原因为REASON_COST+REASON_DISCARD（作为代价丢弃）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤的筛选条件：从卡组选择的怪兽必须是「幻崩」怪兽，且能够被玩家tp用当前效果e特殊召唤（满足苏生限制和召唤条件）。
function c3679218.spfilter(c,e,tp)
	return c:IsSetCard(0x112) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动目标检查：自己主要怪兽区域有空位，且卡组中存在至少1只满足spfilter的「幻崩」怪兽，才能发动。
function c3679218.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标检查阶段（chk==0）确认自己场上主要怪兽区有可用空格，以保证特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在目标检查阶段同时确认卡组中存在至少1只符合条件的「幻崩」怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(c3679218.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：声明本效果包含特殊召唤操作，对象为卡组中的1只怪兽（具体卡片在效果处理时选择），用于给其他卡（如星尘龙等）提供效果发动的检测信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	if e:GetHandler():GetMutualLinkedGroupCount()>0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetLabel(0)
	end
end
-- ①效果处理：若自己主要怪兽区仍有空位，则选择卡组中1只符合条件的「幻崩」怪兽特殊召唤；若发动时这张卡处于互相连接状态，且玩家选择抽卡，则再洗切卡组并抽1张。
function c3679218.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区存在空位，若没有空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1张满足spfilter的「幻崩」怪兽（选择结果存入g）。
	local g=Duel.SelectMatchingCard(tp,c3679218.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若选择到了怪兽且特殊召唤成功（返回实际召唤数量不为0），则继续判断是否追加抽卡。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 追加抽卡的条件判断：在目标设定时已标记（e:GetLabel()==1）为发动时这张卡处于互相连接状态，且玩家允许抽1张卡。
		and e:GetLabel()==1 and Duel.IsPlayerCanDraw(tp,1)
		-- 向玩家询问“是否抽卡？”，若同意则继续执行抽卡处理。
		and Duel.SelectYesNo(tp,aux.Stringid(3679218,1)) then  --"是否抽卡？"
		-- 中断当前效果链，使后续抽卡处理与之前的特殊召唤视为不同时处理，避免引起错误的时点。
		Duel.BreakEffect()
		-- 洗切玩家的卡组，确保卡组顺序随机后再进行抽卡。
		Duel.ShuffleDeck(tp)
		-- 玩家以效果原因抽1张卡，完成追加抽卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- ②效果的适用对象筛选：返回true表示该怪兽不处于互相连接状态（互相连接数为0），应对其应用攻击力·守备力下降效果；此函数同时用于攻击力下降（e2）和守备力下降（e3克隆）的目标判定。
function c3679218.atktg(e,c)
	return c:GetMutualLinkedGroupCount()==0
end
