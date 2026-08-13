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
	-- 为这张卡添加融合召唤手续：素材为1只「青眼白龙」（卡号89631139）和1只龙族怪兽，对应融合素材要求「青眼白龙」＋龙族怪兽。
	aux.AddFusionProcCodeFun(c,89631139,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),1,true,true)
	-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	-- 设定特殊召唤条件判定值：仅允许以融合召唤（SUMMON_TYPE_FUSION）方式从额外卡组特殊召唤本卡，禁止其他非融合召唤方式（替代召唤手续由后续e2实现）。
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
-- 融合素材合法性校验函数：验证融合素材组中同时包含1只「青眼白龙」和1只龙族怪兽，且顺序不限。
function c11443677.ultimate_fusion_check(tp,sg,fc)
	-- 调用aux.gffcheck检查素材组sg是否满足两种组合之一：第一张是青眼白龙且第二张是龙族，或第一张是龙族且第二张是青眼白龙。
	return aux.gffcheck(sg,Card.IsFusionCode,89631139,Card.IsRace,RACE_DRAGON)
end
-- 定义过滤条件：卡为表侧表示且原类型包含融合怪兽（TYPE_FUSION），用于判断装备怪兽是否为融合怪兽。
function c11443677.cfilter(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_FUSION~=0
end
-- 定义替代特殊召唤手续的解放素材条件：表侧表示的「青眼白龙」且其装备区有融合怪兽，解放后有空位可供本卡出场，且该「青眼白龙」可作为本卡特殊召唤的素材。
function c11443677.sprfilter(c,tp,sc)
	local eqc=c:GetEquipGroup():FilterCount(c11443677.cfilter,nil)
	-- 返回解放素材筛选结果：必须同时满足卡名是青眼白龙、装备有融合怪兽、解放后额外怪兽区有空格、可作为特殊召唤素材。
	return c:IsFusionCode(89631139) and eqc>0 and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 特殊召唤手续的发动条件：若c为空则返回true；否则检查我方是否存在至少1只满足解放素材条件的「青眼白龙」可用于此特殊召唤。
function c11443677.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 调用Duel.CheckReleaseGroupEx检查我方存在至少1只符合条件的可解放卡（解放原因为特殊召唤），以决定该特殊召唤手续能否使用。
	return Duel.CheckReleaseGroupEx(tp,c11443677.sprfilter,1,REASON_SPSUMMON,false,nil,tp,c)
end
-- 特殊召唤手续的目标选择：从可解放卡中筛选出符合条件的「青眼白龙」，提示玩家选择1张，并将选中卡存入效果标签用于后续解放。
function c11443677.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取我方场上可解放的卡组，并用sprfilter过滤出装备有融合怪兽的「青眼白龙」作为候选。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c11443677.sprfilter,nil,tp,c)
	-- 向玩家发送选择提示，消息类型为HINTMSG_RELEASE，内容为“请选择要解放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的操作处理：取出之前选定的解放对象，将其记录为这张卡的融合素材并解放，随后由引擎完成特殊召唤。
function c11443677.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	-- 以特殊召唤为理由解放选中的「青眼白龙」，支付特殊召唤手续所需的代价。
	Duel.Release(tc,REASON_SPSUMMON)
end
-- 免疫判定函数：若效果发起者是陷阱卡效果（te:IsActiveType(TYPE_TRAP)），则返回true，使本卡不受该陷阱效果影响。
function c11443677.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
-- ③效果的发动条件：本回合本卡尚未用该效果获得过flag（即未发动过），且当前处于本卡战斗的伤害步骤结束时。
function c11443677.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回条件判定结果：未使用过该效果（flag为0）且aux.dsercon判定本卡确实经历了这次战斗伤害步骤。
	return e:GetHandler():GetFlagEffect(11443677)==0 and aux.dsercon(e,tp,eg,ep,ev,re,r,rp)
end
-- 定义③效果的对象筛选条件：目标是陷阱卡且可以被盖放（IsSSetable）。
function c11443677.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ③效果的发动时目标处理：从自己墓地选择1张可以盖放的陷阱卡作为对象，并登记墓地离开的操作信息；若在发动时检查，给本卡设置一回合一次的flag标记。
function c11443677.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c11443677.setfilter(chkc) end
	-- 发动合法性检查：chk==0时确认自己墓地是否存在至少1张满足条件的陷阱卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c11443677.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送选择提示，消息类型为HINTMSG_SET，内容为“请选择要盖放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己墓地的陷阱卡中选择1张作为效果对象，并自动设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c11443677.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息：记录这次效果将使对象卡从墓地移动到其他区域（CATEGORY_LEAVE_GRAVE），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	if e:IsCostChecked() then
		e:GetHandler():RegisterFlagEffect(11443677,RESET_EVENT|RESET_TOFIELD|RESET_TURN_SET|RESET_PHASE|PHASE_END,0,0,1)
	end
end
-- ③效果处理：取得效果对象卡，若它仍然与该效果关联，则将其盖放到自己场上。
function c11443677.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这个效果发动时选择的对象卡（即从墓地选择的陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象陷阱卡以里侧表示盖放到自己场上。
		Duel.SSet(tp,tc)
	end
end
