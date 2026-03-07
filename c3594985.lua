--マジェスペクター・ドラコ
-- 效果：
-- ←5 【灵摆】 5→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域有「威风妖怪」卡或「龙剑士」卡存在的场合才能发动。从卡组把1张「威风妖怪」卡加入手卡。那之后，可以把自己的灵摆区域1张卡破坏。
-- 【怪兽效果】
-- 4星怪兽×2
-- 4星可以灵摆召唤的场合在额外卡组的表侧的这张卡可以灵摆召唤。这个卡名的①的怪兽效果1回合可以使用最多2次。
-- ①：这张卡在怪兽区域存在的状态，怪兽被解放的场合，把这张卡1个超量素材取除才能发动。从卡组把1只6星以下的魔法师族·风属性怪兽特殊召唤。
-- ②：怪兽区域的这张卡被战斗·效果破坏的场合或者被解放的场合才能发动。这张卡在自己的灵摆区域放置。
local s,id,o=GetID()
-- 初始化卡片效果，设置XYZ召唤手续、灵摆属性和三个效果
function s.initial_effect(c)
	-- 设置该卡为4星、2只怪兽叠放的XYZ召唤条件
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 为该卡添加灵摆怪兽属性，但不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：另一边的自己的灵摆区域有「威风妖怪」卡或「龙剑士」卡存在的场合才能发动。从卡组把1张「威风妖怪」卡加入手卡。那之后，可以把自己的灵摆区域1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.srcon)
	e1:SetTarget(s.srtg)
	e1:SetOperation(s.srop)
	c:RegisterEffect(e1)
	-- ①：这张卡在怪兽区域存在的状态，怪兽被解放的场合，把这张卡1个超量素材取除才能发动。从卡组把1只6星以下的魔法师族·风属性怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(2,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡被战斗·效果破坏的场合或者被解放的场合才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"在灵摆区域放置"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_RELEASE)
	c:RegisterEffect(e4)
end
s.pendulum_level=4
-- 判断灵摆区域是否有「威风妖怪」或「龙剑士」卡
function s.cfilter(c)
	return c:IsSetCard(0xc7,0xd0)
end
-- 判断灵摆区域是否有「威风妖怪」或「龙剑士」卡
function s.srcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断灵摆区域是否有「威风妖怪」或「龙剑士」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 检索卡组中「龙剑士」卡的过滤函数
function s.srfilter(c,oc)
	return c:IsSetCard(0xd0) and c:IsAbleToHand()
end
-- 设置灵摆效果的检索目标
function s.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的「龙剑士」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行灵摆效果的检索与破坏操作
function s.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local tc=Duel.SelectMatchingCard(tp,s.srfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 确认卡加入手牌并洗牌
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 确认对手查看加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
		-- 洗切玩家手牌
		Duel.ShuffleHand(tp)
		-- 获取玩家灵摆区域的卡组
		local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
		-- 判断是否选择破坏灵摆区域的卡
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把自己的灵摆区域1张卡破坏？"
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 显示被选为对象的卡
			Duel.HintSelection(sg)
			-- 破坏选中的灵摆区域卡
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
-- 判断解放的卡是否为怪兽且不在灵摆区域
function s.cfilter2(c)
	return (c:IsType(TYPE_MONSTER) and not c:IsPreviousLocation(LOCATION_SZONE)) or c:IsPreviousLocation(LOCATION_MZONE)
end
-- 判断是否有怪兽被解放且不是该卡本身
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 设置怪兽效果的取除超量素材费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 提示玩家选择要取除的超量素材
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选6星以下魔法师族·风属性怪兽
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置怪兽效果的特殊召唤目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 执行怪兽效果的特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断该卡是否从怪兽区域被破坏或解放
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 设置灵摆区域放置效果的目标
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 执行灵摆区域放置效果
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡移动到玩家的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
