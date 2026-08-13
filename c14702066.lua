--メガキャノン・ソルジャー
-- 效果：
-- 每把自己场上存在的2只怪兽作为祭品，给与对方基本分1500分伤害。
function c14702066.initial_effect(c)
	-- 每把自己场上存在的2只怪兽作为祭品，给与对方基本分1500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14702066,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c14702066.cost)
	e1:SetTarget(c14702066.target)
	e1:SetOperation(c14702066.operation)
	c:RegisterEffect(e1)
end
-- 发动代价处理：确认能否支付“把2只怪兽解放”的代价并进行选择、解放。
function c14702066.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 仅在效果发动前的代价确认阶段（chk==0）检查己方场上是否存在至少2只可解放的怪兽，满足才可发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,2,nil) end
	-- 让玩家从自己场上选择2只可解放的怪兽作为发动代价的解放对象。
	local sg=Duel.SelectReleaseGroup(tp,nil,2,2,nil)
	-- 将选择的两只怪兽解放，作为效果的发动代价（REASON_COST）。
	Duel.Release(sg,REASON_COST)
end
-- 发动时设定目标：将对方玩家设为效果对象，伤害数值设为1500，并登记操作信息以供后续处理和连锁判定。
function c14702066.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的对象玩家设置为对方（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将对象参数（伤害数值）设置为1500，与效果原文的伤害值一致。
	Duel.SetTargetParam(1500)
	-- 登记操作信息：本连锁将造成伤害（CATEGORY_DAMAGE），目标玩家为对方，伤害值为1500。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
-- 效果处理：从连锁信息中取出目标玩家和伤害参数，对对方玩家实际造成1500点伤害。
function c14702066.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的目标玩家和伤害参数（在发动时通过SetTargetPlayer/SetTargetParam设置）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害形式（REASON_EFFECT）对目标玩家造成指定的1500点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
