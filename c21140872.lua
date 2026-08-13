--真紅眼の黒刃竜
-- 效果：
-- 「真红眼黑龙」＋战士族怪兽
-- ①：「真红眼」怪兽的攻击宣言时以自己墓地1只战士族怪兽为对象才能发动。那只怪兽当作攻击力上升200的装备卡使用给这张卡装备。
-- ②：自己场上的卡为对象的卡的效果发动时，把自己场上1张装备卡送去墓地才能发动。那个发动无效并破坏。
-- ③：这张卡被战斗·效果破坏的场合才能发动。给这张卡装备的怪兽从自己墓地尽可能特殊召唤。
function c21140872.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，素材为「真红眼黑龙」（卡号74677422）与1只战士族怪兽，允许使用融合素材代用等。
	aux.AddFusionProcCodeFun(c,74677422,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),1,true,true)
	-- 「真红眼」怪兽的攻击宣言时以自己墓地1只战士族怪兽为对象才能发动。那只怪兽当作攻击力上升200的装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21140872,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c21140872.eqcon)
	e1:SetTarget(c21140872.eqtg)
	e1:SetOperation(c21140872.eqop)
	c:RegisterEffect(e1)
	-- 自己场上的卡为对象的卡的效果发动时，把自己场上1张装备卡送去墓地才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21140872,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCondition(c21140872.ngcon)
	e2:SetCost(c21140872.ngcost)
	e2:SetTarget(c21140872.ngtg)
	e2:SetOperation(c21140872.ngop)
	c:RegisterEffect(e2)
	-- 给这张卡装备的怪兽
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(c21140872.eqcheck)
	c:RegisterEffect(e4)
	-- 这张卡被战斗·效果破坏的场合才能发动。给这张卡装备的怪兽从自己墓地尽可能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21140872,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c21140872.spcon2)
	e3:SetTarget(c21140872.sptg2)
	e3:SetOperation(c21140872.spop2)
	e3:SetLabelObject(e4)
	c:RegisterEffect(e3)
end
c21140872.material_setcode=0x3b
-- 检查用于融合召唤的素材组是否满足「真红眼黑龙」+战士族怪兽的组合（顺序不限）。
function c21140872.red_eyes_fusion_check(tp,sg,fc)
	-- 返回检查结果：素材组同时包含卡号为74677422的「真红眼黑龙」和1只战士族怪兽，且顺序可互换。
	return aux.gffcheck(sg,Card.IsFusionCode,74677422,Card.IsRace,RACE_WARRIOR)
end
-- 效果发动条件：当前攻击宣言的怪兽是「真红眼」怪兽（字段0x3b）。
function c21140872.eqcon(e)
	-- 返回当前攻击宣言的怪兽是否属于「真红眼」系列。
	return Duel.GetAttacker():IsSetCard(0x3b)
end
-- 定义可装备的战士族怪兽筛选条件：战士族、怪兽、场上不重名、且非禁止卡。
function c21140872.eqfilter(c,tp)
	return c:IsRace(RACE_WARRIOR) and c:CheckUniqueOnField(tp) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- ①效果的目标选择函数：从自己墓地选择1只符合条件的战士族怪兽作为装备对象，并确认后场有空位。
function c21140872.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21140872.eqfilter(chkc,tp) end
	-- 发动时确认：自己墓地是否存在至少1只符合条件的战士族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c21140872.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		-- 并且确认自己的魔法·陷阱区域有空位，以便放置装备卡。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 向玩家显示选择装备卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己墓地选择1只符合条件的战士族怪兽，并设为效果对象。
	local g=Duel.SelectTarget(tp,c21140872.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
end
-- ①效果处理：将对象怪兽装备给这张卡，赋予攻击力上升200，并设置只能装备给这张卡的限制。
function c21140872.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理对象：之前选择的墓地战士族怪兽。
	local tc=Duel.GetFirstTarget()
	-- 当对象卡仍与效果关联且成功装备到这张卡上时，执行后续处理。
	if tc:IsRelateToEffect(e) and Duel.Equip(tp,tc,c) then
		-- 那只怪兽当作攻击力上升200的装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c21140872.eqlimit)
		e1:SetLabelObject(c)
		tc:RegisterEffect(e1)
		-- 攻击力上升200
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(200)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 装备限制条件：该装备卡只能装备给真红眼黑刃龙（标签对象）。
function c21140872.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 定义“自己场上的卡”的判断：卡片为己方控制且在场上。
function c21140872.ngcfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
end
-- ②效果发动条件：正在发动的效果是取对象效果，且对象中包含自己场上的卡，并且该连锁可以被无效。
function c21140872.ngcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁效果的对象卡组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 若对象卡组中存在己方场上的卡且该效果可被无效，则满足发动条件。
	return g and g:IsExists(c21140872.ngcfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- cost筛选：自己场上的装备卡（表侧表示或装备中的装备卡）且可以作为代价送去墓地。
function c21140872.ngfilter(c)
	return c:IsType(TYPE_EQUIP) and (c:IsFaceup() or c:GetEquipTarget()) and c:IsAbleToGraveAsCost()
end
-- cost操作：选择1张自己场上的装备卡送去墓地作为发动代价。
function c21140872.ngcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查：自己场上是否存在至少1张符合条件的装备卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c21140872.ngfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 显示选择要送去墓地的装备卡的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张自己场上的符合条件的装备卡。
	local g=Duel.SelectMatchingCard(tp,c21140872.ngfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选择的装备卡送去墓地，作为发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的目标设置：预告将使该发动无效并破坏其卡，无需选择额外对象。
function c21140872.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：对象为当前发动的效果，分类为无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若效果持有者卡可被破坏，则追加设置破坏的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果处理：无效该效果的发动，若此时原卡仍与其效果关联，则将其破坏。
function c21140872.ngop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果无效发动成功，且原效果所属卡仍与效果关联，则执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏那个被无效效果所属的卡（原因：效果）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 辅助效果：在这张卡离场前，记录它当前装备的卡组并保持其存活，供③效果使用。
function c21140872.eqcheck(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject() then e:GetLabelObject():DeleteGroup() end
	local g=e:GetHandler():GetEquipGroup()
	g:KeepAlive()
	e:SetLabelObject(g)
end
-- ③效果发动条件：这张卡被战斗或效果破坏。
function c21140872.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 特殊召唤对象筛选：之前装备的怪兽在自己墓地且可以被特殊召唤。
function c21140872.spfilter2(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的目标设置：从记录的装备卡中选出可特殊召唤的怪兽，并设为对象。
function c21140872.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject()
	-- 发动检查：己方主要怪兽区有空位才可发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g and g:IsExists(c21140872.spfilter2,1,nil,e,tp) end
	local sg=g:Filter(c21140872.spfilter2,nil,e,tp)
	-- 将筛选出的可特殊召唤怪兽组设为当前连锁对象。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：预告特殊召唤这些怪兽及数量。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,sg:GetCount(),0,0)
end
-- ③效果处理：从之前装备且仍关联的怪兽中，尽可能多地特殊召唤到己方主要怪兽区；若「青眼精灵龙」效果适用，则最多特殊召唤1只。
function c21140872.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象组，并过滤出仍与效果关联的怪兽。
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 计算己方主要怪兽区可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if sg:GetCount()>ft then
		-- 显示选择要特殊召唤的怪兽的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将选出的怪兽以表侧表示特殊召唤到己方场上。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
