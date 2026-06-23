--真紅眼の黒刃竜
-- 效果：
-- 「真红眼黑龙」＋战士族怪兽
-- ①：「真红眼」怪兽的攻击宣言时以自己墓地1只战士族怪兽为对象才能发动。那只怪兽当作攻击力上升200的装备卡使用给这张卡装备。
-- ②：自己场上的卡为对象的卡的效果发动时，把自己场上1张装备卡送去墓地才能发动。那个发动无效并破坏。
-- ③：这张卡被战斗·效果破坏的场合才能发动。给这张卡装备的怪兽从自己墓地尽可能特殊召唤。
function c21140872.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用真红眼黑龙（74677422）和1只战士族怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,74677422,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),1,true,true)
	-- ①：「真红眼」怪兽的攻击宣言时以自己墓地1只战士族怪兽为对象才能发动。那只怪兽当作攻击力上升200的装备卡使用给这张卡装备。
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
	-- ②：自己场上的卡为对象的卡的效果发动时，把自己场上1张装备卡送去墓地才能发动。那个发动无效并破坏。
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
	-- ③：这张卡被战斗·效果破坏的场合才能发动。给这张卡装备的怪兽从自己墓地尽可能特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(c21140872.eqcheck)
	c:RegisterEffect(e4)
	-- 融合召唤时检查融合素材是否满足条件：1只真红眼怪兽和1只战士族怪兽
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
-- 融合召唤时检查融合素材是否满足条件：1只真红眼怪兽和1只战士族怪兽
function c21140872.red_eyes_fusion_check(tp,sg,fc)
	-- 融合召唤时检查融合素材是否满足条件：1只真红眼怪兽和1只战士族怪兽
	return aux.gffcheck(sg,Card.IsFusionCode,74677422,Card.IsRace,RACE_WARRIOR)
end
-- 攻击宣言时判断攻击怪兽是否为真红眼族
function c21140872.eqcon(e)
	-- 攻击宣言时判断攻击怪兽是否为真红眼族
	return Duel.GetAttacker():IsSetCard(0x3b)
end
-- 装备卡选择过滤器，筛选墓地中的战士族怪兽
function c21140872.eqfilter(c,tp)
	return c:IsRace(RACE_WARRIOR) and c:CheckUniqueOnField(tp) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 装备效果的发动条件判断，检查是否有满足条件的墓地战士族怪兽和装备区域
function c21140872.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21140872.eqfilter(chkc,tp) end
	-- 装备效果的发动条件判断，检查是否有满足条件的墓地战士族怪兽
	if chk==0 then return Duel.IsExistingTarget(c21140872.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		-- 装备效果的发动条件判断，检查是否有装备区域
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的墓地战士族怪兽作为装备卡
	local g=Duel.SelectTarget(tp,c21140872.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
end
-- 装备效果的处理流程，将选中的怪兽装备给自身并设置装备限制和攻击力加成
function c21140872.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效并执行装备操作
	if tc:IsRelateToEffect(e) and Duel.Equip(tp,tc,c) then
		-- 设置装备限制效果，确保只能装备给自身
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c21140872.eqlimit)
		e1:SetLabelObject(c)
		tc:RegisterEffect(e1)
		-- 设置装备攻击力加成效果，使装备怪兽攻击力上升200
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(200)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 装备限制效果的判断函数，确保只能装备给自身
function c21140872.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 连锁效果的目标过滤器，筛选玩家场上的卡
function c21140872.ngcfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
end
-- 连锁无效效果的发动条件判断，检查是否为取对象效果且目标包含玩家场上的卡
function c21140872.ngcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁的目标卡组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 连锁无效效果的发动条件判断，检查是否为取对象效果且目标包含玩家场上的卡
	return g and g:IsExists(c21140872.ngcfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 无效效果的消耗卡筛选器，筛选场上可送去墓地的装备卡
function c21140872.ngfilter(c)
	return c:IsType(TYPE_EQUIP) and (c:IsFaceup() or c:GetEquipTarget()) and c:IsAbleToGraveAsCost()
end
-- 无效效果的发动条件判断，检查是否有满足条件的场上装备卡
function c21140872.ngcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 无效效果的发动条件判断，检查是否有满足条件的场上装备卡
	if chk==0 then return Duel.IsExistingMatchingCard(c21140872.ngfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的装备卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的场上装备卡作为消耗
	local g=Duel.SelectMatchingCard(tp,c21140872.ngfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选中的装备卡送去墓地作为消耗
	Duel.SendtoGrave(g,REASON_COST)
end
-- 无效效果的目标设定，设置无效和破坏的处理信息
function c21140872.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏效果的处理信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效效果的处理流程，使连锁发动无效并破坏目标卡
function c21140872.ngop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否可以被无效且目标卡是否有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 离开场上的处理流程，记录当前装备卡组
function c21140872.eqcheck(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject() then e:GetLabelObject():DeleteGroup() end
	local g=e:GetHandler():GetEquipGroup()
	g:KeepAlive()
	e:SetLabelObject(g)
end
-- 特殊召唤效果的发动条件判断，检查是否为战斗或效果破坏
function c21140872.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 特殊召唤的过滤器，筛选墓地中的可特殊召唤怪兽
function c21140872.spfilter2(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标设定，检查是否有满足条件的墓地怪兽和召唤区域
function c21140872.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject()
	-- 特殊召唤效果的目标设定，检查是否有召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g and g:IsExists(c21140872.spfilter2,1,nil,e,tp) end
	local sg=g:Filter(c21140872.spfilter2,nil,e,tp)
	-- 设置特殊召唤的目标卡
	Duel.SetTargetCard(sg)
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,sg:GetCount(),0,0)
end
-- 特殊召唤效果的处理流程，将装备的怪兽特殊召唤
function c21140872.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标卡组并筛选有效的卡
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 获取玩家的召唤区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if sg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将选中的卡特殊召唤到场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
