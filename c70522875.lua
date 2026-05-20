--ドラグニティロード－ゲオルギアス
-- 效果：
-- 包含调整的怪兽2只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合或者对方把怪兽特殊召唤的场合才能发动。从自己的额外卡组·墓地把1只5星以上的「龙骑兵团」怪兽特殊召唤。
-- ②：只要这张卡有「龙骑兵团」卡装备，对方不能把墓地的怪兽的效果发动。
-- ③：对方把魔法·陷阱卡的效果发动时，把自己场上1张装备卡送去墓地才能发动。那个效果无效。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含连接召唤手续、①效果（连接召唤成功或对方特召时特召额外/墓地龙骑兵团）、②效果（有龙骑兵团装备时封锁对方墓地怪兽效果）、③效果（送墓装备卡无效魔陷效果）。
function s.initial_effect(c)
	-- 设置连接召唤手续：需要2只以上怪兽作为素材，且必须包含调整怪兽。
	aux.AddLinkProcedure(c,nil,2,99,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合或者对方把怪兽特殊召唤的场合才能发动。从自己的额外卡组·墓地把1只5星以上的「龙骑兵团」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.spcon2)
	c:RegisterEffect(e2)
	-- ②：只要这张卡有「龙骑兵团」卡装备，对方不能把墓地的怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.condition)
	e3:SetValue(s.aclimit)
	c:RegisterEffect(e3)
	-- ③：对方把魔法·陷阱卡的效果发动时，把自己场上1张装备卡送去墓地才能发动。那个效果无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.discon)
	e4:SetCost(s.discost)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
-- 连接素材过滤条件：素材组中必须存在至少1只调整怪兽。
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_TUNER)
end
-- ①效果的触发条件1：这张卡是通过连接召唤特殊召唤成功的。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果的触发条件2：对方玩家特殊召唤了怪兽。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),1-tp)
end
-- 过滤满足特殊召唤条件的卡：5星以上的「龙骑兵团」怪兽，且根据其所在位置（墓地或额外卡组）判断是否有可用的怪兽区域。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x29) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsLevelAbove(5)
		-- 如果目标卡在墓地，检查自己场上是否有空余的怪兽区域。
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 如果目标卡在额外卡组，检查自己场上是否有空余的额外怪兽区域。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ①效果的发动准备：检查是否存在可特召的怪兽，并向对方玩家宣告发动该效果，设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组或墓地是否存在至少1只满足特召条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从额外卡组或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
	-- 向对方玩家提示本效果已被选择发动。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ①效果的效果处理：让玩家从额外卡组或墓地选择1只满足条件的「龙骑兵团」怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 过滤并让玩家从额外卡组或墓地选择1只满足条件的怪兽（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的适用条件：自身装备有表侧表示的「龙骑兵团」卡。
function s.condition(e)
	-- 检查这张卡的装备卡组中是否存在表侧表示的「龙骑兵团」卡。
	return e:GetHandler():GetEquipGroup():IsExists(aux.AND(Card.IsSetCard,Card.IsFaceup),1,nil,0x29)
end
-- ②效果的限制内容：限制对方不能发动墓地中的怪兽效果。
function s.aclimit(e,re,tp)
	local loc=re:GetActivateLocation()
	return loc==LOCATION_GRAVE and re:IsActiveType(TYPE_MONSTER)
end
-- ③效果的发动条件：对方发动魔法·陷阱卡的效果时，且该效果可以被无效，且自身未被战斗破坏。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return ep==1-tp
		-- 检查发动的效果是否为魔法或陷阱卡的效果，且该连锁效果可以被无效。
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
-- ③效果的Cost过滤条件：自己场上表侧表示、且作为装备卡装备着、且能送去墓地的卡。
function s.cgfilter(c)
	return c:IsFaceup() and c:GetEquipTarget() and c:IsAbleToGraveAsCost()
end
-- ③效果的发动代价：把自己场上1张装备卡送去墓地。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1张满足送墓条件的装备卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cgfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张满足条件的装备卡。
	local g=Duel.SelectMatchingCard(tp,s.cgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的装备卡作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ③效果的发动准备：设置无效效果的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示本效果已被选择发动。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果无效的操作信息，指定对象为当前连锁中发动的卡。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ③效果的效果处理：使该魔法·陷阱卡的效果无效。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效对应连锁的效果。
	Duel.NegateEffect(ev)
end
