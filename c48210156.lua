--DDナイト・ハウリング
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0，那只怪兽被破坏的场合自己受到1000伤害。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
function c48210156.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只「DD」怪兽为对象才能发动。
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
-- 筛选满足条件的墓地DD怪兽
function c48210156.filter(c,e,tp)
	return c:IsSetCard(0xaf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上是否有空位且墓地是否存在符合条件的怪兽
function c48210156.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c48210156.filter(chkc,e,tp) end
	-- 判断是否满足发动条件：场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c48210156.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标：从自己墓地选择一只符合条件的DD怪兽
	local g=Duel.SelectTarget(tp,c48210156.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：将该怪兽设为特殊召唤对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果：特殊召唤选中的怪兽，并设置其攻守为0，注册破坏时伤害效果和回合结束时限制特殊召唤的效果
function c48210156.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功执行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 将特殊召唤的怪兽攻击力设为0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
		-- 注册一个场地区域持续效果：当有怪兽被破坏时触发伤害效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DESTROYED)
		e3:SetCondition(c48210156.damcon)
		e3:SetOperation(c48210156.damop)
		-- 将破坏时触发的伤害效果注册到场上
		Duel.RegisterEffect(e3,tp)
		-- 注册一个单体持续效果：当该怪兽被破坏时，标记破坏时触发的伤害效果为已触发
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_DESTROY)
		e4:SetLabelObject(e3)
		e4:SetOperation(c48210156.checkop)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	-- 注册一个场地区域永续效果：直到回合结束时自己不是恶魔族怪兽不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c48210156.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制特殊召唤的效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤效果的判定函数：若怪兽种族不是恶魔族则不能特殊召唤
function c48210156.splimit(e,c)
	return c:GetRace()~=RACE_FIEND
end
-- 破坏时触发的标记操作函数：设置标记为已触发
function c48210156.checkop(e,tp,eg,ep,ev,re,r,rp)
	local e3=e:GetLabelObject()
	e3:SetLabel(1)
end
-- 伤害触发条件函数：判断是否已被标记为已触发
function c48210156.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1
end
-- 执行伤害处理函数：对玩家造成1000点伤害
function c48210156.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 对玩家造成1000点伤害
	Duel.Damage(tp,1000,REASON_EFFECT)
	e:SetLabel(0)
	e:Reset()
end
