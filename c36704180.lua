--幻影騎士団フラジャイルアーマー
-- 效果：
-- 「幻影骑士团 脆铠甲」的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示的「幻影骑士团」怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把墓地的这张卡除外，把手卡1张「幻影骑士团」卡或者「幻影」魔法·陷阱卡送去墓地才能发动。自己从卡组抽1张。
function c36704180.initial_effect(c)
	-- ①：自己场上的表侧表示的「幻影骑士团」怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36704180,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1,36704180)
	e1:SetCondition(c36704180.condition)
	e1:SetTarget(c36704180.target)
	e1:SetOperation(c36704180.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，把手卡1张「幻影骑士团」卡或者「幻影」魔法·陷阱卡送去墓地才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36704180,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,36704181)
	e2:SetCost(c36704180.drcost)
	e2:SetTarget(c36704180.drtg)
	e2:SetOperation(c36704180.drop)
	c:RegisterEffect(e2)
end
-- 筛选被破坏的怪兽是否满足触发①效果的条件：必须因战斗或效果破坏、是「幻影骑士团」怪兽、原控制者为这张卡的控制者、之前位于主要怪兽区且为表侧表示。
function c36704180.filter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsSetCard(0x10db) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 判断被破坏的怪兽组中是否存在至少1张符合上述筛选条件的怪兽，以此作为①效果的触发条件。
function c36704180.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36704180.filter,1,nil,tp)
end
-- 发动时点检测：自己的主要怪兽区有空位，且手牌的这张卡满足特殊召唤条件（可被特殊召唤）。
function c36704180.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的特殊召唤操作信息：将这张卡特殊召唤（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与①效果关联（未被无效或离场等），则进行特殊召唤。
function c36704180.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的场上（经过通常的召唤条件/苏生限制检查）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 筛选可作为②发动代价的手卡：是「幻影骑士团」卡，或是「幻影」魔法·陷阱卡，且可以送入墓地作为代价。
function c36704180.drcfilter(c)
	return (c:IsSetCard(0x10db) or (c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP))) and c:IsAbleToGraveAsCost()
end
-- ②发动代价检测：墓地中的这张卡可以被除外，且手卡存在满足条件的「幻影骑士团」/「幻影」卡。
function c36704180.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查手卡是否存在至少1张符合条件的「幻影骑士团」卡或「幻影」魔法·陷阱卡。
		and Duel.IsExistingMatchingCard(c36704180.drcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 把墓地中的这张卡表侧除外作为②的发动代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 从手卡丢弃1张符合条件的「幻影骑士团」卡或「幻影」魔法·陷阱卡作为②的发动代价。
	Duel.DiscardHand(tp,c36704180.drcfilter,1,1,REASON_COST,nil)
end
-- 抽卡效果的发动条件与目标设定：确认自己可抽1张卡；将目标玩家设为自己、抽卡数设为1，并设置抽卡操作信息。
function c36704180.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以进行1张抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁处理的对象玩家设为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁处理的对象参数设为1，即抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置抽卡的操作信息：不指定对象，预计让玩家tp抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：从连锁信息中取出目标玩家和抽卡数，并执行抽卡。
function c36704180.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的目标玩家与抽卡数参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家以效果原因抽取指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
