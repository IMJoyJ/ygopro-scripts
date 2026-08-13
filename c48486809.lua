--ハネクリボー LV6
-- 效果：
-- 这个卡名在规则上也当作「元素英雄」卡、「至爱」卡使用。这张卡不能通常召唤。「羽翼栗子球 LV6」1回合1次在把自己的手卡·场上（表侧表示）·墓地1只「元素英雄」融合怪兽或「羽翼栗子球」除外的场合才能从手卡·墓地特殊召唤。
-- ①：对方怪兽的攻击宣言时或者对方把场上的怪兽的效果发动时，把这张卡解放才能发动。那1只怪兽破坏，给与对方那个原本攻击力数值的伤害。
local s,id,o=GetID()
-- 注册该卡核心效果：EnableReviveLimit配合特殊召唤条件实现“不能通常召唤”；注册EFFECT_SPSUMMON_PROC实现从手卡·墓地除外1只“元素英雄”融合怪兽或“羽翼栗子球”来特殊召唤；再注册①效果，在对方怪兽攻击宣言时或对方场上怪兽效果发动时解放自身，破坏那1只怪兽并给予其原本攻击力伤害。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 「羽翼栗子球 LV6」1回合1次在把自己的手卡·场上（表侧表示）·墓地1只「元素英雄」融合怪兽或「羽翼栗子球」除外的场合才能从手卡·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 对方怪兽的攻击宣言时……把这张卡解放才能发动。那1只怪兽破坏，给与对方那个原本攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.descon)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(s.descon2)
	e4:SetTarget(s.destg2)
	e4:SetOperation(s.desop2)
	c:RegisterEffect(e4)
end
s.lvup={id}
-- 过滤可作为特殊召唤代价的卡：是「羽翼栗子球」或「元素英雄」融合怪兽，且满足表侧判定与可除外条件，并确保除外后自己怪兽区有空位供特殊召唤使用。
function s.spfilter(c,tp)
	return (c:IsCode(57116033) or c:IsSetCard(0x3008) and c:IsType(TYPE_FUSION))
		-- 进一步要求该卡可被除外作为代价（场上时为表侧表示，手卡/墓地不受限），且除外后自己仍有怪兽区空格。
		and c:IsFaceupEx() and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤程序的发动条件：若c为空则直接允许；否则检查自己手卡·场上·墓地是否存在至少1张满足spfilter的卡可作为除外代价。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判定自己手卡·场上·墓地是否存在至少1张满足spfilter条件的卡（排除要特殊召唤的c自身）作为特殊召唤代价。
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_HAND,0,1,c,tp)
end
-- 特殊召唤的处理：从自己手卡·场上·墓地选择1张符合条件的卡，将其表侧除外作为代价，随后完成自身的特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 给玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己手卡·场上·墓地选择1张满足spfilter的卡作为除外代价，且不能选择要特殊召唤的c自身。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c)
	-- 将选中的卡以表侧表示除外，作为这次特殊召唤的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 攻击宣言效果的发动条件：只有对方回合（当前回合玩家不是自己）且对方怪兽攻击宣言时才满足。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家不是自己，即该效果只能在对方攻击宣言时发动。
	return tp~=Duel.GetTurnPlayer()
end
-- 发动代价：检查这张卡能否被解放；可以则将其解放作为发动代价。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放这张卡自身作为效果的发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 攻击宣言效果的目标/操作信息：取攻击怪兽；若可破坏则登记破坏信息；若其原本攻击力大于0则登记给对方其原本攻击力伤害的信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击宣言的怪兽，作为后续破坏与伤害判定的对象。
	local tc=Duel.GetAttacker()
	if chk==0 then return tc:IsDestructable() end
	-- 登记本连锁的操作信息：将攻击宣言怪兽确定为将被破坏的卡（数量1），供其他效果判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	if tc:GetTextAttack()>0 then
		-- 若攻击怪兽原本攻击力大于0，登记将给对方造成其原本攻击力数值伤害的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tc:GetTextAttack())
	end
end
-- 攻击宣言效果的处理：确认攻击怪兽仍与战斗相关后将其破坏；若破坏成功且其原本攻击力大于0，给与对方该数值的伤害。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取攻击宣言的怪兽，用于效果处理时的状态检查。
	local tc=Duel.GetAttacker()
	-- 确认攻击怪兽仍与那次战斗关联，且被成功破坏，且其原本攻击力大于0时才继续造成伤害。
	if tc:IsRelateToBattle() and Duel.Destroy(tc,REASON_EFFECT)>0 and tc:GetTextAttack()>0 then
		-- 给与对方玩家等同于该攻击怪兽原本攻击力数值的效果伤害。
		Duel.Damage(1-tp,tc:GetTextAttack(),REASON_EFFECT)
	end
end
-- 对方场上怪兽效果发动时的触发条件：效果发动者是对方（rp≠tp），效果来源是场上的怪兽，且该效果为怪兽效果。
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER)
end
-- 对方怪兽效果发动时的目标/操作信息：以发动效果的那只怪兽为处理对象；若可破坏则登记破坏信息；若其原本攻击力大于0则登记伤害信息。
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=re:GetHandler()
	if chk==0 then return tc:IsDestructable() end
	-- 登记将发动效果的那只怪兽确定为破坏对象，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 当该怪兽原本攻击力大于0时，登记给与对方造成伤害的操作信息；实际伤害数值由处理时按原本攻击力计算。
	if math.max(0,tc:GetTextAttack())>0 then Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0) end
end
-- 对方怪兽效果发动时的效果处理：若该怪兽仍与发动效果关联且在怪兽区，则将其破坏；破坏成功且原本攻击力大于0时给与对方该数值的伤害。
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if tc:IsRelateToEffect(re) and tc:IsLocation(LOCATION_MZONE)
		-- 确认该怪兽仍与发动效果关联、仍在怪兽区，且破坏成功，并满足原本攻击力大于0才继续造成伤害。
		and Duel.Destroy(tc,REASON_EFFECT)>0 and tc:GetTextAttack()>0 then
		-- 给与对方玩家等同于该怪兽原本攻击力数值的效果伤害。
		Duel.Damage(1-tp,tc:GetTextAttack(),REASON_EFFECT)
	end
end
