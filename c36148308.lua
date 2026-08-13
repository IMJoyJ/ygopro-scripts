--命の奇跡
-- 效果：
-- 地属性同调怪兽才能装备。
-- ①：只在装备怪兽和对方怪兽进行战斗的伤害计算时，那只对方怪兽的攻击力下降1500。
-- ②：1回合1次，怪兽的表示形式变更的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：这张卡从魔法与陷阱区域送去墓地的场合，把自己场上1只「动力工具」同调怪兽解放才能发动。从额外卡组把1只「生命激流龙」当作同调召唤作特殊召唤。
local s,id=GetID()
-- 注册本卡的全部效果：作为装备魔法发动、装备对象限制、伤害计算时降低对方怪兽攻击力、怪兽表示形式变更时破坏场上1张卡、从魔法与陷阱区域送去墓地时解放「动力工具」同调怪兽特殊召唤「生命激流龙」。
function s.initial_effect(c)
	-- 地属性同调怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 地属性同调怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	-- 只在装备怪兽和对方怪兽进行战斗的伤害计算时，那只对方怪兽的攻击力下降1500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetValue(-1500)
	c:RegisterEffect(e3)
	-- 1回合1次，怪兽的表示形式变更的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"场上1张卡破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHANGE_POS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	-- 这张卡从魔法与陷阱区域送去墓地的场合，把自己场上1只「动力工具」同调怪兽解放才能发动。从额外卡组把1只「生命激流龙」当作同调召唤作特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetLabel(0)
	e5:SetCondition(s.spcon)
	e5:SetCost(s.spcost)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
-- 过滤器：判断怪兽是否为表侧表示、地属性、同调怪兽，用于选择可以装备的对象。
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_SYNCHRO)
end
-- 装备魔法的发动时处理：选择场上1只表侧表示的地属性同调怪兽作为装备对象，并设置装备操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 发动合法性检查：场上是否存在至少1只符合条件的表侧表示地属性同调怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家给出“选择要装备的卡”的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方怪兽区域选择1只表侧表示的地属性同调怪兽作为装备对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 将本卡登记为装备魔法卡的装备对象操作信息，供后续处理及效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备处理：若此卡和目标怪兽均与效果保持关联且目标仍表侧表示，则将此卡装备给该怪兽。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备魔法卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 装备限制：仅限地属性同调怪兽装备此卡。
function s.eqlimit(e,c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_SYNCHRO)
end
-- 攻击力下降效果的条件：只在伤害计算阶段，装备怪兽正在与对方怪兽进行战斗，且装备怪兽仍与战斗相关时适用。
function s.atkcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	-- 条件判断：当前为伤害计算阶段，存在装备怪兽，装备怪兽有战斗对象且未离开战斗。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and ec and ec:GetBattleTarget() and ec:IsRelateToBattle()
end
-- 指定攻击力下降的适用对象：装备怪兽正在进行战斗的对方怪兽。
function s.atktg(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	return c==ec:GetBattleTarget()
end
-- 破坏效果的目标选择：怪兽表示形式变更时，选择场上1张卡为破坏对象，并设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动合法性检查：场上是否存在至少1张可以被选择为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家给出“选择要破坏的卡”的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上选择1张卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 将所选卡登记为破坏的操作信息，破坏数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏处理：若选择的对象仍与效果关联，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前选择的破坏对象。
	local tc=Duel.GetFirstTarget()
	-- 验证对象仍与效果关联后，将其以效果破坏。
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
-- 特殊召唤效果的发动条件：此卡从魔法与陷阱区域（通常后场）送去墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousSequence()<5
end
-- 解放素材过滤器：选择1只「动力工具」同调怪兽作为解放对象，且确认额外卡组存在可特殊召唤的生命激流龙，并腾出额外怪兽区。
function s.cfilter(c,e,tp)
	return c:IsSetCard(0xc2) and c:IsType(TYPE_SYNCHRO)
		-- 确认解放该素材后，额外卡组有1只符合条件的「生命激流龙」可以特殊召唤。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 特殊召唤目标过滤器：目标必须是「生命激流龙」，能够以同调召唤方式特殊召唤，且解放素材后额外怪兽区有空位可出场。
function s.spfilter(c,e,tp,sc)
	return c:IsCode(25165047) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 在解放素材后，额外卡组的怪兽能有可用的额外怪兽区空格。
		and Duel.GetLocationCountFromEx(tp,tp,sc,c)>0
end
-- 解放代价：选择并解放自己场上1只「动力工具」同调怪兽作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只符合条件的「动力工具」同调怪兽可以解放。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,e,tp) end
	-- 向玩家给出“选择要解放的卡”的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从自己场上选择1只符合条件的「动力工具」同调怪兽。
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,e,tp)
	-- 将选中的怪兽解放，作为效果的发动代价。
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤效果的目标/发动条件：没有必须作为同调素材的限制，且已支付代价或额外有可特殊召唤的目标。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上不存在受到“必须作为同调素材”效果影响的怪兽，保证同调召唤合法。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 确认代价（解放）已执行，或额外卡组存在可特殊召唤的生命激流龙。
		and (e:IsCostChecked() or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)) end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 特殊召唤处理：若无素材限制，从额外卡组选择1只「生命激流龙」，当作同调召唤特殊召唤并完成同调召唤手续。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若仍存在必须作为同调素材的限制，则无法进行同调特殊召唤，直接结束处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 向玩家给出“选择要特殊召唤的卡”的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只符合条件的「生命激流龙」。
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	-- 若选择的「生命激流龙」以同调召唤方式特殊召唤成功，则执行CompleteProcedure完成同调召唤手续。
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end
