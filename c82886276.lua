--サイバネット・サーキット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「防火」连接怪兽为对象才能发动。从自己墓地选怪兽任意数量在要和作为对象的怪兽成为连接状态的自己或者对方场上特殊召唤。
-- ②：自己基本分是2000以下的场合，把墓地的这张卡除外才能发动。从自己墓地选1只「防火」连接怪兽回到额外卡组。那之后，可以把那只怪兽从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：以自己场上1只「防火」连接怪兽为对象才能发动。从自己墓地选怪兽任意数量在要和作为对象的怪兽成为连接状态的自己或者对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己基本分是2000以下的场合，把墓地的这张卡除外才能发动。从自己墓地选1只「防火」连接怪兽回到额外卡组。那之后，可以把那只怪兽从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tdcon)
	-- 设置效果②的发动代价为把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 计算并返回怪兽在指定位置时，其连接标记所指向的区域
function s.get_zone(c,seq)
	local zone=0
	if seq<4 and c:IsLinkMarker(LINK_MARKER_LEFT) then zone=bit.replace(zone,0x1,seq+1) end
	if seq>0 and seq<5 and c:IsLinkMarker(LINK_MARKER_RIGHT) then zone=bit.replace(zone,0x1,seq-1) end
	if seq==5 and c:IsLinkMarker(LINK_MARKER_TOP_LEFT) then zone=bit.replace(zone,0x1,2) end
	if seq==5 and c:IsLinkMarker(LINK_MARKER_TOP) then zone=bit.replace(zone,0x1,1) end
	if seq==5 and c:IsLinkMarker(LINK_MARKER_TOP_RIGHT) then zone=bit.replace(zone,0x1,0) end
	if seq==6 and c:IsLinkMarker(LINK_MARKER_TOP_LEFT) then zone=bit.replace(zone,0x1,4) end
	if seq==6 and c:IsLinkMarker(LINK_MARKER_TOP) then zone=bit.replace(zone,0x1,3) end
	if seq==6 and c:IsLinkMarker(LINK_MARKER_TOP_RIGHT) then zone=bit.replace(zone,0x1,2) end
	return zone
end
-- 过滤自己场上表侧表示的「防火」连接怪兽，且墓地存在能特殊召唤到其连接端的怪兽
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x18f)
		-- 检查自己墓地是否存在至少1只可以特殊召唤到该怪兽连接端的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
-- 过滤可以特殊召唤到目标怪兽连接端的怪兽
function s.spfilter(c,e,tp,tc)
	for p=0,1 do
		local zone=tc:GetLinkedZone(p)&0xff
		local seq=tc:GetSequence()
		if tc:IsControler(p) then zone=zone|s.get_zone(c,seq) end
		if tc:IsControler(1-p) and seq>=5 then
			seq=11-seq
			zone=zone|s.get_zone(c,seq)
		end
		-- 检查指定玩家场上在指定连接端区域是否有可用的怪兽区域
		if Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p,zone) then
			return true
		end
	end
end
-- 效果①的发动准备与目标选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc,e,tp) end
	-- 检查场上是否存在符合条件的可作为对象的「防火」连接怪兽
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择作为效果对象的目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「防火」连接怪兽作为对象
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤墓地怪兽的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①的处理函数，循环选择并特殊召唤怪兽到连接端
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的那只「防火」连接怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsFaceup() or not tc:IsRelateToEffect(e) then return end
	-- 获取自己墓地中所有可以特殊召唤到该怪兽连接端的怪兽（受王家长眠之谷影响）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,tc)
	while #g>0 do
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sc=g:Select(tp,1,1,nil):GetFirst()
		local avail_zone=0
		for p=0,1 do
			local zone=tc:GetLinkedZone(p)&0xff
			local seq=tc:GetSequence()
			if tc:IsControler(p) then zone=zone|s.get_zone(sc,seq) end
			if tc:IsControler(1-p) and seq>=5 then
				seq=11-seq
				zone=zone|s.get_zone(sc,seq)
			end
			-- 获取指定玩家场上在指定连接端区域的可用格子掩码
			local _,flag_tmp=Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
			local flag=(~flag_tmp)&0x7f
			if sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p,flag) then
				avail_zone=avail_zone|(flag<<(p==tp and 0 or 16))
			end
		end
		-- 让玩家选择要特殊召唤该怪兽的具体连接端格子
		local sel_zone=Duel.SelectField(tp,1,LOCATION_MZONE,LOCATION_MZONE,0x00ff00ff&(~avail_zone),sc:GetCode())
		local sump=0
		if sel_zone&0xff>0 then
			sump=tp
		else
			sump=1-tp
			sel_zone=sel_zone>>16
		end
		-- 将选中的怪兽特殊召唤到选定的玩家场上及区域（分步处理）
		Duel.SpecialSummonStep(sc,0,tp,sump,false,false,POS_FACEUP,sel_zone)
		-- 重新获取墓地中剩余可特殊召唤的怪兽组
		g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,tc)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) or #g==0
			-- 询问玩家是否继续特殊召唤下一只怪兽
			or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否继续特殊召唤？"
			break
		end
	end
	-- 完成所有分步特殊召唤的处理
	Duel.SpecialSummonComplete()
end
-- 效果②的发动条件判断函数
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的基本分是否在2000以下
	return Duel.GetLP(tp)<=2000
end
-- 过滤墓地中可以回到额外卡组的「防火」连接怪兽
function s.tdfilter(c)
	return c:IsSetCard(0x18f) and c:IsType(TYPE_LINK) and c:IsAbleToExtra()
end
-- 效果②的发动准备与目标检查
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可以回到额外卡组的「防火」连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置将墓地卡片送回额外卡组的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的处理函数，将怪兽送回额外卡组并可选地特殊召唤
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只「防火」连接怪兽
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽送回额外卡组
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		local tc=g:GetFirst()
		if tc:IsLocation(LOCATION_EXTRA)
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检查场上是否有可用于从额外卡组特殊召唤该怪兽的空格
			and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
			-- 询问玩家是否将那只怪兽从额外卡组特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把那只怪兽特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤不与返回额外卡组同时处理
			Duel.BreakEffect()
			-- 将该怪兽从额外卡组特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
