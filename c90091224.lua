--四天の龍 ダーク・リベリオン・エクシーズ・ドラゴン
-- 效果：
-- 暗属性4星怪兽×2
-- 这个卡名在规则上也当作「幻影骑士团」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以自己以及对方场上的卡各相同数量为对象才能发动。那些卡破坏。
-- ②：对方把效果发动时，把这张卡1个超量素材取除才能发动。把1只暗属性·4阶的超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果和XYZ召唤手续的初始化函数
function s.initial_effect(c)
	-- 添加XYZ召唤手续：暗属性4星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),4,2)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，以自己以及对方场上的卡各相同数量为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：对方把效果发动时，把这张卡1个超量素材取除才能发动。把1只暗属性·4阶的超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"超量召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：过滤场上可以成为效果对象的卡
function s.desfilter(c,e)
	return c:IsCanBeEffectTarget(e)
end
-- 效果①的发动靶向：获取场上所有可以作为对象的卡，若双方场上都存在至少一张卡，则让玩家从双方场上选择相同数量的卡作为对象，并设置破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取场上双方所有可以被效果选为对象的卡
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then
		return g:IsExists(Card.IsControler,1,nil,tp) and g:IsExists(Card.IsControler,1,nil,1-tp)
	end
	local g1=g:Filter(Card.IsControler,nil,tp)
	local g2=g:Filter(Card.IsControler,nil,1-tp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上的卡中选择相同数量的卡
	local sg=aux.SelectSameCount(tp,g1,g2)
	-- 将选定的卡设为当前连锁的效果对象
	Duel.SetTargetCard(sg)
	-- 设置操作信息：预计将选中的相同数量的卡破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果①的效果处理：获取所有仍存在于场上的效果对象并将其破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中所有与该连锁相关且仍然在场上的效果对象卡片
	local sg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	-- 破坏选定的卡片
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 效果②的发动条件：对方玩家把效果发动时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
-- 效果②的发动代价：把这张卡1个超量素材取除
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：过滤额外卡组可以当作超量召唤重叠召唤在自己场上的暗属性4阶超量怪兽
function s.spfilter(c,e,tp,mc)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRank(4) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否能以超量召唤形式特殊召唤，以及额外怪兽区域或所指向的区域是否存在可用格子
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果②的发动靶向：检查自己是否必须使用特定素材，以及额外卡组是否存在可以特殊召唤的暗属性4阶超量怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有必须成为超量素材的卡片检测限制
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组中是否存在至少1只满足超量召唤条件的暗属性4阶超量怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置操作信息：预计从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理：必须在素材检测通过且这张卡在场、属于自己控制的情况下，选择额外卡组中的暗属性4阶超量怪兽，将其拥有的超量素材与这张卡自身重叠叠放在该超量怪兽下方，当作超量召唤特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否有必须成为超量素材的卡片检测限制，若不通过则返回
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToChain() and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组中选择1只满足条件的暗属性4阶超量怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将这张卡原本拥有的超量素材全部重叠到新特殊召唤的超量怪兽下方
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将这张卡自身作为超量素材叠放到新特殊召唤的超量怪兽下方
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将选定的超量怪兽以超量召唤的方式在场上特殊召唤
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
