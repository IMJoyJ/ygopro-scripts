--クロノダイバー・スタートアップ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从手卡把1只「时间潜行者」怪兽特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只「时间潜行者」超量怪兽为对象才能发动。从自己墓地选「时间潜行者」卡3种类（怪兽·魔法·陷阱）各1张在作为对象的怪兽下面重叠作为超量素材。
function c10877309.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：从手卡把1只「时间潜行者」怪兽特殊召唤。
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
	-- 设置②效果的发动代价：把墓地里的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c10877309.mattg)
	e2:SetOperation(c10877309.matop)
	c:RegisterEffect(e2)
end
-- 定义①效果的特殊召唤对象过滤器：必须是「时间潜行者」字段怪兽，且满足特殊召唤条件。
function c10877309.filter(c,e,tp)
	return c:IsSetCard(0x126) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：自己主要怪兽区有空位，且手牌存在符合条件的「时间潜行者」怪兽。
function c10877309.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用的空格（特殊召唤所需空位）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足过滤器条件的「时间潜行者」怪兽。
		and Duel.IsExistingMatchingCard(c10877309.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设定处理时将要进行特殊召唤的操作信息，用于连锁响应检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：若仍有空位，则从手牌选择1只符合条件的「时间潜行者」怪兽，以表侧表示特殊召唤。
function c10877309.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的主要怪兽区，则效果不处理（不特殊召唤）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手牌中筛选并选择1张符合条件的「时间潜行者」怪兽。
	local g=Duel.SelectMatchingCard(tp,c10877309.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果对象的过滤器：自己场上的表侧表示「时间潜行者」超量怪兽。
function c10877309.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x126)
end
-- 定义可选择作为超量素材的卡过滤器：墓地的「时间潜行者」卡且可以成为超量素材。
function c10877309.matfilter(c)
	return c:IsSetCard(0x126) and c:IsCanOverlay()
end
-- 获取卡片的种类标识（用位与0x7提取怪兽·魔法·陷阱类型），用于判断3种类。
function c10877309.ccfilter(c)
	return bit.band(c:GetType(),0x7)
end
-- 判断所选卡片组中，卡的种类数量等于卡数，即3张卡必须分别为怪兽·魔法·陷阱三种类。
function c10877309.fselect(g)
	return g:GetClassCount(c10877309.ccfilter)==g:GetCount()
end
-- ②效果的发动条件判定：取对象并确认墓地存在3张不同种类的「时间潜行者」卡可作素材。
function c10877309.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取墓地所有符合条件的「时间潜行者」卡（排除自身，因为自身除外作为代价，e:GetHandler()即自身从墓地除外）。
	local g=Duel.GetMatchingGroup(c10877309.matfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c10877309.xyzfilter(chkc) end
	-- 检查是否存在可取对象的「时间潜行者」超量怪兽。
	if chk==0 then return Duel.IsExistingTarget(c10877309.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and g:CheckSubGroup(c10877309.fselect,3,3) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的「时间潜行者」超量怪兽作为效果对象。
	Duel.SelectTarget(tp,c10877309.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：若对象仍与效果相关且不受效果免疫，则从墓地选3张不同种类的「时间潜行者」卡重叠到对象下面作为超量素材。
function c10877309.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的那个对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 获取墓地可选的超量素材卡，并应用王家长眠之谷的过滤（受其影响时不能选择）。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c10877309.matfilter),tp,LOCATION_GRAVE,0,nil)
		-- 提示玩家选择要作为超量素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		local sg=g:SelectSubGroup(tp,c10877309.fselect,false,3,3)
		if sg and sg:GetCount()==3 then
			-- 将选择的3张卡作为超量素材叠放在对象怪兽下面。
			Duel.Overlay(tc,sg)
		end
	end
end
