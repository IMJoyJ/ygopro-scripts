--火霊媒師ヒータ
-- 效果：
-- 这个卡名在规则上也当作「灵使」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡和1只炎属性怪兽丢弃才能发动。比这张卡以外的丢弃的怪兽攻击力高的1只炎属性怪兽从卡组加入手卡。这个效果的发动后，直到回合结束时自己不能把炎属性以外的怪兽的效果发动。
-- ②：自己的炎属性怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册①效果（手卡起动检索）和②效果（炎属性怪兽战破时手卡特召）
function s.initial_effect(c)
	-- ①：从手卡把这张卡和1只炎属性怪兽丢弃才能发动。比这张卡以外的丢弃的怪兽攻击力高的1只炎属性怪兽从卡组加入手卡。这个效果的发动后，直到回合结束时自己不能把炎属性以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己的炎属性怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤满足丢弃条件的炎属性怪兽：该卡必须是炎属性、可丢弃，且卡组中存在攻击力比其高的可检索炎属性怪兽
function s.dfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsDiscardable()
		-- 检查卡组中是否存在攻击力比该丢弃怪兽高的炎属性怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,c:GetAttack())
end
-- 过滤满足检索条件的卡：卡组中的炎属性怪兽，其攻击力需大于指定的数值，且能加入手卡
function s.filter(c,atk)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:GetAttack()>atk and c:IsAbleToHand()
end
-- ①效果的发动代价（Cost）处理函数：检查并从手卡将这张卡和另一只炎属性怪兽丢弃，并记录另一只怪兽的攻击力
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查发动代价是否满足：自身可丢弃，且手卡中存在另一张满足条件的炎属性怪兽
	if chk==0 then return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,1,c,tp) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手卡选择1张除自身以外的满足条件的炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND,0,1,1,c,tp)
	e:SetLabel(g:GetFirst():GetAttack())
	-- 将选中的怪兽和这张卡作为发动代价一起丢弃送去墓地
	Duel.SendtoGrave(g+c,REASON_COST+REASON_DISCARD)
end
-- ①效果的发动检测（Target）函数：检查卡组中是否存在符合条件的检索对象
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查卡组中是否存在攻击力大于被丢弃怪兽的炎属性怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) end
	-- 设置连锁中的操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的效果处理（Operation）函数：从卡组将符合条件的炎属性怪兽加入手卡，并给玩家施加“不能发动炎属性以外的怪兽效果”的限制
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只攻击力比丢弃怪兽高的炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if #g>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时自己不能把炎属性以外的怪兽的效果发动。②：自己的炎属性怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制玩家发动效果的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动效果的过滤函数：限制非炎属性怪兽的效果发动
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsNonAttribute(ATTRIBUTE_FIRE)
end
-- 过滤被战斗破坏的怪兽：必须是炎属性且原本控制者为自己
function s.cfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsPreviousControler(tp)
end
-- ②效果的发动条件（Condition）函数：检查是否有自己的炎属性怪兽被战斗破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ②效果的发动检测（Target）函数：检查自身是否能特殊召唤，并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果的效果处理（Operation）函数：将手卡的这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍存在于手卡，则将其以表侧表示特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
