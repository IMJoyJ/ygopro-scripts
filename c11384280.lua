--キャノン・ソルジャー
-- 效果：
-- 可以把自己场上存在的1只怪兽解放，给与对方基本分500分伤害。
function c11384280.initial_effect(c)
	-- 可以把自己场上存在的1只怪兽解放，给与对方基本分500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11384280,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c11384280.cost)
	e1:SetTarget(c11384280.target)
	e1:SetOperation(c11384280.operation)
	c:RegisterEffect(e1)
end
-- 代价处理：检查能否解放怪兽，然后选择并解放自己场上1只怪兽作为发动代价。
function c11384280.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查时，确认自己场上是否存在至少1只可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 让发动玩家从自己场上选择1只可解放的怪兽作为解放对象。
	local sg=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将选择的怪兽以代价方式解放。
	Duel.Release(sg,REASON_COST)
end
-- 发动时目标设定：效果必定可行，将对方玩家设为伤害对象，伤害值设为500，并登记伤害效果信息。
function c11384280.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家设置为该效果的对象玩家（受到伤害的玩家）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为500，即伤害数值。
	Duel.SetTargetParam(500)
	-- 登记伤害效果的操作信息，用于连锁确认和相关效果检测，目标玩家为对方，伤害值为500。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理：从连锁信息中取出对象玩家和伤害数值，对对方造成效果伤害。
function c11384280.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给予对象玩家p数值为d的效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
