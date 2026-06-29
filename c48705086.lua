--玲瓏竜クンツァイド
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡在手卡存在的场合才能发动。从手卡·卡组把1只7星以上的通常怪兽送去墓地，这张卡特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1只通常怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 注册手卡送墓7星以上通常怪兽特召自身、以及除外墓地自身特召墓地通常怪兽的效果
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合才能发动。从手卡·卡组把1只7星以上的通常怪兽送去墓地，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只通常怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 将墓地的此卡除外作为效果②发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 手卡或卡组中等级为7星以上且能够送入墓地的通常怪兽的过滤条件
function s.tgfilter(c)
	return c:IsLevelAbove(7) and c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
-- 效果①的发动准备与合法性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空闲的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手卡或卡组中是否存在符合送墓条件的7星以上通常怪兽
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c) end
	-- 设置操作信息为将卡片送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
	-- 设置操作信息为从手卡特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 送墓7星以上通常怪兽以及特殊召唤此卡自身的执行
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从手卡或卡组选择1只符合条件的7星以上通常怪兽
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,aux.ExceptThisCard(e)):GetFirst()
	-- 将选择的通常怪兽送入墓地，若成功送墓则继续处理
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) then
		-- 将手卡的此卡以表侧表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 墓地中能够以守备表示进行特殊召唤的通常怪兽的过滤条件
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动准备与对象选择
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空闲的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在可以特殊召唤的通常怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 向玩家提示选择需要特殊召唤的墓地怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择1只符合条件的通常怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 从墓地守备表示特殊召唤通常怪兽的执行
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中关联的作为特殊召唤对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认怪兽依然有效处于墓地且效果处理未受墓地无效影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将选中的墓地怪兽以表侧守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
