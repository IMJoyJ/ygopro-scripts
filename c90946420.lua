--百鬼羅刹大重畳
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只超量怪兽为对象才能发动。把1只「哥布林」超量怪兽在作为对象的自己的超量怪兽上面重叠当作超量召唤从额外卡组特殊召唤，把这张卡作为那超量素材。
-- ②：把墓地的这张卡除外，以自己场上1只「哥布林」超量怪兽和自己或对方的墓地1张卡为对象才能发动。把成为对象的墓地的卡作为成为对象的场上的怪兽的超量素材。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（场上超量怪兽重叠超量召唤额外卡组的「哥布林」超量怪兽）和②效果（墓地除外自身，将双方墓地的卡叠放到场上「哥布林」超量怪兽下作为素材）。
function s.initial_effect(c)
	-- ①：以自己场上1只超量怪兽为对象才能发动。把1只「哥布林」超量怪兽在作为对象的自己的超量怪兽上面重叠当作超量召唤从额外卡组特殊召唤，把这张卡作为那超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「哥布林」超量怪兽和自己或对方的墓地1张卡为对象才能发动。把成为对象的墓地的卡作为成为对象的场上的怪兽的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	-- 设置发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示、满足必须作为超量素材的限制、且额外卡组有可重叠召唤的「哥布林」超量怪兽的超量怪兽。
function s.filter(c,e,tp)
	-- 检查卡片是否为表侧表示的超量怪兽，且满足超量素材限制，并且额外卡组存在可重叠召唤的「哥布林」超量怪兽。
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 过滤额外卡组中可以以目标怪兽为素材进行超量召唤、且能特殊召唤的「哥布林」超量怪兽。
function s.filter2(c,e,tp,mc)
	return c:IsSetCard(0xac) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 检查在将作为素材的怪兽送去墓地或叠放后，额外怪兽区域或连接端是否有足够的空位用于特殊召唤。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ①效果的发动准备与合法性检查（Target函数），处理取对象和检查是否能将自身作为超量素材。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return e:GetHandler():IsCanOverlay()
		-- 检查自己场上是否存在满足条件的超量怪兽作为效果对象。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的超量怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的实际处理函数（Operation函数），执行重叠超量召唤并将这张卡作为超量素材。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的自己场上的超量怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查作为对象的怪兽是否满足必须作为超量素材的限制，若不满足则结束处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的「哥布林」超量怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将作为对象的怪兽原本持有的超量素材转移给新特殊召唤的「哥布林」超量怪兽。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将作为对象的怪兽重叠在新特殊召唤的「哥布林」超量怪兽下面作为超量素材。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选定的「哥布林」超量怪兽以超量召唤的形式特殊召唤，若特殊召唤成功则继续处理。
		if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
			if c:IsRelateToEffect(e) then
				c:CancelToGrave()
				-- 将这张卡（百鬼罗刹大重叠）作为该超量怪兽的超量素材。
				Duel.Overlay(sc,c)
			end
		end
	end
end
-- 过滤自己场上表侧表示的「哥布林」超量怪兽。
function s.mfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0xac)
end
-- 过滤可以作为超量素材且未被禁止使用的卡片。
function s.ofilter(c)
	return c:IsCanOverlay() and not c:IsForbidden()
end
-- ②效果的发动准备与合法性检查（Target函数），选择场上的「哥布林」超量怪兽和双方墓地的卡作为对象。
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查场上是否存在「哥布林」超量怪兽，且双方墓地是否存在可作为素材的卡。
	if chk==0 then return Duel.IsExistingTarget(s.mfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) and Duel.IsExistingTarget(s.ofilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择场上表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「哥布林」超量怪兽作为效果对象。
	local g1=Duel.SelectTarget(tp,s.mfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 提示玩家选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择自己或对方墓地的1张卡作为效果对象。
	local g2=Duel.SelectTarget(tp,s.ofilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息，表示有1张卡将离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,1,0,0)
end
-- ②效果的实际处理函数（Operation函数），将作为对象的墓地的卡重叠在作为对象的场上怪兽下面作为超量素材。
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此连锁中仍与效果相关的全部对象卡。
	local tg=Duel.GetTargetsRelateToChain()
	local tc1=tg:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
	local tc2=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	if tc1 and tc1:IsControler(tp) and tc2 then
		-- 将作为对象的墓地的卡作为超量素材重叠在作为对象的场上怪兽下面。
		Duel.Overlay(tc1,tc2)
	end
end
