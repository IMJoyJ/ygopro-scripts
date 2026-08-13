--幻奏の歌姫ソロ
-- 效果：
-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡被战斗破坏送去墓地时才能发动。从卡组把「幻奏的歌姬 索萝」以外的1只「幻奏」怪兽特殊召唤。
function c14763299.initial_effect(c)
	-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c14763299.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏送去墓地时才能发动。从卡组把「幻奏的歌姬 索萝」以外的1只「幻奏」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14763299,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c14763299.condition)
	e2:SetTarget(c14763299.target)
	e2:SetOperation(c14763299.operation)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件函数：若参数c为nil则返回true（表示该卡可作为特殊召唤手续）；否则要求这张卡的持有者自己场上没有怪兽、对方场上有怪兽且自己主要怪兽区有空位。
function c14763299.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡持有者自己的主要怪兽区没有怪兽。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查这张卡持有者的对方场上存在怪兽。
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查这张卡持有者自己场上有可用的主要怪兽区空格，以放置特殊召唤的这张卡。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- ②效果的发动条件：这张卡在墓地存在，满足“被战斗破坏送去墓地时”的时点。
function c14763299.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 定义特殊召唤对象的筛选条件：是「幻奏」怪兽、不是「幻奏的歌姬 索萝」自身、并且可以被特殊召唤。
function c14763299.filter(c,e,tp)
	return c:IsSetCard(0x9b) and not c:IsCode(14763299) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标判定：满足自己场上有空位且卡组中存在符合条件的「幻奏」怪兽时，效果可以发动。
function c14763299.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动条件检查（chk==0）时，确认自己主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动条件检查时，确认自己卡组中存在至少1张满足过滤条件的「幻奏」怪兽（不取对象）。
		and Duel.IsExistingMatchingCard(c14763299.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：该效果包含特殊召唤，数量为1，卡片来源为卡组；具体对象在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理时的操作：若自己场上有空位，则从卡组选择1张符合条件的「幻奏」怪兽，以表侧攻击表示特殊召唤到自己场上。
function c14763299.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己主要怪兽区没有空位，则中断处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示特殊召唤选择提示信息（“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组中选择1张符合条件的「幻奏」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c14763299.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到玩家自己场上，并正常检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
