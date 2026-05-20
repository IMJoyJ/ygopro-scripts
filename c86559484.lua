--X－レイ・ピアース
-- 效果：
-- 「超量透视细剑龙」的①②的效果1回合各能使用1次。
-- ①：从自己墓地把龙族怪兽和幻龙族怪兽各1只除外才能发动。从手卡·卡组把1只「超量透视细剑龙」特殊召唤。
-- ②：这张卡从场上送去墓地的场合才能发动。给与对方500伤害。
function c86559484.initial_effect(c)
	-- ①：从自己墓地把龙族怪兽和幻龙族怪兽各1只除外才能发动。从手卡·卡组把1只「超量透视细剑龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86559484,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,86559484)
	e1:SetCost(c86559484.spcost)
	e1:SetTarget(c86559484.sptg)
	e1:SetOperation(c86559484.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86559484,1))  --"给予伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,86559485)
	e2:SetCondition(c86559484.damcon)
	e2:SetTarget(c86559484.damtg)
	e2:SetOperation(c86559484.damop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地可以作为cost除外的龙族或幻龙族怪兽
function c86559484.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsRace(RACE_DRAGON+RACE_WYRM)
end
-- ①号效果的发动代价：从自己墓地把龙族和幻龙族怪兽各1只除外
function c86559484.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地所有可以作为cost除外的龙族及幻龙族怪兽
	local g=Duel.GetMatchingGroup(c86559484.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查墓地中是否存在龙族和幻龙族怪兽各1只
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsRace,RACE_DRAGON,RACE_WYRM) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地选择龙族和幻龙族怪兽各1只
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsRace,RACE_DRAGON,RACE_WYRM)
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 过滤手卡·卡组中可以特殊召唤的「超量透视细剑龙」
function c86559484.spfilter(c,e,tp)
	return c:IsCode(86559484) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备与合法性检测
function c86559484.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在可以特殊召唤的「超量透视细剑龙」
		and Duel.IsExistingMatchingCard(c86559484.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡·卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①号效果的效果处理：从手卡·卡组把1只「超量透视细剑龙」特殊召唤
function c86559484.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择1只「超量透视细剑龙」
	local g=Duel.SelectMatchingCard(tp,c86559484.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查这张卡是否是从场上送去墓地
function c86559484.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②号效果的发动准备与合法性检测
function c86559484.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为500（伤害值）
	Duel.SetTargetParam(500)
	-- 设置伤害的操作信息（给与对方500伤害）
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- ②号效果的效果处理：给与对方500伤害
function c86559484.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
