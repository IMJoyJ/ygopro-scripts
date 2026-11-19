--DDナイト・ハウリング
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0，那只怪兽被破坏的场合自己受到1000伤害。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
function c48210156.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 过滤自己墓地中可作为对象的怪兽：属于「DD」字段且能够被特殊召唤
function c48210156.filter(c,e,tp)
	return c:IsSetCard(0xaf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动合法性检查：确认自己主要怪兽区有空位且墓地存在可特殊召唤的「DD」怪兽
function c48210156.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c48210156.filter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否还有至少1个可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的可成为对象的「DD」怪兽
		and Duel.IsExistingTarget(c48210156.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向发动玩家发送选择要特殊召唤的卡片提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动玩家从自己墓地选择1只「DD」怪兽作为本次连锁的对象
	local g=Duel.SelectTarget(tp,c48210156.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次连锁包含将对象怪兽特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行①效果处理：以分解步骤特殊召唤对象怪兽并将其攻击力·守备力设为0，同时为其绑定被破坏时给与自己1000伤害的监听效果；完成特殊召唤后，为自己施加直到回合结束时不能特殊召唤恶魔族以外怪兽的誓约限制
function c48210156.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选中的墓地对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联后，以分解步骤将其表侧表示特殊召唤到自己场上
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的攻击力·守备力变成0，
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
		e3:SetProperty(EFFECT_FLAG_DELAY)
		e3:SetCondition(c48210156.damcon)
		e3:SetOperation(c48210156.damop)
		-- 为自己注册在场上监听怪兽被破坏并结算1000效果伤害的辅助效果
		Duel.RegisterEffect(e3,tp)
		-- 那只怪兽被破坏的场合
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_DESTROY)
		e4:SetLabelObject(e3)
		e4:SetOperation(c48210156.checkop)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4)
	end
	-- 结束分解特殊召唤过程并触发特殊召唤成功相关时点
	Duel.SpecialSummonComplete()
	-- 这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c48210156.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为自己注册持续到回合结束时的特殊召唤种族限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤函数：禁止特殊召唤种族不为恶魔族的怪兽
function c48210156.splimit(e,c)
	return c:GetRace()~=RACE_FIEND
end
-- 当所特召的怪兽确定被破坏即将离场时，将对应的伤害触发效果标签设为1以标记需结算伤害
function c48210156.checkop(e,tp,eg,ep,ev,re,r,rp)
	local e3=e:GetLabelObject()
	e3:SetLabel(1)
end
-- 检查伤害触发条件：确认伤害触发标签已被标记为1
function c48210156.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1
end
-- 执行破坏后惩罚伤害处理：使控制者受到1000点效果伤害，并将标签清零同时重置该监听效果
function c48210156.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果给与自己1000点伤害
	Duel.Damage(tp,1000,REASON_EFFECT)
	e:SetLabel(0)
	e:Reset()
end
