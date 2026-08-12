--エクスプロード・ウィング・ドラゴン
-- 效果：
-- 调整＋调整以外的龙族怪兽1只以上
-- 和持有这张卡的攻击力以下的攻击力的场上表侧表示存在的怪兽进行战斗的场合，可以不进行伤害计算把那只怪兽破坏，给与对方基本分破坏怪兽的攻击力数值的伤害。
function c40529384.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整，1只调整以外的龙族怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_DRAGON),1)
	c:EnableReviveLimit()
	-- 和持有这张卡的攻击力以下的攻击力的场上表侧表示存在的怪兽进行战斗的场合，可以不进行伤害计算把那只怪兽破坏，给与对方基本分破坏怪兽的攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40529384,0))  --"破坏并伤害"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(c40529384.destg)
	e1:SetOperation(c40529384.desop)
	c:RegisterEffect(e1)
end
-- 设置效果目标函数，判断攻击怪兽是否存在且攻击力不超过自身攻击力，并设置破坏和伤害的操作信息
function c40529384.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取当前战斗中的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽是自身，则获取攻击目标怪兽
	if tc==c then tc=Duel.GetAttackTarget() end
	if chk==0 then return tc and tc:IsFaceup() and tc:GetAttack()<=c:GetAttack() end
	-- 设置操作信息，指定将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 设置操作信息，指定将要给予的伤害及伤害对象
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tc:GetAttack())
end
-- 设置效果运算函数，执行破坏和伤害处理
function c40529384.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前战斗中的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽是自身，则获取攻击目标怪兽
	if tc==c then tc=Duel.GetAttackTarget() end
	if tc:IsRelateToBattle() and tc:GetAttack()<=c:GetAttack() then
		local atk=tc:GetAttack()
		-- 执行破坏操作，若成功则继续造成伤害
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 对对方造成等于被破坏怪兽攻击力的伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
