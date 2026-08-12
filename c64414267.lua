--煉獄の騎士 ヴァトライムス
-- 效果：
-- 4星「星骑士」怪兽×2
-- ①：只要这张卡在怪兽区域存在，场上的表侧表示怪兽变成暗属性。
-- ②：把这张卡1个超量素材取除，丢弃1张手卡才能发动（自己墓地的「星骑士」怪兽是7种类以上的场合，这个效果在对方回合也能发动）。把1只光属性「星骑士」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。这个效果的发动后，直到回合结束时自己不能把怪兽超量召唤。
function c64414267.initial_effect(c)
	-- 设置超量召唤手续：4星「星骑士」怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x9c),4,2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，场上的表侧表示怪兽变成暗属性。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e1)
	-- ②：把这张卡1个超量素材取除，丢弃1张手卡才能发动（自己墓地的「星骑士」怪兽是7种类以上的场合，这个效果在对方回合也能发动）。把1只光属性「星骑士」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。这个效果的发动后，直到回合结束时自己不能把怪兽超量召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64414267,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c64414267.spcon1)
	e2:SetCost(c64414267.spcost)
	e2:SetTarget(c64414267.sptg)
	e2:SetOperation(c64414267.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(c64414267.spcon2)
	c:RegisterEffect(e3)
end
-- 过滤条件：墓地中的「星骑士」怪兽
function c64414267.cfilter(c)
	return c:IsSetCard(0x9c) and c:IsType(TYPE_MONSTER)
end
-- 起动效果（自己回合）的发动条件：自己墓地的「星骑士」怪兽不足7种类
function c64414267.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中所有满足条件的「星骑士」怪兽
	local ct=Duel.GetMatchingGroup(c64414267.cfilter,tp,LOCATION_GRAVE,0,nil)
	return ct:GetClassCount(Card.GetCode)<7
end
-- 诱发即时效果（双方回合）的发动条件：自己墓地的「星骑士」怪兽在7种类以上
function c64414267.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中所有满足条件的「星骑士」怪兽
	local ct=Duel.GetMatchingGroup(c64414267.cfilter,tp,LOCATION_GRAVE,0,nil)
	return ct:GetClassCount(Card.GetCode)>=7
end
-- 效果发动代价（Cost）的检测与执行
function c64414267.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
		-- 检查手卡中是否存在至少1张可以丢弃的卡
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：额外卡组中可以重叠在当前卡上进行超量召唤的光属性「星骑士」超量怪兽
function c64414267.spfilter(c,e,tp,mc)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsSetCard(0x9c) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否能以超量召唤的方式特殊召唤，且额外区域有空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动目标（Target）的检测与设置
function c64414267.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前卡是否必须作为超量素材
	if chk==0 then return aux.MustMaterialCheck(e:GetHandler(),tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组中是否存在满足特殊召唤条件的目标怪兽
		and Duel.IsExistingMatchingCard(c64414267.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置连锁信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理（Operation）的执行：将目标怪兽重叠在当前卡上特殊召唤，并添加超量召唤限制
function c64414267.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前卡是否满足必须作为超量素材的规则限制
	if aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then
		if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 玩家从额外卡组选择1只满足条件的超量怪兽
			local g=Duel.SelectMatchingCard(tp,c64414267.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
			local sc=g:GetFirst()
			if sc then
				local mg=c:GetOverlayGroup()
				if mg:GetCount()~=0 then
					-- 将当前卡原本持有的超量素材转移重叠到新召唤的怪兽下
					Duel.Overlay(sc,mg)
				end
				sc:SetMaterial(Group.FromCards(c))
				-- 将当前卡作为超量素材重叠在新召唤的怪兽下
				Duel.Overlay(sc,Group.FromCards(c))
				-- 将目标怪兽以超量召唤的形式表侧表示特殊召唤
				Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
				sc:CompleteProcedure()
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不能把怪兽超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c64414267.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能超量召唤的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：限制的召唤类型为超量召唤
function c64414267.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return bit.band(sumtype,SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ
end
