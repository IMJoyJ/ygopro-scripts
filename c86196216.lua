--RUM－デス・ダブル・フォース
-- 效果：
-- ①：以这个回合被战斗破坏送去自己墓地的1只「急袭猛禽」超量怪兽为对象才能发动。那只怪兽特殊召唤，那只怪兽的2倍阶级的1只超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c86196216.initial_effect(c)
	-- ①：以这个回合被战斗破坏送去自己墓地的1只「急袭猛禽」超量怪兽为对象才能发动。那只怪兽特殊召唤，那只怪兽的2倍阶级的1只超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_DESTROY+TIMING_END_PHASE)
	e1:SetTarget(c86196216.target)
	e1:SetOperation(c86196216.activate)
	c:RegisterEffect(e1)
	if not c86196216.globle_check then
		c86196216.globle_check=true
		-- ①：以这个回合被战斗破坏送去自己墓地的1只「急袭猛禽」超量怪兽为对象才能发动。那只怪兽特殊召唤，那只怪兽的2倍阶级的1只超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c86196216.checkop)
		-- 注册全局环境效果，用于记录本回合被战斗破坏送去墓地的怪兽
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查送去墓地的卡是否为本回合被战斗破坏的「急袭猛禽」超量怪兽，并给其注册标记
function c86196216.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsSetCard(0xba) and tc:IsType(TYPE_XYZ) and tc:IsReason(REASON_DESTROY) and tc:IsReason(REASON_BATTLE) then
			tc:RegisterFlagEffect(86196216,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end
-- 过滤自己墓地中本回合被战斗破坏的「急袭猛禽」超量怪兽，且额外卡组存在可重叠超量召唤的怪兽
function c86196216.filter1(c,e,tp)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetFlagEffect(86196216)~=0
		-- 检查额外卡组是否存在阶级为该怪兽2倍且能以其为素材进行超量召唤的怪兽
		and Duel.IsExistingMatchingCard(c86196216.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()*2)
end
-- 过滤额外卡组中满足阶级为指定数值、可将目标怪兽作为超量素材、且能特殊召唤的超量怪兽
function c86196216.filter2(c,e,tp,mc,rk)
	return c:IsRank(rk) and mc:IsCanBeXyzMaterial(c)
		-- 检查该超量怪兽是否可以进行超量召唤，以及额外卡组怪兽出场所需的怪兽区域空格是否足够
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动时的对象选择与可行性检查
function c86196216.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c86196216.filter1(chkc,e,tp) end
	-- 检查玩家是否能进行2次特殊召唤（苏生墓地怪兽和额外卡组超量召唤）
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查自己场上是否有可用于特殊召唤怪兽的空闲怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在必须作为超量素材的限制效果
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查自己墓地是否存在满足条件的可选择为对象的「急袭猛禽」超量怪兽
		and Duel.IsExistingTarget(c86196216.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「急袭猛禽」超量怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c86196216.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理的操作信息为“特殊召唤2只怪兽（包含额外卡组的怪兽）”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,LOCATION_EXTRA)
end
-- 效果发动后的处理逻辑（特殊召唤墓地怪兽并重叠超量召唤额外卡组怪兽）
function c86196216.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空闲的怪兽区域，若无则无法继续处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取作为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	-- 将作为对象的怪兽以表侧表示特殊召唤，若特殊召唤失败则结束处理
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 检查该怪兽是否满足作为超量素材的限制条件
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 提示玩家选择要从额外卡组特殊召唤的超量怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只阶级为对象怪兽2倍且能以其为素材的超量怪兽
	local g=Duel.SelectMatchingCard(tp,c86196216.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()*2)
	local sc=g:GetFirst()
	if sc then
		-- 中断当前效果处理，使后续的超量召唤与前一步的特殊召唤不视为同时处理
		Duel.BreakEffect()
		sc:SetMaterial(Group.FromCards(tc))
		-- 将特殊召唤的墓地怪兽重叠作为所选择超量怪兽的超量素材
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将该超量怪兽以超量召唤的形式表侧表示特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
