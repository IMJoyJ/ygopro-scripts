--覇王天龍オッドアイズ・アークレイ・ドラゴン
-- 效果：
-- ←13 【灵摆】 13→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己的灵摆区域有2张卡存在的场合才能发动。这张卡特殊召唤。那之后，以下可以适用。
-- ●自己的灵摆区域1张卡回到卡组。回到自己的额外卡组的场合，可以再把那只怪兽无视召唤条件特殊召唤。
-- 【怪兽效果】
-- 龙族的融合·同调·超量·灵摆怪兽各1只合计4只
-- 这个卡名在规则上当作「霸王龙 扎克」使用。额外卡组的里侧的这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把自己场上1只暗属性·12星的「霸王龙 扎克」解放的场合可以特殊召唤。
-- ①：这张卡从额外卡组特殊召唤的场合才能发动。从卡组把1只灵摆怪兽在自己的灵摆区域放置。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c6218704.initial_effect(c)
	-- 注册该卡在卡片效果中记载了「霸王龙 扎克」的卡片密码
	aux.AddCodeList(c,13331639)
	c:EnableReviveLimit()
	-- 注册融合召唤素材：龙族的融合、同调、超量、灵摆怪兽各1只合计4只，且不能使用融合代替素材
	aux.AddFusionProcMix(c,false,true,c6218704.fusfilter1,c6218704.fusfilter2,c6218704.fusfilter3,c6218704.fusfilter4)
	-- 注册灵摆怪兽属性，但不注册灵摆卡“卡的发动”的效果
	aux.EnablePendulumAttribute(c,false)
	-- 额外卡组的里侧的这张卡用融合召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c6218704.splimit)
	c:RegisterEffect(e1)
	-- ●把自己场上1只暗属性·12星的「霸王龙 扎克」解放的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c6218704.hspcon)
	e2:SetTarget(c6218704.hsptg)
	e2:SetOperation(c6218704.hspop)
	c:RegisterEffect(e2)
	-- ①：自己的灵摆区域有2张卡存在的场合才能发动。这张卡特殊召唤。那之后，以下可以适用。●自己的灵摆区域1张卡回到卡组。回到自己的额外卡组的场合，可以再把那只怪兽无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(6218704,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,6218704)
	e3:SetCondition(c6218704.pcon)
	e3:SetTarget(c6218704.ptg)
	e3:SetOperation(c6218704.pop)
	c:RegisterEffect(e3)
	-- ①：这张卡从额外卡组特殊召唤的场合才能发动。从卡组把1只灵摆怪兽在自己的灵摆区域放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(6218704,3))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c6218704.setcon)
	e4:SetTarget(c6218704.settg)
	e4:SetOperation(c6218704.setop)
	c:RegisterEffect(e4)
	-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(6218704,4))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(c6218704.pencon)
	e5:SetTarget(c6218704.pentg)
	e5:SetOperation(c6218704.penop)
	c:RegisterEffect(e5)
end
c6218704.material_type=TYPE_SYNCHRO
-- 融合素材过滤条件1：龙族的融合怪兽
function c6218704.fusfilter1(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_FUSION)
end
-- 融合素材过滤条件2：龙族的同调怪兽
function c6218704.fusfilter2(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_SYNCHRO)
end
-- 融合素材过滤条件3：龙族的超量怪兽
function c6218704.fusfilter3(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_XYZ)
end
-- 融合素材过滤条件4：龙族的灵摆怪兽
function c6218704.fusfilter4(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_PENDULUM)
end
-- 限制额外卡组里侧表示的这张卡只能通过融合召唤或自身特召规则来特殊召唤
function c6218704.splimit(e,se,sp,st)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION end
	return true
end
-- 自身特召规则的解放怪兽过滤：自己场上暗属性、12星的「霸王龙 扎克」
function c6218704.hspfilter(c,tp,sc)
	return c:IsCode(13331639) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(12)
		-- 检查该怪兽是否由自己控制、解放后额外卡组是否有可用怪兽区域，且该怪兽可作为特殊召唤的素材
		and c:IsControler(tp) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 自身特召规则的特殊召唤条件：这张卡在额外卡组里侧表示，且场上存在可解放的满足条件的怪兽
function c6218704.hspcon(e,c)
	if c==nil then return true end
	-- 检查这张卡是否在额外卡组里侧表示，且场上是否存在至少1只可解放的暗属性·12星「霸王龙 扎克」
	return c:IsFacedown() and Duel.CheckReleaseGroupEx(c:GetControler(),c6218704.hspfilter,1,REASON_SPSUMMON,false,nil,c:GetControler(),c)
end
-- 自身特召规则的释放目标选择：让玩家选择1只满足条件的怪兽解放
function c6218704.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可解放的、满足特召条件的「霸王龙 扎克」怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c6218704.hspfilter,nil,tp,c)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 自身特召规则的执行：将选择的怪兽设为素材并解放，然后特殊召唤这张卡
function c6218704.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	-- 解放选中的怪兽
	Duel.Release(tc,REASON_SPSUMMON)
end
-- 灵摆效果发动条件：自己的灵摆区域有2张卡存在
function c6218704.pcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的灵摆区域卡片数量是否大于等于2
	return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>=2
end
-- 灵摆效果发动准备：检查怪兽区域是否有空位且这张卡能否特殊召唤，并注册特殊召唤的操作信息
function c6218704.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空怪兽区域，以及这张卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，包含这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 灵摆效果处理：特殊召唤这张卡，之后可以适用“灵摆区域1张卡回到卡组，若回到额外卡组则无视召唤条件特召”的效果
function c6218704.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果相关，并将其以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取自己灵摆区域中可以回到卡组的卡片组
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_PZONE,0,nil)
		-- 如果有可回到卡组的卡，询问玩家是否适用“灵摆区域1张卡回到卡组”的效果
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(6218704,1)) then  --"是否把自己的灵摆区域1张卡回到卡组？"
			-- 中断当前效果处理，使后续的回到卡组处理与特殊召唤不视为同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要返回卡组的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local sc=g:Select(tp,1,1,nil):GetFirst()
			-- 将选中的卡送回卡组（或额外卡组），并检查该卡是否成功回到自己的额外卡组
			if sc and Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_EXTRA) and sc:IsControler(tp)
				-- 检查该怪兽是否可以无视召唤条件特殊召唤，且额外卡组怪兽出场区域是否有空位
				and sc:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,sc)>0
				-- 询问玩家是否将那只怪兽无视召唤条件特殊召唤
				and Duel.SelectYesNo(tp,aux.Stringid(6218704,2)) then  --"是否把那只怪兽无视召唤条件特殊召唤？"
				-- 中断当前效果处理，使后续的特殊召唤处理与回到额外卡组不视为同时处理
				Duel.BreakEffect()
				-- 将该怪兽无视召唤条件以表侧表示特殊召唤
				Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
			end
		end
	end
end
-- 效果①的发动条件：这张卡是从额外卡组特殊召唤的
function c6218704.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 效果①的放置卡片过滤：卡组中的灵摆怪兽且不能是无法放置的卡
function c6218704.setfilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 效果①的发动准备：检查自己的灵摆区域是否有空位，且卡组中是否存在可放置的灵摆怪兽
function c6218704.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的左或右灵摆区域是否有空位
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 检查卡组中是否存在至少1只可放置的灵摆怪兽
		and Duel.IsExistingMatchingCard(c6218704.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果①的效果处理：从卡组选择1只灵摆怪兽放置在自己的灵摆区域
function c6218704.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查灵摆区域是否仍有空位，若无则不处理
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从卡组选择1只满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c6218704.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的灵摆怪兽移动并表侧表示放置到自己的灵摆区域
	if Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,false) then
		tc:SetStatus(STATUS_EFFECT_ENABLED,true)
	end
end
-- 效果②的发动条件：这张卡在怪兽区域被破坏，且在被破坏前是表侧表示
function c6218704.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 效果②的发动准备：检查自己的灵摆区域是否有空位
function c6218704.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的左或右灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 效果②的效果处理：将这张卡放置在自己的灵摆区域
function c6218704.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡移动并表侧表示放置到自己的灵摆区域，并立刻适用其效果
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
