--宝玉の玲瓏
-- 效果：
-- ①：「宝玉的玲珑」在自己场上只能有1张表侧表示存在。
-- ②：自己场上的「宝玉兽」怪兽的攻击力上升那原本守备力数值。
-- ③：自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动（伤害步骤也能发动）。从自己的手卡·墓地选1只「宝玉兽」怪兽特殊召唤。这个回合，自己受到的全部伤害变成一半。
local s,id,o=GetID()
-- 注册卡片的初始效果，设置唯一性、激活效果、攻击上升效果和特殊召唤效果
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	-- ①：「宝玉的玲珑」在自己场上只能有1张表侧表示存在。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制该效果只能在伤害步骤前发动
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ②：自己场上的「宝玉兽」怪兽的攻击力上升那原本守备力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设定攻击上升效果的目标为场上的宝玉兽数怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1034))
	-- 设定攻击上升值为怪兽的原本守备力数值
	e2:SetValue(aux.TargetBoolFunction(Card.GetBaseDefense))
	c:RegisterEffect(e2)
	-- ③：自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动（伤害步骤也能发动）。从自己的手卡·墓地选1只「宝玉兽」怪兽特殊召唤。这个回合，自己受到的全部伤害变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(s.con)
	e3:SetCost(s.cost)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断是否为场上宝玉兽数怪兽
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5
end
-- 判定条件：当有宝玉兽数怪兽移入魔法与陷阱区域时发动
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 费用支付：将自身送去墓地作为发动代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsStatus(STATUS_EFFECT_ENABLED) and c:IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为发动代价
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤函数：判断是否为可特殊召唤的宝玉兽数怪兽
function s.filter(c,e,tp)
	return c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设定特殊召唤效果的发动条件
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地中是否存在符合条件的宝玉兽数怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤宝玉兽数怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行特殊召唤效果的操作流程，包括设置伤害减半效果和选择特殊召唤的怪兽
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- ③：自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动（伤害步骤也能发动）。从自己的手卡·墓地选1只「宝玉兽」怪兽特殊召唤。这个回合，自己受到的全部伤害变成一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.val)
	e1:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将伤害减半效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或墓地中选择一只符合条件的宝玉兽数怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设定伤害减半效果的数值为原伤害的一半
function s.val(e,re,dam)
	return dam//2
end
