--墓守の大筒持ち
-- 效果：
-- 每祭掉自己场上1只名称中含有「守墓」的怪兽，给与对方基本分700分的伤害。使用这个效果的场合不能使用「守墓的重炮手」作为祭品。
function c99877698.initial_effect(c)
	-- 每祭掉自己场上1只名称中含有「守墓」的怪兽，给与对方基本分700分的伤害。使用这个效果的场合不能使用「守墓的重炮手」作为祭品。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99877698,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c99877698.cost)
	e1:SetTarget(c99877698.target)
	e1:SetOperation(c99877698.operation)
	c:RegisterEffect(e1)
end
-- costfilter判断可作为解放代价的怪兽：必须是名称中含有「守墓」（字段0x2e）的怪兽，且不能是「守墓的重炮手」（卡号99877698）。
function c99877698.costfilter(c)
	return c:IsSetCard(0x2e) and not c:IsCode(99877698)
end
-- 发动效果的COST：从自己场上选择并解放1只满足costfilter条件的怪兽，不能选择「守墓的重炮手」。
function c99877698.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk==0）确认自己场上是否存在至少1只满足costfilter条件的可解放怪兽，若不存在则不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c99877698.costfilter,1,nil) end
	-- 从自己场上选择1只满足costfilter条件的怪兽作为发动代价。
	local sg=Duel.SelectReleaseGroup(tp,c99877698.costfilter,1,1,nil)
	-- 将所选择的怪兽以REASON_COST（作为代价）解放。
	Duel.Release(sg,REASON_COST)
end
-- 发动时指定对方玩家为效果对象，伤害数值为700，并登记伤害操作信息；该效果以玩家为对象。
function c99877698.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为对方（1-tp），即承受伤害的玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设为700，即造成的伤害数值。
	Duel.SetTargetParam(700)
	-- 登记操作信息：本连锁包含CATEGORY_DAMAGE伤害效果，目标玩家为对方，伤害参数为700，不指定具体卡片。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,700)
end
-- 效果处理时从连锁信息中取得对象玩家与伤害数值，并执行伤害。
function c99877698.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象玩家p和伤害参数d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害（REASON_EFFECT）的形式给予玩家p共d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
