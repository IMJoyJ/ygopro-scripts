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
-- 发动条件判断：仅当受到伤害的玩家是自己（ep==tp）时，该效果才满足发动条件。
function c2130625.reccon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 发动时目标处理：效果必定可发动；发动时记录回复对象为自己，回复数值为1000，并设置操作信息为回复效果。
function c2130625.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁效果的对象玩家设为自己，即回复基本分的对象。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁效果的对象参数设为1000，用于表示本次回复的数值。
	Duel.SetTargetParam(1000)
	-- 设置操作信息：本效果分类为回复（CATEGORY_RECOVER），对象玩家为自己，预计回复数值为1000，供其他效果检测或对应。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 效果处理：根据连锁中记录的对象玩家与回复数值执行回复，并额外统计自己墓地「白衣天使」的数量，每有1张再追加回复500基本分。
function c2130625.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家和回复数值，分别赋给变量p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p回复d点基本分，回复原因记为效果（REASON_EFFECT）。
	Duel.Recover(p,d,REASON_EFFECT)
	-- 统计玩家p墓地中卡名「白衣天使」（卡号2130625）的数量，结果存入gc。
	local gc=Duel.GetMatchingGroupCount(Card.IsCode,p,LOCATION_GRAVE,0,nil,2130625)
	if gc>0 then
		-- 如果墓地存在「白衣天使」，则玩家p追加回复500×gc点基本分，回复原因记为效果（REASON_EFFECT）。
		Duel.Recover(p,500*gc,REASON_EFFECT)
	end
end
