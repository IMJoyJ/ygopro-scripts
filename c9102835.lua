--サラマンドラ・フュージョン
-- 效果：
-- 战士族·炎属性怪兽才能装备。这个卡名的③的效果1回合只能使用1次。
-- ①：装备怪兽的攻击力上升700。
-- ②：装备怪兽被战斗·效果破坏的场合，可以作为代替把这张卡破坏。
-- ③：这张卡给自己场上的融合怪兽装备中的场合才能发动。装备怪兽和这张卡送去墓地，把1只「炎之剑士」或者有那个卡名记述的融合怪兽当作融合召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包括装备卡发动、装备限制、代破效果、特殊召唤效果以及攻击力上升效果。
function s.initial_effect(c)
	-- 注册卡片效果文本中记载了「炎之剑士」（卡号45231177）。
	aux.AddCodeList(c,45231177)
	-- 战士族·炎属性怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 战士族·炎属性怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	-- ②：装备怪兽被战斗·效果破坏的场合，可以作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- ③：这张卡给自己场上的融合怪兽装备中的场合才能发动。装备怪兽和这张卡送去墓地，把1只「炎之剑士」或者有那个卡名记述的融合怪兽当作融合召唤从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	-- ①：装备怪兽的攻击力上升700。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetValue(700)
	c:RegisterEffect(e5)
end
s.fusion_effect=true
-- 装备限制判定函数，限定只能装备给战士族·炎属性怪兽。
function s.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 过滤场上表侧表示的战士族·炎属性怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 装备魔法卡发动时的效果目标选择与检测函数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 步骤0：检测场上是否存在可以作为装备对象的战士族·炎属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的战士族·炎属性怪兽作为装备对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理中的操作信息，表示将此卡装备。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的效果处理函数，将此卡装备给目标怪兽。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- 代替破坏效果的检测函数，判断装备怪兽是否因战斗或效果被破坏，且这张卡是否可以被破坏。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=c:GetEquipTarget()
	if chk==0 then return c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and tg and tg:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) end
	-- 询问玩家是否发动代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的处理函数，将这张卡破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏这张卡以代替装备怪兽的破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 过滤额外卡组中可以特殊召唤的「炎之剑士」或记述了该卡名的融合怪兽。
function s.ffilter(c,e,tp,qc)
	-- 判定卡片是否为融合怪兽，且是「炎之剑士」或有该卡名记述，并满足融合素材检测。
	return c:IsType(TYPE_FUSION) and (c:IsCode(45231177) or aux.IsCodeListed(c,45231177)) and c:CheckFusionMaterial()
		-- 判定卡片是否能以融合召唤的形式特殊召唤，且在送去装备怪兽后额外卡组怪兽出场的空格数大于0。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,qc,c)>0
end
-- 特殊召唤效果的发动准备与检测函数。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local qc=c:GetEquipTarget()
	-- 步骤0：检测是否存在装备怪兽，并进行必须作为融合素材的卡片检测。
	if chk==0 then return qc and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检测额外卡组是否存在满足条件的「炎之剑士」或记述了该卡名的融合怪兽。
		and Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,qc)
		and c:GetControler()==qc:GetControler() and qc:IsType(TYPE_FUSION)
		and qc:IsAbleToGrave() and c:IsAbleToGrave()
	end
	-- 设置连锁处理中的操作信息，表示将这张卡和装备怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,Group.FromCards(c,qc),2,0,0)
	-- 设置连锁处理中的操作信息，表示从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 特殊召唤效果的处理函数，将装备怪兽和此卡送去墓地，并从额外卡组特殊召唤目标怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local qc=c:GetEquipTarget()
	-- 将这张卡和装备怪兽送去墓地。
	Duel.SendtoGrave(Group.FromCards(c,qc),REASON_EFFECT)
	-- 获取刚刚被送去墓地的卡片组。
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	if ct~=2 then return false end
	-- 再次检测必须作为融合素材的卡片限制，若不满足则结束处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的融合怪兽。
	local sg=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=sg:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 将选择的怪兽当作融合召唤在场上表侧表示特殊召唤。
	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end
