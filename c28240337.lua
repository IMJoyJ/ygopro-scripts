--真紅眼の不屍竜
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力·守备力上升双方的场上·墓地的不死族怪兽数量×100。
-- ②：这张卡以外的不死族怪兽被战斗破坏时才能发动。选自己或者对方的墓地1只不死族怪兽在自己场上特殊召唤。
function c28240337.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整1只＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力·守备力上升双方的场上·墓地的不死族怪兽数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c28240337.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡以外的不死族怪兽被战斗破坏时才能发动。选自己或者对方的墓地1只不死族怪兽在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,28240337)
	e3:SetCondition(c28240337.spcon)
	e3:SetTarget(c28240337.sptg)
	e3:SetOperation(c28240337.spop)
	c:RegisterEffect(e3)
end
-- 计算这张卡的攻击力上升值：统计双方场上与墓地的不死族怪兽数量，每只上升100点攻击力。
function c28240337.atkval(e,c)
	-- 返回双方场上与墓地的不死族怪兽数量乘以100，作为攻击力上升数值。
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil,RACE_ZOMBIE)*100
end
-- 过滤函数：判断被战斗破坏的怪兽在被破坏前的种族是否为不死族。
function c28240337.cfilter(c)
	return c:GetPreviousRaceOnField()&RACE_ZOMBIE~=0
end
-- 发动条件：被战斗破坏送去墓地的怪兽群中存在至少1只被破坏前为不死族的怪兽时，满足②效果的发动条件。
function c28240337.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28240337.cfilter,1,nil)
end
-- 特殊召唤对象筛选：选择双方墓地中满足不死族且可以被当前效果特殊召唤的怪兽。
function c28240337.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标检查：确认自己场上留有可用的怪兽区空格，并且双方墓地存在可特殊召唤的不死族怪兽，否则不能发动。
function c28240337.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否还有可用的主要怪兽区域空格，无空格则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地中是否存在至少1只满足条件（不死族且可被特殊召唤）的怪兽，存在才能发动。
		and Duel.IsExistingMatchingCard(c28240337.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 设置操作信息，声明本效果将进行特殊召唤，预定从墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：若自己场上仍有可用怪兽区空格，则让玩家从双方墓地选择1只不死族怪兽（不受王家长眠之谷影响）特殊召唤到自己场上。
function c28240337.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否有空位，若无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从双方墓地中筛选可特殊召唤的不死族怪兽，并使用王家长眠之谷过滤器排除受影响者，让玩家选择1张。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28240337.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
