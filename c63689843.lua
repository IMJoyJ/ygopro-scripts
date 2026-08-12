--白兵戦
-- 效果：
-- 自己受到伤害的时候才可以发动。对方的基本分受到700分的伤害。自己的墓地还有「白兵战」存在的场合，对方受到（这些卡的数量×300）的伤害。
function c63689843.initial_effect(c)
	-- 自己受到伤害的时候才可以发动。对方的基本分受到700分的伤害。自己的墓地还有「白兵战」存在的场合，对方受到（这些卡的数量×300）的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetTarget(c63689843.rectg)
	e1:SetOperation(c63689843.recop)
	c:RegisterEffect(e1)
end
-- 效果发动的检测与效果对象准备：检测是否是自己受到伤害，并设置伤害目标为对方、伤害数值为700
function c63689843.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return ep==tp end
	-- 设置当前连锁的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数（伤害数值）为700
	Duel.SetTargetParam(700)
	-- 设置操作信息，表明此效果包含对对方造成700点伤害的操作
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,700)
end
-- 效果处理：给与对方700点伤害，并根据自己墓地中「白兵战」的数量追加伤害
function c63689843.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家设定的伤害（700点）
	Duel.Damage(p,d,REASON_EFFECT)
	-- 计算自己墓地中卡名为「白兵战」的卡片数量
	local gc=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,63689843)
	if gc>0 then
		-- 以效果原因给与目标玩家（墓地中「白兵战」数量×300）的伤害
		Duel.Damage(p,300*gc,REASON_EFFECT)
	end
end
