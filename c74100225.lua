--進化の特異点
-- 效果：
-- ①：以自己墓地1只「进化虫」怪兽和1只「进化龙」怪兽为对象才能发动。从额外卡组把1只「进化帝」超量怪兽特殊召唤，把作为对象的怪兽作为那只超量怪兽的超量素材。
function c74100225.initial_effect(c)
	-- ①：以自己墓地1只「进化虫」怪兽和1只「进化龙」怪兽为对象才能发动。从额外卡组把1只「进化帝」超量怪兽特殊召唤，把作为对象的怪兽作为那只超量怪兽的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c74100225.target)
	e1:SetOperation(c74100225.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为指定系列的怪兽，且可以作为超量素材
function c74100225.filter(c,cat)
	return c:IsSetCard(cat) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 过滤函数：检查额外卡组中是否存在可以特殊召唤的「进化帝」超量怪兽，且额外卡组怪兽出场区域有空位
function c74100225.spfilter(c,e,tp)
	-- 检查卡片是否为「进化帝」超量怪兽，是否能被特殊召唤，以及额外卡组怪兽出场区域是否有空位
	return c:IsSetCard(0x504e) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动阶段：检查发动条件，即墓地是否存在符合条件的「进化虫」和「进化龙」怪兽，以及额外卡组是否有可特殊召唤的「进化帝」超量怪兽
function c74100225.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己墓地是否存在至少1只可以作为超量素材的「进化虫」怪兽
	if chk==0 then return Duel.IsExistingTarget(c74100225.filter,tp,LOCATION_GRAVE,0,1,nil,0x304e)
		-- 检查自己墓地是否存在至少1只可以作为超量素材的「进化龙」怪兽
		and Duel.IsExistingTarget(c74100225.filter,tp,LOCATION_GRAVE,0,1,nil,0x604e)
		-- 检查额外卡组是否存在至少1只可以特殊召唤的「进化帝」超量怪兽
		and Duel.IsExistingMatchingCard(c74100225.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择自己墓地1只「进化虫」怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c74100225.filter,tp,LOCATION_GRAVE,0,1,1,nil,0x304e)
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择自己墓地1只「进化龙」怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c74100225.filter,tp,LOCATION_GRAVE,0,1,1,nil,0x604e)
	g1:Merge(g2)
	-- 设置操作信息：2张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g1,2,0,0)
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理阶段：从额外卡组特殊召唤1只「进化帝」超量怪兽，并将作为对象的墓地怪兽重叠作为其超量素材
function c74100225.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的「进化帝」超量怪兽
	local sg=Duel.SelectMatchingCard(tp,c74100225.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local sc=sg:GetFirst()
	-- 若成功将选择的「进化帝」超量怪兽以表侧表示特殊召唤
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取墓地中仍与当前连锁相关的对象怪兽（即作为对象的「进化虫」和「进化龙」怪兽）
		local mg=Duel.GetTargetsRelateToChain()
		if #mg>0 then
			-- 将这些对象怪兽重叠作为该超量怪兽的超量素材
			Duel.Overlay(sc,mg)
		end
	end
end
