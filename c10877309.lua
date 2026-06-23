--クロノダイバー・スタートアップ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从手卡把1只「时间潜行者」怪兽特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只「时间潜行者」超量怪兽为对象才能发动。从自己墓地选「时间潜行者」卡3种类（怪兽·魔法·陷阱）各1张在作为对象的怪兽下面重叠作为超量素材。
function c10877309.initial_effect(c)
	-- ①：从手卡把1只「时间潜行者」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,10877309)
	e1:SetTarget(c10877309.target)
	e1:SetOperation(c10877309.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只「时间潜行者」超量怪兽为对象才能发动。从自己墓地选「时间潜行者」卡3种类（怪兽·魔法·陷阱）各1张在作为对象的怪兽下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10877309,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,10877309)
	-- 将这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c10877309.mattg)
	e2:SetOperation(c10877309.matop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可以特殊召唤的「时间潜行者」怪兽
function c10877309.filter(c,e,tp)
	return c:IsSetCard(0x126) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动时点处理函数
function c10877309.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果①的发动条件：手牌有「时间潜行者」怪兽且场上存在召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足效果①的发动条件：手牌有「时间潜行者」怪兽且场上存在召唤空间
		and Duel.IsExistingMatchingCard(c10877309.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果①的处理信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的发动处理函数
function c10877309.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择1只满足条件的手牌怪兽
	local g=Duel.SelectMatchingCard(tp,c10877309.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤场上可以作为超量素材的「时间潜行者」超量怪兽
function c10877309.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x126)
end
-- 过滤墓地中的「时间潜行者」卡
function c10877309.matfilter(c)
	return c:IsSetCard(0x126) and c:IsCanOverlay()
end
-- 获取卡的类型位
function c10877309.ccfilter(c)
	return bit.band(c:GetType(),0x7)
end
-- 判断选择的3张卡是否来自不同种类（怪兽·魔法·陷阱）
function c10877309.fselect(g)
	return g:GetClassCount(c10877309.ccfilter)==g:GetCount()
end
-- 效果②的发动时点处理函数
function c10877309.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取墓地中所有「时间潜行者」卡
	local g=Duel.GetMatchingGroup(c10877309.matfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c10877309.xyzfilter(chkc) end
	-- 检查是否满足效果②的发动条件：场上存在「时间潜行者」超量怪兽且墓地有满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(c10877309.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and g:CheckSubGroup(c10877309.fselect,3,3) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择1只「时间潜行者」超量怪兽作为对象
	Duel.SelectTarget(tp,c10877309.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的发动处理函数
function c10877309.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 获取墓地中所有未受王家长眠之谷影响的「时间潜行者」卡
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c10877309.matfilter),tp,LOCATION_GRAVE,0,nil)
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local sg=g:SelectSubGroup(tp,c10877309.fselect,false,3,3)
		if sg and sg:GetCount()==3 then
			-- 将选择的卡作为超量素材叠放至对象怪兽上
			Duel.Overlay(tc,sg)
		end
	end
end
