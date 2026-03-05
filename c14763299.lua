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
-- 检查特殊召唤条件的函数
function c14763299.spcon(e,c)
	if c==nil then return true end
	-- 判断自己场上是否有怪兽
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 判断对方场上是否有怪兽
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 判断自己场上是否有可用区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判断效果是否发动的函数
function c14763299.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 筛选符合条件的「幻奏」怪兽的函数
function c14763299.filter(c,e,tp)
	return c:IsSetCard(0x9b) and not c:IsCode(14763299) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标的函数
function c14763299.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：自己场上是否有可用区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c14763299.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时执行的函数
function c14763299.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有可用区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从卡组中选择一张符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c14763299.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
