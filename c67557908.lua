--No.4 猛毒刺胞ステルス・クラーゲン
-- 效果：
-- 水属性4星怪兽×2
-- ①：场上的表侧表示怪兽变成水属性。
-- ②：1回合1次，自己·对方的主要阶段才能发动。对方场上1只水属性怪兽破坏，给与对方那个攻击力一半数值的伤害。
-- ③：超量召唤的这张卡被破坏的场合才能发动。把最多有这张卡持有的超量素材数量的「隐形水母怪碟状幼体」从额外卡组特殊召唤。并且可以再给那些特殊召唤的怪兽各从自己墓地把最多1只水属性怪兽作为那超量素材。
function c67557908.initial_effect(c)
	-- 添加超量召唤手续：水属性4星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),4,2)
	c:EnableReviveLimit()
	-- ①：场上的表侧表示怪兽变成水属性。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 过滤场上表侧表示的怪兽作为效果对象
	e1:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	e1:SetValue(ATTRIBUTE_WATER)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己·对方的主要阶段才能发动。对方场上1只水属性怪兽破坏，给与对方那个攻击力一半数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67557908,0))  --"水属性怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(c67557908.descon)
	e2:SetTarget(c67557908.destg)
	e2:SetOperation(c67557908.desop)
	c:RegisterEffect(e2)
	-- ③：超量召唤的这张卡被破坏的场合才能发动。把最多有这张卡持有的超量素材数量的「隐形水母怪碟状幼体」从额外卡组特殊召唤。并且可以再给那些特殊召唤的怪兽各从自己墓地把最多1只水属性怪兽作为那超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67557908,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c67557908.spcon)
	e3:SetTarget(c67557908.sptg)
	e3:SetOperation(c67557908.spop)
	c:RegisterEffect(e3)
end
-- 设定该怪兽的“No.”编号为4
aux.xyz_number[67557908]=4
-- 效果②的发动条件：自己或对方的主要阶段
function c67557908.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤对方场上的表侧表示水属性怪兽
function c67557908.desfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果②的发动准备与目标确认（破坏与伤害效果）
function c67557908.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67557908.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示的水属性怪兽
	local g=Duel.GetMatchingGroup(c67557908.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁处理信息：破坏对方场上的1只水属性怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁处理信息：给与对方生命值伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果②的实际处理：破坏选中的怪兽并给与对方其攻击力一半的伤害
function c67557908.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1只表侧表示的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c67557908.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 选中卡片并向双方玩家展示
	Duel.HintSelection(g)
	local dam=math.floor(tc:GetAttack()/2)
	-- 尝试因效果破坏选中的怪兽，若成功则继续处理
	if Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给与对方该怪兽攻击力一半数值的伤害
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
-- 效果③的发动条件：超量召唤的这张卡被破坏，且被破坏时持有超量素材
function c67557908.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetPreviousOverlayCountOnField()
	e:SetLabel(ct)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ) and ct>0
end
-- 过滤额外卡组中可以特殊召唤的「隐形水母怪碟状幼体」
function c67557908.spfilter(c,e,tp)
	return c:IsCode(94942656) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备与目标确认（特殊召唤效果）
function c67557908.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外怪兽区域或可用区域是否有空位用于特殊召唤超量怪兽
	if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)>0
		-- 且额外卡组中存在至少1只可特殊召唤的「隐形水母怪碟状幼体」
		and Duel.IsExistingMatchingCard(c67557908.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁处理信息：从额外卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤墓地中可以作为超量素材的水属性怪兽
function c67557908.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanOverlay()
end
-- 效果③的实际处理：特殊召唤「隐形水母怪碟状幼体」并为其补充超量素材
function c67557908.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组怪兽可特殊召唤的区域数量
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)
	if ft<=0 then return end
	ft=math.min(ft,e:GetLabel())
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 检测是否有其他限制特殊召唤数量的效果生效
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	if ect~=nil then ft=math.min(ft,ect) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择最多等同于原素材数量且不超过区域限制的「隐形水母怪碟状幼体」
	local g=Duel.SelectMatchingCard(tp,c67557908.spfilter,tp,LOCATION_EXTRA,0,1,ft,nil,e,tp)
	-- 将选中的怪兽以表侧表示特殊召唤，若成功则继续处理
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取本次操作中成功特殊召唤到怪兽区域的怪兽组
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_MZONE)
		-- 获取自己墓地中不受「王家长眠之谷」影响的水属性怪兽组
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c67557908.matfilter),tp,LOCATION_GRAVE,0,nil)
		local res=false
		local tc=og:GetFirst()
		while tc do
			if sg:GetCount()==0 then return end
			-- 询问玩家是否要为该特殊召唤的怪兽补充超量素材
			if Duel.SelectEffectYesNo(tp,tc,aux.Stringid(67557908,2)) then  --"是否为此怪兽补充超量素材？"
				if res==false then
					res=true
					-- 中断当前效果处理，使后续的重叠素材处理与特殊召唤不视为同时进行
					Duel.BreakEffect()
				end
				-- 提示玩家选择要作为超量素材的卡片
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
				local tg=sg:Select(tp,1,1,nil)
				-- 将选中的墓地怪兽作为超量素材重叠在对应的超量怪兽下
				Duel.Overlay(tc,tg)
				sg:Sub(tg)
			end
			tc=og:GetNext()
		end
	end
end
