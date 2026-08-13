--DDナイト・ハウリング
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0，那只怪兽被破坏的场合自己受到1000伤害。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
function c48210156.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0，那只怪兽被破坏的场合自己受到1000伤害。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48210156,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c48210156.sptg)
	e1:SetOperation(c48210156.spop)
	c:RegisterEffect(e1)
end
-- 筛选自己墓地中满足「DD」字段且能够被特殊召唤的怪兽，作为效果对象候选。
function c48210156.filter(c,e,tp)
	return c:IsSetCard(0xaf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标检查：若指定对象，验证其在自己墓地且符合筛选；若为发动确认，检查场上是否有可用怪兽区和墓地是否存在可特殊召唤的「DD」怪兽。
function c48210156.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c48210156.filter(chkc,e,tp) end
	-- 确认自己场上存在可用的主要怪兽区空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地存在至少1只符合条件的「DD」怪兽可作为特殊召唤对象。
		and Duel.IsExistingTarget(c48210156.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的「DD」怪兽，将其设为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c48210156.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁将进行特殊召唤的操作信息，数量为1，供后续时点/效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象怪兽特殊召唤，使其攻击力·守备力变成0，并设置被破坏时造成伤害的效果；随后适用直到回合结束只能特殊召唤恶魔族怪兽的自肃。
function c48210156.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得该效果发动时选择的对象怪兽（墓地中的那只「DD」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍然与该效果有关联，且其能够被特殊召唤时，将其以表侧表示加入特殊召唤处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
		-- 那只怪兽被破坏的场合自己受到1000伤害。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DESTROYED)
		e3:SetCondition(c48210156.damcon)
		e3:SetOperation(c48210156.damop)
		-- 将监听破坏事件的持续效果e3注册给tp方，用于在符合条件的怪兽被破坏时触发伤害。
		Duel.RegisterEffect(e3,tp)
		-- 那只怪兽被破坏的场合（用于判定被破坏的是否为此效果特殊召唤的怪兽）。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_DESTROY)
		e4:SetLabelObject(e3)
		e4:SetOperation(c48210156.checkop)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4)
	end
	-- 完成特殊召唤处理（与SpecialSummonStep配套，结束连锁中的特殊召唤并触发召唤成功时点）。
	Duel.SpecialSummonComplete()
	-- 这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c48210156.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册给tp方，在回合结束前限制其不能特殊召唤恶魔族以外的怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制条件：被特殊召唤的怪兽种族不是恶魔族时，禁止该特殊召唤。
function c48210156.splimit(e,c)
	return c:GetRace()~=RACE_FIEND
end
-- 当被特殊召唤的怪兽被破坏时，将对应的伤害效果e3的标记设为1，标记该破坏对象是此效果特殊召唤的怪兽。
function c48210156.checkop(e,tp,eg,ep,ev,re,r,rp)
	local e3=e:GetLabelObject()
	e3:SetLabel(1)
end
-- 伤害效果的发动条件：仅当标记为1时才满足，即确实是被此效果特殊召唤的怪兽被破坏。
function c48210156.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1
end
-- 条件满足时给与tp方1000点效果伤害，然后将标记复位并重置该伤害效果，避免重复触发。
function c48210156.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给tp方造成1000点效果伤害。
	Duel.Damage(tp,1000,REASON_EFFECT)
	e:SetLabel(0)
	e:Reset()
end
