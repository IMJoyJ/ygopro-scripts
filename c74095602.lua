--英雄変化－リフレクター・レイ
-- 效果：
-- 自己场上存在的名字带有「元素英雄」的融合怪兽被战斗破坏送去墓地时才能发动。给与对方基本分破坏的融合怪兽等级×300的数值的伤害。
function c74095602.initial_effect(c)
	-- 自己场上存在的名字带有「元素英雄」的融合怪兽被战斗破坏送去墓地时才能发动。给与对方基本分破坏的融合怪兽等级×300的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c74095602.condition)
	e1:SetTarget(c74095602.target)
	e1:SetOperation(c74095602.activate)
	c:RegisterEffect(e1)
end
-- 判断触发事件的怪兽是否为自己场上被战斗破坏并送去墓地的「元素英雄」融合怪兽
function c74095602.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsPreviousControler(tp) and tc:IsType(TYPE_FUSION) and tc:IsSetCard(0x3008)
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
end
-- 获取被破坏怪兽的等级，并设置伤害的玩家与伤害数值等操作信息
function c74095602.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=eg:GetFirst()
	local lv=tc:GetLevel()
	e:SetLabel(lv)
	-- 将当前连锁的对象玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为被破坏怪兽的等级×300
	Duel.SetTargetParam(lv*300)
	-- 设置当前连锁的操作信息为给与对方等级×300的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,lv*300)
end
-- 获取连锁信息并执行给与对方伤害的效果处理
function c74095602.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和对象参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
