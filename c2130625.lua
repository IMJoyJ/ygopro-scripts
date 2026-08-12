--白衣の天使
-- 效果：
-- 自己因战斗或者卡的效果受到伤害时才能发动。自己回复1000基本分。自己墓地有「白衣天使」存在的场合，再回复那个数量的500基本分。
function c2130625.initial_effect(c)
	-- 自己因战斗或者卡的效果受到伤害时才能发动。自己回复1000基本分。自己墓地有「白衣天使」存在的场合，再回复那个数量的500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(c2130625.reccon)
	e1:SetTarget(c2130625.rectg)
	e1:SetOperation(c2130625.recop)
	c:RegisterEffect(e1)
end
-- 伤害步骤时，只有自己受到伤害才能发动。
function c2130625.reccon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 设置效果目标为自身，设置效果参数为1000，设置操作信息为回复1000基本分。
function c2130625.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的效果对象玩家为处理该效果的玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果参数为1000。
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为回复基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 效果处理函数，先回复1000基本分，再判断墓地是否有「白衣天使」，若有则再回复相应数量的500基本分。
function c2130625.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复目标参数数量的基本分。
	Duel.Recover(p,d,REASON_EFFECT)
	-- 统计目标玩家墓地中「白衣天使」的数量。
	local gc=Duel.GetMatchingGroupCount(Card.IsCode,p,LOCATION_GRAVE,0,nil,2130625)
	if gc>0 then
		-- 使目标玩家回复500乘以「白衣天使」数量的基本分。
		Duel.Recover(p,500*gc,REASON_EFFECT)
	end
end
