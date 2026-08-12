--バリアンズ・シール
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：「混沌超量」怪兽或者「混沌No.101」～「混沌No.107」其中任意种的「混沌No.」怪兽在自己场上存在，对方把怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。那之后，可以从自己或对方的场上·墓地把1只怪兽作为自己场上1只超量怪兽的超量素材。
-- ②：把墓地的这张卡除外才能发动。从自己墓地把2只「阴影」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化注册两个效果：e1为魔陷发动的诱发即时无效效果（对方发动怪兽效果或魔陷卡时连锁发动，1回合1次），e2为墓地的诱发即时特殊召唤效果（自由时点，除外自身为代价，1回合1次，与①效果共用次数限制）
function s.initial_effect(c)
	-- ①：「混沌超量」怪兽或者「混沌No.101」～「混沌No.107」其中任意种的「混沌No.」怪兽在自己场上存在，对方把怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。那之后，可以从自己或对方的场上·墓地把1只怪兽作为自己场上1只超量怪兽的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"无效"
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己墓地把2只「阴影」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 设定②效果的发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤器：表侧表示的「混沌超量」怪兽，或者「混沌No.101」～「混沌No.107」的「混沌No.」怪兽
function s.cfilter(c)
	-- 获取该卡的No.编号（非「No.」卡则为nil）
	local no=aux.GetXyzNumber(c)
	return c:IsFaceup() and (no and no>=101 and no<=107 and c:IsSetCard(0x1048)
		or c:IsSetCard(0x1073))
end
-- ①效果的发动条件：自己场上存在「混沌超量」或「混沌No.101」～「混沌No.107」的怪兽，且对方发动的怪兽效果或魔陷卡的发动可以被无效
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测自己怪兽区是否存在满足条件的「混沌超量」或「混沌No.101」～「混沌No.107」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检测该连锁是对方发动的怪兽效果或魔法·陷阱卡的发动，且其发动可以被无效
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev) and rp==1-tp
end
-- ①效果的目标函数：无需选取对象，设置使发动无效的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁将使发动中的那张卡（eg）的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 过滤器：自己场上表侧表示的超量怪兽，且双方场上·墓地存在可以作为其超量素材的怪兽（不受王家长眠之谷影响）
function s.xyzfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检测双方场上·墓地是否存在至少1只可作为该超量怪兽素材的怪兽（排除该超量怪兽自身，并适用王家长眠之谷过滤）
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,c,e)
end
-- 素材过滤器：可以作为超量素材叠放、且不受此效果免疫影响的怪兽卡
function s.mtfilter(c,e)
	return c:IsType(TYPE_MONSTER)
		and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- ①效果的处理：使对方那次发动无效，若自己场上存在可叠加素材的超量怪兽且玩家选择是，则中断效果处理，依次选择1只超量怪兽和1只怪兽素材，将素材原本的超量素材送墓后叠放到该超量怪兽下
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的发动无效，并检查是否成功
	if Duel.NegateActivation(ev)
		-- 检测自己场上是否存在可以获得超量素材的超量怪兽
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 询问玩家是否要将怪兽作为超量素材（选择否则处理结束）
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否获得超量素材？"
		-- 中断当前效果处理，使之后的叠放处理与无效处理视为不同时进行（对应「那之后」）
		Duel.BreakEffect()
		-- 提示玩家选择1只要获得超量素材的超量怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))  --"请选择1只超量怪兽"
		-- 让自己玩家从自己场上选择1只满足条件的超量怪兽
		local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		local xc=g:GetFirst()
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 让玩家从双方场上·墓地选择1只作为超量素材的怪兽（优先选择场上的卡，并适用王家长眠之谷过滤）
		local mg=aux.SelectCardFromFieldFirst(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,xc,e)
		if mg:GetCount()>0 then
			-- 显示所选素材卡的选中动画并记录其被选择
			Duel.HintSelection(mg)
			local og=mg:GetFirst():GetOverlayGroup()
			if og:GetCount()>0 then
				-- 把该素材怪兽原本持有的超量素材按规则送去墓地
				Duel.SendtoGrave(og,REASON_RULE)
			end
			-- 把所选怪兽作为超量素材叠放到所选超量怪兽下面
			Duel.Overlay(xc,mg)
		end
	end
end
-- 过滤器：自己墓地中可以特殊召唤的「阴影」怪兽
function s.ffilter(c,e,tp)
	return c:IsSetCard(0x87) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标：检测自己主要怪兽区有2个以上空格、「青眼精灵龙」的同时特殊召唤限制未生效、且墓地存在2只以上可特殊召唤的「阴影」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：自己主要怪兽区的可用空格数在2个以上
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 发动条件检测：自己墓地存在2只以上可以特殊召唤的「阴影」怪兽
		and Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 设置操作信息：将从自己墓地特殊召唤2只怪兽（具体卡在效果处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
-- ②效果处理的前置检测：若自己主要怪兽区空格不足2个、受「青眼精灵龙」同时特殊召唤限制、或墓地可特殊召唤的「阴影」怪兽不足2只，则不处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测自己墓地中可特殊召唤的「阴影」怪兽（适用王家长眠之谷过滤）是否不足2只，不足则不处理
		or Duel.GetMatchingGroupCount(aux.NecroValleyFilter(s.ffilter),tp,LOCATION_GRAVE,0,nil,e,tp)<2 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己玩家从自己墓地选择2只可特殊召唤的「阴影」怪兽（适用王家长眠之谷过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.ffilter),tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 把选择的2只「阴影」怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
