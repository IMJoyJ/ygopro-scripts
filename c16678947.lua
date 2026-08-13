--カース・サイキック
-- 效果：
-- 自己场上表侧表示存在的念动力族怪兽被对方怪兽的攻击破坏送去墓地时才能发动。那个时候进行攻击的1只对方怪兽破坏，给与对方基本分破坏的自己的念动力族怪兽等级×300的数值的伤害。
function c16678947.initial_effect(c)
	-- 自己场上表侧表示存在的念动力族怪兽被对方怪兽的攻击破坏送去墓地时才能发动。那个时候进行攻击的1只对方怪兽破坏，给与对方基本分破坏的自己的念动力族怪兽等级×300的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c16678947.condition)
	e1:SetTarget(c16678947.target)
	e1:SetOperation(c16678947.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判断：从战斗破坏送去墓地的怪兽中取出该怪兽，确认其之前是自己控制、现处墓地且为念动力族，且在战斗前为表侧表示；同时取得与其战斗的怪兽，确认该战斗怪兽仍与本次战斗关联、为对方控制且正是那次攻击的怪兽。
function c16678947.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return tc:IsPreviousControler(tp) and tc:IsLocation(LOCATION_GRAVE) and tc:IsRace(RACE_PSYCHO)
		and bit.band(tc:GetBattlePosition(),POS_FACEUP)~=0
		-- 进一步确认攻击怪兽仍与本次战斗保持关联（未离场或效果重置），且该怪兽的控制者为对方的场地，并且该怪兽就是伤害步骤中实际发动攻击的怪兽。
		and bc:IsRelateToBattle() and bc:IsControler(1-tp) and bc==Duel.GetAttacker()
end
-- 效果发动时的对象选择与信息登记：若指定对象（攻击怪兽）能够成为效果对象，则将破坏对象的等级存入标签，将其设为效果对象，并登记破坏该怪兽的预计信息；若等级不为0，还登记给对方造成等级×300伤害的预计信息。
function c16678947.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local tc=eg:GetFirst()
	-- 取得当前攻击的怪兽（即对方那只进行攻击的怪兽）作为候选对象。
	local bc=Duel.GetAttacker()
	if chk==0 then return bc:IsCanBeEffectTarget(e) end
	local lv=tc:GetLevel()
	e:SetLabel(lv)
	-- 将那只攻击怪兽登记为当前连锁的效果对象（取对象），后续处理以此对象为准。
	Duel.SetTargetCard(bc)
	-- 设置操作信息：本次效果将破坏1只对象怪兽（即攻击怪兽），用于连锁检测和效果发动判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	if lv~=0 then
		-- 若被破坏的念动力族怪兽等级不为0，则设置操作信息：本次效果将给对方造成对象怪兽等级×300的伤害，伤害来源为效果。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,lv*300)
	end
end
-- 效果处理：取得效果对象，若对象仍与效果关联，则将其破坏；破坏成功后，再根据之前存入的等级给予对方对应伤害。
function c16678947.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁中登记的效果对象（即那只攻击怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认取出的对象仍然与本效果存在关联（没有因离场等原因失效），然后以效果破坏该对象；若破坏处理成功（返回非0），才继续执行伤害。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给与对方玩家（1-tp）基本分伤害，数值为之前记录的等级×300，伤害理由为效果伤害。
		Duel.Damage(1-tp,e:GetLabel()*300,REASON_EFFECT)
	end
end
