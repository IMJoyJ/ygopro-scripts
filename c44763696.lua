--Sin Tune
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示的「罪」怪兽被战斗或者对方的效果破坏的场合才能发动。自己从卡组抽2张。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「罪」怪兽被战斗以外破坏的场合，把墓地的这张卡除外才能发动。从卡组把1只「罪」怪兽加入手卡。
function c44763696.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上的表侧表示的「罪」怪兽被战斗或者对方的效果破坏的场合才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,44763696)
	e1:SetCondition(c44763696.condition)
	e1:SetTarget(c44763696.target)
	e1:SetOperation(c44763696.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「罪」怪兽被战斗以外破坏的场合，把墓地的这张卡除外才能发动。从卡组把1只「罪」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,44763697)
	-- 设置②效果的发动代价：把墓地中的这张卡除外作为发动COST。
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c44763696.thcon)
	e2:SetTarget(c44763696.thtg)
	e2:SetOperation(c44763696.thop)
	c:RegisterEffect(e2)
end
-- 过滤被破坏的怪兽：判定其上一个控制者为发动者、之前位于我方主要怪兽区、之前为表侧表示、属于「罪」系列，且破坏原因为战斗，或为对方控制的效果造成的效果破坏。
function c44763696.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsSetCard(0x23)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- ①效果的发动条件：本次被破坏的怪兽组中，存在至少1只满足cfilter条件的「罪」怪兽。
function c44763696.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44763696.cfilter,1,nil,tp)
end
-- ①效果的发动目标处理：先确认自己能否抽2张；若能，则将目标玩家设为自己、目标参数设为2，并登记抽卡的操作信息。
function c44763696.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认自己当前可以抽2张卡（chk==0表示发动时的合法性确认）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的效果目标玩家设为发动者自己，表示最终抽卡的是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果参数设为2，表示抽卡数量为2张。
	Duel.SetTargetParam(2)
	-- 向系统登记操作信息：本效果涉及抽卡分类，玩家tp抽2张卡（具体卡牌在效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ①效果处理：从连锁信息中取出目标玩家和抽卡数量，让该玩家以效果原因抽对应张数的卡。
function c44763696.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得之前设定的目标玩家（谁抽卡）和目标参数（抽几张）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡：让玩家p以REASON_EFFECT原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤被破坏的怪兽：判定其上一个控制者为发动者、之前位于我方主要怪兽区、之前为表侧表示、属于「罪」系列，且破坏原因不是战斗（即战斗以外的破坏）。
function c44763696.cfilter2(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsSetCard(0x23) and not c:IsReason(REASON_BATTLE)
end
-- ②效果的触发条件：本次被破坏的怪兽组中，存在至少1只满足cfilter2条件的「罪」怪兽。
function c44763696.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44763696.cfilter2,1,nil,tp)
end
-- 检索过滤条件：对象必须是「罪」字段的怪兽卡，并且可以加入手牌。
function c44763696.thfilter(c)
	return c:IsSetCard(0x23) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动条件与目标设定：先确认卡组中存在可以检索的「罪」怪兽；若存在，则登记从卡组将1只「罪」怪兽加入手牌的操作信息。
function c44763696.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认卡组中是否存在1张满足thfilter的「罪」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c44763696.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统登记操作信息：本效果涉及检索与加入手牌分类，从卡组选1张「罪」怪兽加入手牌（具体卡牌在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：由发动者从卡组选择1张满足条件的「罪」怪兽加入手牌，并向对方展示确认。
function c44763696.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动者从自己卡组中选出1张满足thfilter的「罪」怪兽。
	local g=Duel.SelectMatchingCard(tp,c44763696.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡送去持有者手牌（nil表示返回持有者手牌），原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
