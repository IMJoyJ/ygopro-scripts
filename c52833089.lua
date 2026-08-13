--ブラック・サンダー
-- 效果：
-- 自己场上存在的名字带有「黑羽」的怪兽被战斗破坏送去墓地时才能发动。对方场上存在的卡每有1张，给与对方基本分400分伤害。
function c52833089.initial_effect(c)
	-- 自己场上存在的名字带有「黑羽」的怪兽被战斗破坏送去墓地时才能发动。对方场上存在的卡每有1张，给与对方基本分400分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c52833089.condition)
	e1:SetTarget(c52833089.target)
	e1:SetOperation(c52833089.activate)
	c:RegisterEffect(e1)
end
-- 筛选满足条件的怪兽：该卡必须带有「黑羽」字段、位于墓地、在被战斗破坏前由发动玩家控制，且是被战斗破坏而送去墓地的。
function c52833089.cfilter(c,tp)
	return c:IsSetCard(0x33) and c:IsLocation(LOCATION_GRAVE)
		and c:IsPreviousControler(tp) and bit.band(c:GetReason(),REASON_BATTLE)~=0
end
-- 发动条件：检查本次被战斗破坏送去墓地的怪兽组中是否存在至少1只满足上述筛选条件的「黑羽」怪兽。
function c52833089.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c52833089.cfilter,1,nil,tp)
end
-- 效果发动时的目标处理：确认对方场上存在卡，将对象玩家设为对方，并登记造成伤害的操作信息。
function c52833089.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有至少1张卡，若无则不能发动该效果。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
	-- 将当前连锁的对象玩家设置为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 登记操作信息：该效果将造成伤害，目标玩家为对方，基准伤害值为400，具体数量在效果处理时根据对方场上卡数决定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end
-- 效果处理：获取对象玩家，统计其场上的卡数并乘以400，给予该玩家伤害。
function c52833089.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的对象玩家，作为伤害对象。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算伤害值：以对象玩家视角统计其场上的卡数，乘以400。
	local d=Duel.GetFieldGroupCount(p,LOCATION_ONFIELD,0)*400
	-- 给予对象玩家p总共d点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
