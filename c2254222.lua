--SRウィング・シンクロン
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，可以发动。自己的灵摆区域1张风属性·2星的灵摆怪兽卡和这张卡破坏，从额外卡组把1只「幻透翼同调龙」当作同调召唤作特殊召唤。这个回合，自己的灵摆区域的卡不会被效果破坏，自己不是风属性怪兽不能特殊召唤。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡表侧加入额外卡组的场合，若自己场上的风属性同调怪兽的种族是2种类以上则能发动。从卡组把1张「疾行机人」魔法·陷阱卡送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果，注册灵摆属性和两个效果
function s.initial_effect(c)
	-- 记录该卡拥有「幻透翼同调龙」的卡名
	aux.AddCodeList(c,82044279)
	-- 为该卡添加灵摆怪兽属性，允许灵摆召唤和灵摆卡发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，可以发动。自己的灵摆区域1张风属性·2星的灵摆怪兽卡和这张卡破坏，从额外卡组把1只「幻透翼同调龙」当作同调召唤作特殊召唤。这个回合，自己的灵摆区域的卡不会被效果破坏，自己不是风属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡表侧加入额外卡组的场合，若自己场上的风属性同调怪兽的种族是2种类以上则能发动。从卡组把1张「疾行机人」魔法·陷阱卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查额外卡组中是否存在满足条件的「幻透翼同调龙」
function s.spfilter(c,e,tp)
	return c:IsCode(82044279) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查额外卡组中是否有足够的特殊召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 过滤函数，检查灵摆区域中是否存在满足条件的风属性2星灵摆怪兽
function s.desfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:GetOriginalAttribute()==ATTRIBUTE_WIND
		and c:GetOriginalLevel()==2
end
-- 设置特殊召唤效果的发动条件，检查是否满足破坏灵摆怪兽和检索同调怪兽的条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查灵摆区域是否存在满足条件的风属性2星灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
		-- 检查是否满足同调召唤的素材要求
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组中是否存在满足条件的「幻透翼同调龙」
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 获取玩家灵摆区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 设置连锁操作信息，提示将要破坏灵摆区域的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置连锁操作信息，提示将要特殊召唤同调怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行特殊召唤效果，破坏灵摆怪兽并从额外卡组特殊召唤「幻透翼同调龙」，并设置回合内灵摆区域卡不被破坏和不能特殊召唤非风属性怪兽的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否仍在灵摆区域且满足发动条件
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_PZONE) and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_PZONE,0,1,e:GetHandler()) then
		-- 获取玩家灵摆区域的所有卡
		local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
		-- 检查灵摆区域卡数量是否满足破坏条件并执行破坏
		if dg:GetCount()>=2 and Duel.Destroy(dg,REASON_EFFECT)==2 and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then
			-- 提示玩家选择要特殊召唤的同调怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从额外卡组中选择满足条件的「幻透翼同调龙」
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
			local tc=g:GetFirst()
			if tc then
				tc:SetMaterial(nil)
				-- 执行特殊召唤操作
				if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
					tc:CompleteProcedure()
				end
			end
		end
	end
	-- 设置回合内灵摆区域卡不被效果破坏的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_PZONE,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册灵摆区域卡不被效果破坏的效果
	Duel.RegisterEffect(e1,tp)
	-- 设置回合内不能特殊召唤非风属性怪兽的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤非风属性怪兽的效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制非风属性怪兽不能特殊召唤
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- 过滤函数，检查场上是否存在风属性同调怪兽
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 判断该卡是否在额外卡组且表侧表示
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()
end
-- 过滤函数，检查卡组中是否存在「疾行机人」魔法·陷阱卡
function s.tgfilter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 设置送去墓地效果的发动条件，检查卡组中是否存在「疾行机人」魔法·陷阱卡且场上风属性同调怪兽种族种类≥2
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查卡组中是否存在「疾行机人」魔法·陷阱卡
		if not Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) then return false end
		-- 获取场上所有风属性同调怪兽
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
		return g:GetClassCount(Card.GetRace)>=2
	end
	-- 设置连锁操作信息，提示将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行送去墓地效果，从卡组选择一张「疾行机人」魔法·陷阱卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择一张「疾行机人」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
