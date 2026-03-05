--エクシーズ・ポセイドン・スプラッシュ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：有超量怪兽在作为超量素材中的超量怪兽在自己场上存在的场合，宣言场上的怪兽1个属性才能发动。除有装备魔法卡装备的怪兽外的场上的宣言属性的怪兽全部破坏。
-- ②：把墓地的这张卡除外，把自己场上1个超量素材取除才能发动。从自己墓地把1只鱼族·海龙族·水族怪兽在自己或对方的场上特殊召唤。
local s,id,o=GetID()
-- 注册卡牌的两个效果：①破坏效果和②特殊召唤效果
function s.initial_effect(c)
	-- ①：有超量怪兽在作为超量素材中的超量怪兽在自己场上存在的场合，宣言场上的怪兽1个属性才能发动。除有装备魔法卡装备的怪兽外的场上的宣言属性的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏怪兽"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，把自己场上1个超量素材取除才能发动。从自己墓地把1只鱼族·海龙族·水族怪兽在自己或对方的场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡片是否为超量怪兽
function s.mfilter(c)
	return c:IsType(TYPE_XYZ)
end
-- 过滤函数：判断卡片是否为表侧表示的超量怪兽且其叠放区有超量怪兽
function s.ffilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(s.mfilter,1,nil)
end
-- 效果条件函数：判断自己场上是否存在满足ffilter条件的怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足ffilter条件的怪兽
	return Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：判断卡片是否为表侧表示且属性为指定属性且未装备魔法卡
function s.desfilter(c,attr)
	return c:IsFaceup() and c:IsAttribute(attr) and c:GetEquipGroup():Filter(Card.IsType,nil,TYPE_SPELL):GetCount()==0
end
-- 过滤函数：判断卡片是否为表侧表示且未装备魔法卡
function s.dmfilter(c)
	return c:IsFaceup() and c:GetEquipGroup():Filter(Card.IsType,nil,TYPE_SPELL):GetCount()==0
end
-- 效果处理函数：设置破坏效果的目标和参数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在满足dmfilter条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.dmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取所有满足dmfilter条件的怪兽组
	local g=Duel.GetMatchingGroup(s.dmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local attr=0
	-- 遍历怪兽组中的每张怪兽
	for tc in aux.Next(g) do
		attr=attr|tc:GetAttribute()
	end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言一个属性
	local at=Duel.AnnounceAttribute(tp,1,attr)
	e:SetLabel(at)
	-- 获取所有满足desfilter条件的怪兽组
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,at)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果处理函数：执行破坏效果
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local attr=e:GetLabel()
	-- 获取所有满足desfilter条件的怪兽组
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,attr)
	if dg:GetCount()>0 then
		-- 将目标怪兽破坏
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
-- 效果处理函数：设置特殊召唤效果的费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤效果的费用条件
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 将此卡除外作为费用
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 从自己场上移除1个超量素材作为费用
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- 过滤函数：判断卡片是否为鱼族·海龙族·水族怪兽且可以特殊召唤
function s.filter(c,e,tp)
	-- 判断自己场上是否有足够的位置特殊召唤该怪兽
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
	-- 判断对方场上是否有足够的位置特殊召唤该怪兽
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	return c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT) and (b1 or b2)
end
-- 效果处理函数：设置特殊召唤效果的目标和参数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在满足filter条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数：执行特殊召唤效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己和对方场上是否都没有足够的位置进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足filter条件的1张卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 显示选中的卡被选为对象的动画
		Duel.HintSelection(g)
		-- 判断对方场上是否有足够的位置特殊召唤该怪兽
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
			-- 判断自己场上是否有足够的位置特殊召唤该怪兽
			and (not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false))
				-- 询问玩家是否在对方场上特殊召唤
				or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then  --"是否在对方场上特殊召唤？"
			-- 将怪兽特殊召唤到对方场上
			Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
		else
			-- 将怪兽特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
