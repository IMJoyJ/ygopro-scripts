--翼の魔妖－波旬
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「翼之魔妖-波旬」以外的1只「魔妖」怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
function c41729254.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「翼之魔妖-波旬」以外的1只「魔妖」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41729254,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,41729254)
	e1:SetTarget(c41729254.sptg)
	e1:SetOperation(c41729254.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c41729254.sslimit)
	c:RegisterEffect(e3)
end
-- 过滤函数：作为本次特殊召唤的候选，要求是「魔妖」怪兽、卡名不是「翼之魔妖-波旬」本身，并且能够被当前效果特殊召唤（满足苏生限制与召唤条件）。
function c41729254.filter(c,e,tp)
	return c:IsSetCard(0x121) and not c:IsCode(41729254) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：仅在效果发动时（chk==0）检查自己主要怪兽区是否仍有空位、卡组是否存在满足过滤条件的「魔妖」怪兽，满足才可发动。
function c41729254.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上主要怪兽区域是否还有可用的空格（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中是否存在至少1张满足c41729254.filter条件的「魔妖」怪兽（即「翼之魔妖-波旬」以外的可特殊召唤的「魔妖」）。
		and Duel.IsExistingMatchingCard(c41729254.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次连锁的特殊召唤操作信息登记为：从持有者卡组把1只怪兽特殊召唤，用于后续效果检测与连锁处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：若此时自己主要怪兽区有空位，则从卡组选择1张满足条件的「魔妖」怪兽，以表侧表示特殊召唤到自己场上。
function c41729254.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区仍有空位，若已无空位则效果不处理，直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求玩家从符合条件的怪兽中选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选出1张满足c41729254.filter条件的「魔妖」怪兽（不是本卡），作为特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c41729254.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示（正面攻击表示）特殊召唤到发动者自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的判定函数：若被特殊召唤的怪兽来自额外卡组且不是「魔妖」怪兽，则该特殊召唤被禁止（以此限制自肃）。
function c41729254.sslimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x121)
end
