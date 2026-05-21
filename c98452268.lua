--覇王黒竜オッドアイズ・リベリオン・ドラゴン－オーバーロード
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，自己主要阶段才能发动。这张卡特殊召唤，把1只「叛逆」怪兽或「幻影骑士团」怪兽在这张卡上面重叠当作超量召唤从额外卡组特殊召唤。那之后，可以把自己的灵摆区域1张卡作为那只怪兽的超量素材。
-- 【怪兽效果】
-- 7星怪兽×2
-- 自己对「霸王黑龙 异色眼叛逆龙-霸王」1回合只能有1次特殊召唤。这张卡也能在自己场上的「叛逆」超量怪兽上面重叠来超量召唤，7星可以灵摆召唤的场合在额外卡组的表侧的这张卡可以灵摆召唤。
-- ①：7阶超量怪兽为素材作超量召唤的这张卡在同1次的战斗阶段中可以作3次攻击。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c98452268.initial_effect(c)
	c:SetSPSummonOnce(98452268)
	aux.AddXyzProcedure(c,nil,7,2,c98452268.ovfilter,aux.Stringid(98452268,0))  --"是否在「叛逆」超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 为灵摆怪兽添加灵摆怪兽属性（不自动注册灵摆卡的发动效果）
	aux.EnablePendulumAttribute(c,false)
	-- ①：1回合1次，自己主要阶段才能发动。这张卡特殊召唤，把1只「叛逆」怪兽或「幻影骑士团」怪兽在这张卡上面重叠当作超量召唤从额外卡组特殊召唤。那之后，可以把自己的灵摆区域1张卡作为那只怪兽的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98452268,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c98452268.sptg)
	e1:SetOperation(c98452268.spop)
	c:RegisterEffect(e1)
	-- ①：7阶超量怪兽为素材作超量召唤的这张卡在同1次的战斗阶段中可以作3次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c98452268.regcon)
	e2:SetOperation(c98452268.regop)
	c:RegisterEffect(e2)
	-- ①：7阶超量怪兽为素材作超量召唤的这张卡在同1次的战斗阶段中可以作3次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c98452268.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ①：7阶超量怪兽为素材作超量召唤的这张卡在同1次的战斗阶段中可以作3次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetValue(2)
	e4:SetCondition(c98452268.effcon)
	c:RegisterEffect(e4)
	-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(98452268,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(c98452268.pencon)
	e5:SetTarget(c98452268.pentg)
	e5:SetOperation(c98452268.penop)
	c:RegisterEffect(e5)
end
c98452268.pendulum_level=7
-- 过滤场上表侧表示的「叛逆」超量怪兽（用于重叠超量召唤）
function c98452268.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x13b)
end
-- 过滤额外卡组中可以重叠在当前卡上进行超量召唤的「叛逆」或「幻影骑士团」超量怪兽
function c98452268.spfilter(c,e,tp,mc)
	return c:IsSetCard(0x13b,0x10db) and mc:IsCanBeXyzMaterial(c) and c:IsType(TYPE_XYZ)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and not c:IsCode(98452268)
		-- 检查在将当前卡作为素材时，额外卡组的该怪兽是否有可用的特殊召唤区域
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 灵摆效果①的发动准备与合法性检查
function c98452268.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家是否能进行2次特殊召唤，且怪兽区域有空位
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在必须作为超量素材的卡片限制
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在满足条件的「叛逆」或「幻影骑士团」超量怪兽
		and Duel.IsExistingMatchingCard(c98452268.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置特殊召唤的操作信息（包含自身特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤灵摆区域中可以作为超量素材的卡
function c98452268.matfilter(c,e)
	return c:IsCanOverlay() and not c:IsImmuneToEffect(e)
end
-- 灵摆效果①的效果处理（特殊召唤自身，重叠超量召唤额外卡组怪兽，并可选将灵摆区卡作为素材）
function c98452268.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Group.FromCards(c)
	-- 检查自身是否仍在灵摆区，并将其特殊召唤到场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查自身是否能作为超量素材
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从额外卡组选择1只满足条件的「叛逆」或「幻影骑士团」超量怪兽
		local g=Duel.SelectMatchingCard(tp,c98452268.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local tc=g:GetFirst()
		if tc then
			-- 中断当前效果处理，使后续的超量召唤与前述特殊召唤不视为同时处理
			Duel.BreakEffect()
			tc:SetMaterial(mg)
			-- 将特殊召唤的自身重叠作为所选怪兽的超量素材
			Duel.Overlay(tc,mg)
			-- 将所选怪兽以超量召唤的方式特殊召唤
			if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
				tc:CompleteProcedure()
				-- 检查自己的灵摆区域是否存在可以作为超量素材的卡
				if Duel.IsExistingMatchingCard(c98452268.matfilter,tp,LOCATION_PZONE,0,1,nil,e)
					-- 询问玩家是否选择自己的灵摆区域1张卡作为超量素材
					and Duel.SelectYesNo(tp,aux.Stringid(98452268,3)) then  --"是否选自己的灵摆区域1张卡作为超量素材？"
					-- 中断当前效果处理，使后续的重叠素材处理与超量召唤不视为同时处理
					Duel.BreakEffect()
					-- 提示玩家选择要作为超量素材的卡
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
					-- 玩家选择灵摆区域的1张卡
					local sg=Duel.SelectMatchingCard(tp,c98452268.matfilter,tp,LOCATION_PZONE,0,1,1,nil,e)
					-- 选中所选的灵摆卡并显示选中动画
					Duel.HintSelection(sg)
					-- 将所选的灵摆卡重叠作为该怪兽的超量素材
					Duel.Overlay(tc,sg)
				end
			end
		end
	end
end
-- 过滤7阶超量怪兽（用于检查超量素材）
function c98452268.mfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsRank(7)
end
-- 检查超量素材中是否存在7阶超量怪兽，并为注册效果设置标记
function c98452268.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(c98452268.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 检查自身是否是以7阶超量怪兽为素材进行的超量召唤
function c98452268.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
-- 为自身注册已满足“7阶超量怪兽为素材作超量召唤”条件的Flag标记
function c98452268.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(98452268,RESET_EVENT+RESETS_STANDARD,0,1)
	c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(98452268,4))  --"7阶超量怪兽为素材作超量召唤"
end
-- 检查自身是否具有满足“7阶超量怪兽为素材作超量召唤”条件的Flag标记
function c98452268.effcon(e)
	return e:GetHandler():GetFlagEffect(98452268)>0
end
-- 检查自身是否在怪兽区域被破坏且表侧表示
function c98452268.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 检查灵摆区域是否有空位以放置这张卡
function c98452268.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查左侧或右侧的灵摆区域是否可用
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 将被破坏的自身移动到自己的灵摆区域
function c98452268.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示放置在自己的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
