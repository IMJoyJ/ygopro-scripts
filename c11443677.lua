--ブルーアイズ・タイラント・ドラゴン
-- 效果：
-- 「青眼白龙」＋龙族怪兽
-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把有融合怪兽装备的1只自己的「青眼白龙」解放的场合可以特殊召唤。
-- ①：场上的这张卡不受陷阱卡的效果影响。
-- ②：这张卡可以向对方怪兽全部各作1次攻击。
-- ③：1回合1次，这张卡进行战斗的伤害步骤结束时，以自己墓地1张陷阱卡为对象才能发动。那张卡在自己场上盖放。
function c11443677.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为89631139的怪兽和1个龙族怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,89631139,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),1,true,true)
	-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	-- 设置该卡只能通过融合召唤方式特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ●把有融合怪兽装备的1只自己的「青眼白龙」解放的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c11443677.sprcon)
	e2:SetTarget(c11443677.sprtg)
	e2:SetOperation(c11443677.sprop)
	c:RegisterEffect(e2)
	-- ①：场上的这张卡不受陷阱卡的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c11443677.efilter)
	c:RegisterEffect(e3)
	-- ②：这张卡可以向对方怪兽全部各作1次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ③：1回合1次，这张卡进行战斗的伤害步骤结束时，以自己墓地1张陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(11443677,0))
	e5:SetCategory(CATEGORY_SSET)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DAMAGE_STEP_END)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCondition(c11443677.setcon)
	e5:SetTarget(c11443677.settg)
	e5:SetOperation(c11443677.setop)
	c:RegisterEffect(e5)
end
-- 用于检查融合素材是否满足特定条件的函数
function c11443677.ultimate_fusion_check(tp,sg,fc)
	-- 检查融合素材是否包含卡号为89631139的融合怪兽和龙族怪兽
	return aux.gffcheck(sg,Card.IsFusionCode,89631139,Card.IsRace,RACE_DRAGON)
end
-- 用于判断怪兽是否为融合怪兽的过滤函数
function c11443677.cfilter(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_FUSION~=0
end
-- 用于判断是否满足特殊召唤条件的过滤函数
function c11443677.sprfilter(c,tp,sc)
	local eqc=c:GetEquipGroup():FilterCount(c11443677.cfilter,nil)
	-- 判断该怪兽是否为青眼白龙、有融合怪兽装备、场上存在召唤空间且可作为融合素材
	return c:IsFusionCode(89631139) and eqc>0 and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 用于判断是否满足特殊召唤条件的函数
function c11443677.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在满足特殊召唤条件的怪兽
	return Duel.CheckReleaseGroupEx(tp,c11443677.sprfilter,1,REASON_SPSUMMON,false,nil,tp,c)
end
-- 用于设置特殊召唤目标的函数
function c11443677.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足特殊召唤条件的可解放怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c11443677.sprfilter,nil,tp,c)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 用于执行特殊召唤操作的函数
function c11443677.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	-- 解放指定的怪兽
	Duel.Release(tc,REASON_SPSUMMON)
end
-- 用于判断效果是否对陷阱卡生效的过滤函数
function c11443677.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
-- 用于判断是否满足盖放陷阱卡效果发动条件的函数
function c11443677.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查该卡是否未发动过此效果且满足伤害步骤结束时的条件
	return e:GetHandler():GetFlagEffect(11443677)==0 and aux.dsercon(e,tp,eg,ep,ev,re,r,rp)
end
-- 用于判断墓地中的陷阱卡是否可盖放的过滤函数
function c11443677.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 用于设置盖放陷阱卡效果的目标选择函数
function c11443677.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c11443677.setfilter(chkc) end
	-- 检查场上是否存在满足条件的墓地陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c11443677.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	-- 选择目标墓地陷阱卡
	local g=Duel.SelectTarget(tp,c11443677.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，指定将要盖放的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	if e:IsCostChecked() then
		e:GetHandler():RegisterFlagEffect(11443677,RESET_EVENT|RESET_TOFIELD|RESET_TURN_SET|RESET_PHASE|PHASE_END,0,0,1)
	end
end
-- 用于执行盖放陷阱卡效果的函数
function c11443677.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标陷阱卡盖放在场上
		Duel.SSet(tp,tc)
	end
end
