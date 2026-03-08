--獄神影機－ゼグレド
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡和自己的手卡·场上（表侧表示）1只「狱神」怪兽或「终刻」怪兽破坏。那之后，可以把场上1张卡破坏。
-- 【怪兽效果】
-- 这个卡名在规则上也当作「终刻」卡使用。这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：从卡组上面把3张卡里侧除外才能发动。这张卡破坏，从额外卡组把1只「坏狱神 朱庇特」当作超量召唤作特殊召唤。那之后，可以选自己1张手卡作为那超量素材。
-- ②：这张卡表侧加入额外卡组的场合才能发动。从卡组把1张「狱神」魔法·陷阱卡或「终刻」魔法·陷阱卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册灵摆和怪兽效果
function s.initial_effect(c)
	-- 将卡片效果注册为「坏狱神 朱庇特」（68231287）
	aux.AddCodeList(c,68231287)
	-- 为卡片添加灵摆属性，使其可以灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- 设置灵摆效果①：自己主要阶段才能发动。这张卡和自己的手卡·场上（表侧表示）1只「狱神」怪兽或「终刻」怪兽破坏。那之后，可以把场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 设置怪兽效果①：从卡组上面把3张卡里侧除外才能发动。这张卡破坏，从额外卡组把1只「坏狱神 朱庇特」当作超量召唤作特殊召唤。那之后，可以选自己1张手卡作为那超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 设置怪兽效果②：这张卡表侧加入额外卡组的场合才能发动。从卡组把1张「狱神」魔法·陷阱卡或「终刻」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索效果"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_DECK)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 定义灵摆效果的破坏目标筛选函数，用于判断手卡或场上的「狱神」或「终刻」怪兽是否满足条件
function s.desfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1ce,0x1d2)
		and c:IsType(TYPE_MONSTER)
end
-- 定义手卡中可破坏的「狱神」或「终刻」怪兽筛选函数，用于判断是否手卡中有公开的「狱神」或「终刻」怪兽
function s.hdesfilter(c)
	return c:IsSetCard(0x1ce,0x1d2) and c:IsType(TYPE_MONSTER) and c:IsPublic()
end
-- 设置灵摆效果①的目标函数，检查是否有满足条件的破坏对象并设置操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有满足条件的破坏对象
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c) end
	-- 获取满足条件的破坏对象组
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,c)
	g:AddCard(c)
	-- 检查是否有未公开的卡
	if Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,LOCATION_HAND,0,1,nil)
		-- 或检查是否有公开的卡
		or Duel.IsExistingMatchingCard(s.hdesfilter,tp,LOCATION_HAND,0,1,nil) then
		-- 设置操作信息为破坏1张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	else
		-- 设置操作信息为破坏2张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	end
end
-- 设置灵摆效果①的处理函数，执行破坏操作并询问是否再破坏一张场上的卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的破坏对象
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,c)
	if #g>0 then
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then
			-- 显示选中对象的动画效果
			Duel.HintSelection(g)
		end
		g:AddCard(c)
		-- 执行破坏操作，破坏目标卡组
		if Duel.Destroy(g,REASON_EFFECT)==2
			-- 检查场上是否有卡可以破坏
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否破坏场上的卡
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把场上的卡破坏？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择场上要破坏的卡
			local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			-- 显示选中对象的动画效果
			Duel.HintSelection(dg)
			-- 执行破坏操作，破坏目标卡
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
-- 设置怪兽效果①的费用函数，从卡组顶部除外3张卡作为费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组顶部的3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3
		-- 检查卡组中是否有至少3张卡
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
	-- 禁止自动洗切卡组
	Duel.DisableShuffleCheck()
	-- 将卡组顶部的3张卡除外作为费用
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 定义特殊召唤的筛选函数，用于判断额外卡组中是否有符合条件的「坏狱神 朱庇特」
function s.spfilter(c,e,tp,mc)
	return c:IsType(TYPE_XYZ) and c:IsCode(68231287)
		-- 检查是否有足够的召唤位置和是否可以特殊召唤
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置怪兽效果①的目标函数，检查是否有满足条件的特殊召唤对象并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足必须成为超量素材的条件
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查是否有满足条件的特殊召唤对象
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置操作信息为破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义超量素材的筛选函数，用于判断手卡中是否有可叠放的卡
function s.matfilter(c)
	return c:IsCanOverlay()
end
-- 设置怪兽效果①的处理函数，执行特殊召唤并询问是否将手卡作为超量素材
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否与连锁相关联或是否被破坏
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 检查是否满足必须成为超量素材的条件
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的特殊召唤对象
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 执行特殊召唤操作
	if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:CompleteProcedure()
		-- 检查是否有可作为超量素材的手卡
		if Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_HAND,0,1,nil)
			-- 询问玩家是否将手卡作为超量素材
			and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否把手卡作为超量素材？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要作为超量素材的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
			-- 选择满足条件的超量素材
			local mg=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_HAND,0,1,1,nil)
			if mg:GetCount()>0 then
				-- 将选中的卡叠放至目标怪兽上
				Duel.Overlay(tc,mg)
			end
		end
	end
end
-- 设置怪兽效果②的发动条件，检查卡片是否在额外卡组且表侧表示
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA)
		and c:IsFaceup()
end
-- 定义检索的筛选函数，用于判断卡组中是否有符合条件的「狱神」或「终刻」魔法·陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x1ce,0x1d2) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置怪兽效果②的目标函数，检查是否有满足条件的检索对象并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的检索对象
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 设置怪兽效果②的处理函数，执行检索并确认卡牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的检索对象
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到选中的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
