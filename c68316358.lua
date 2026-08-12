--魅惑の舞
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「魅惑的女王」怪兽或1张「魅惑的宫殿」加入手卡。
-- ②：自己场上的「魅惑的女王」怪兽的攻击力上升自身的效果装备的怪兽的攻击力数值。
-- ③：把自己场上1张其他的魔法·陷阱卡送去墓地才能发动。从自己墓地把「魅惑的女王」怪兽尽可能特殊召唤（同名卡最多1张）。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 建立卡片关联，记录本卡效果中记载了「魅惑的宫殿」（卡号31322640）。
	aux.AddCodeList(c,31322640)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「魅惑的女王」怪兽或1张「魅惑的宫殿」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「魅惑的女王」怪兽的攻击力上升自身的效果装备的怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	-- ③：把自己场上1张其他的魔法·陷阱卡送去墓地才能发动。从自己墓地把「魅惑的女王」怪兽尽可能特殊召唤（同名卡最多1张）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"尽可能特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「魅惑的女王」怪兽或「魅惑的宫殿」且能加入手牌的卡。
function s.filter(c)
	return (c:IsSetCard(0x3) and c:IsType(TYPE_MONSTER) or c:IsCode(31322640)) and c:IsAbleToHand()
end
-- 魔法卡发动时的效果处理函数，可选择检索一张卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足检索条件的卡。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在满足条件的卡，则询问玩家是否将其加入手卡。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组加入手卡？"
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入玩家手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤出表侧表示、原本是怪兽卡，且带有「魅惑的女王」装备标记的效果装备卡。
function s.atkfilter(c,code)
	return c:IsFaceup() and bit.band(c:GetOriginalType(),TYPE_MONSTER)==TYPE_MONSTER
		and c:GetFlagEffect(code)~=0
end
-- 过滤自己场上的「魅惑的女王」怪兽作为攻击力上升效果的适用对象。
function s.atktg(e,c)
	return c:IsSetCard(0x3)
end
-- 计算攻击力上升值：自身效果装备的怪兽的原本攻击力合计值。
function s.val(e,c)
	local g=c:GetEquipGroup():Filter(s.atkfilter,nil,FLAG_ID_ALLURE_QUEEN)
	if g:GetCount()>0 then
		return g:GetSum(Card.GetBaseAttack)
	else
		return 0
	end
end
-- 过滤作为Cost送去墓地的其他魔法·陷阱卡，且该卡送去墓地后能腾出至少1个怪兽区域。
function s.spcfilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
		-- 检查该卡是否能作为Cost送去墓地，且该卡离场后自己场上是否有可用的怪兽区域。
		and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果③的发动代价（Cost）处理函数。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 步骤0：检查场上是否存在可以作为Cost送去墓地的其他魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_ONFIELD,0,1,c,tp) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张自己场上的其他魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_ONFIELD,0,1,1,c,tp)
	-- 将选中的卡作为Cost送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤墓地中可以特殊召唤的「魅惑的女王」怪兽。
function s.sfilter(c,e,tp)
	return c:IsSetCard(0x3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的靶向（Target）检查与操作信息设置函数。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查墓地中是否存在至少1只可以特殊召唤的「魅惑的女王」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从墓地特殊召唤至少1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果③的效果处理（Operation）函数。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取墓地中满足特殊召唤条件且不受「王家长眠之谷」影响的「魅惑的女王」怪兽。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.sfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 计算最大可特殊召唤的数量（空怪兽区域数量与墓地中不同卡名怪兽种类的较小值）。
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),g:GetClassCount(Card.GetCode))
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 筛选出数量等于最大可召唤数且卡名互不相同的怪兽组合。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,ft,ft)
	-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
	if sg then Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) end
end
