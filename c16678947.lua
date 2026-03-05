--カース・サイキック
-- 效果：
-- 自己场上表侧表示存在的念动力族怪兽被对方怪兽的攻击破坏送去墓地时才能发动。那个时候进行攻击的1只对方怪兽破坏，给与对方基本分破坏的自己的念动力族怪兽等级×300的数值的伤害。
function c16678947.initial_effect(c)
	-- 效果初始化，设置效果类型为发动效果，触发事件为战斗破坏送去墓地，条件为念动力族怪兽被破坏，目标为攻击怪兽，效果为破坏并造成伤害
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
-- 效果发动条件：自己场上表侧表示存在的念动力族怪兽被对方怪兽的攻击破坏送去墓地时才能发动
function c16678947.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return tc:IsPreviousControler(tp) and tc:IsLocation(LOCATION_GRAVE) and tc:IsRace(RACE_PSYCHO)
		and bit.band(tc:GetBattlePosition(),POS_FACEUP)~=0
		-- 攻击怪兽与战斗相关且控制者为对方且等于当前攻击怪兽
		and bc:IsRelateToBattle() and bc:IsControler(1-tp) and bc==Duel.GetAttacker()
end
-- 效果处理目标：设置攻击怪兽为效果目标，准备破坏该怪兽并计算伤害
function c16678947.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local tc=eg:GetFirst()
	-- 获取当前攻击怪兽
	local bc=Duel.GetAttacker()
	if chk==0 then return bc:IsCanBeEffectTarget(e) end
	local lv=tc:GetLevel()
	e:SetLabel(lv)
	-- 将攻击怪兽设置为效果目标
	Duel.SetTargetCard(bc)
	-- 设置操作信息为破坏效果，目标为攻击怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	if lv~=0 then
		-- 设置操作信息为伤害效果，给与对方基本分破坏怪兽等级×300的伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,lv*300)
	end
end
-- 效果发动处理：判断目标怪兽是否有效，若有效则破坏该怪兽并给予对方基本分伤害
function c16678947.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否与效果相关且破坏成功
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给与对方基本分破坏的自己的念动力族怪兽等级×300的数值的伤害
		Duel.Damage(1-tp,e:GetLabel()*300,REASON_EFFECT)
	end
end
