--タタカワナイト
-- 效果：
-- 对方的卡的效果让自己的魔法·陷阱卡的发动无效的场合，把这张卡从手卡送去墓地才能发动。给与对方基本分1500分伤害。
function c18444902.initial_effect(c)
	-- 对方的卡的效果让自己的魔法·陷阱卡的发动无效的场合，把这张卡从手卡送去墓地才能发动。给与对方基本分1500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18444902,0))  --"LP伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_CHAIN_NEGATED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c18444902.damcon)
	e1:SetCost(c18444902.damcost)
	e1:SetTarget(c18444902.damtg)
	e1:SetOperation(c18444902.damop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：存在“连锁被无效的原因效果”且无效方不是自己，且被无效的连锁是己方发动的魔法·陷阱卡发动，才满足本卡发动的场合。
function c18444902.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 从被无效的连锁中取得“导致无效的效果”和“进行无效的玩家”，分别赋给de与dp。
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	return de and dp~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp
end
-- 代价检查：确认这张卡仍与效果相关且可以作为代价从手牌送入墓地。
function c18444902.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e)
		and e:GetHandler():IsAbleToGraveAsCost() end
	-- 以代价（REASON_COST）将这张卡从手牌送入墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果发动时的目标设定：无取对象；将对方玩家设为伤害对象，伤害量为1500，并登记伤害分类的操作信息。
function c18444902.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把当前连锁的对象玩家设为对方（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 把当前连锁的对象参数设为伤害数值1500。
	Duel.SetTargetParam(1500)
	-- 登记本次操作信息：伤害分类，无目标卡，对象玩家为对方，伤害值为1500。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
-- 效果处理：从连锁信息中取出之前保存的对象玩家和伤害值，给对方造成伤害。
function c18444902.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家和对象参数（伤害值），存入局部变量p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果（REASON_EFFECT）为原因给与玩家p（对方）d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
