--富炎星－ハクテンオウ
-- 效果：
-- 兽战士族怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。给与对方为自己场上的「炎舞」魔法·陷阱卡数量×200伤害。
-- ②：自己·对方的战斗阶段，把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地，以对方场上1张卡为对象才能发动。那张卡破坏。
function c93877990.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，需要2只兽战士族怪兽作为素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEASTWARRIOR),2,true)
	-- ①：这张卡特殊召唤成功的场合才能发动。给与对方为自己场上的「炎舞」魔法·陷阱卡数量×200伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93877990,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,93877990)
	e1:SetTarget(c93877990.damtg)
	e1:SetOperation(c93877990.damop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的战斗阶段，把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93877990,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,93877991)
	e2:SetCondition(c93877990.descon)
	e2:SetCost(c93877990.descost)
	e2:SetTarget(c93877990.destg)
	e2:SetOperation(c93877990.desop)
	c:RegisterEffect(e2)
end
-- 过滤自身场上表侧表示的「炎舞」魔法·陷阱卡
function c93877990.damfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①（伤害效果）的发动准备与检测
function c93877990.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1张表侧表示的「炎舞」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c93877990.damfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 设置伤害的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 获取自己场上表侧表示的「炎舞」魔法·陷阱卡数量
	local ct=Duel.GetMatchingGroupCount(c93877990.damfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 设置连锁的操作信息，原因为给与对方伤害，数值为「炎舞」卡数量×200
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
end
-- 效果①（伤害效果）的效果处理
function c93877990.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家（即对方）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算当前自己场上表侧表示的「炎舞」魔法·陷阱卡数量
	local ct=Duel.GetMatchingGroupCount(c93877990.damfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 给与对方计算出的数值的伤害
	Duel.Damage(p,ct*200,REASON_EFFECT)
end
-- 效果②（破坏效果）的发动条件判定
function c93877990.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否处于自己或对方的战斗阶段
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
-- 过滤作为发动成本（Cost）送去墓地的、自己场上表侧表示的「炎舞」魔法·陷阱卡
function c93877990.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 效果②（破坏效果）的发动成本（Cost）处理，并兼容【炎星仙-鹫真人】的代替送墓效果
function c93877990.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为发动成本送去墓地的「炎舞」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c93877990.costfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		or Duel.IsPlayerAffectedByEffect(tp,46241344) end
	-- 再次确认场上存在符合条件的「炎舞」魔法·陷阱卡
	if Duel.IsExistingMatchingCard(c93877990.costfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		and (not Duel.IsPlayerAffectedByEffect(tp,46241344) or not Duel.SelectYesNo(tp,aux.Stringid(46241344,0))) then  --"是否不把卡送去墓地发动？"
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 玩家选择1张符合条件的「炎舞」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c93877990.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 将选择的卡作为发动成本送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	end
end
-- 效果②（破坏效果）的发动准备与对象选择
function c93877990.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的目标卡片
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息，原因为破坏选中的对象卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②（破坏效果）的效果处理
function c93877990.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
