--魔轟神レイジオン
-- 效果：
-- 「魔轰神」调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤时才能发动。自己直到手卡变成2张为止抽卡。
function c47395382.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整素材要求为「魔轰神」怪兽（Card.IsSetCard,0x35），调整以外的素材为任意怪兽1只以上，即素材要求为「魔轰神」调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x35),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤时才能发动。自己直到手卡变成2张为止抽卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47395382,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c47395382.con)
	e1:SetTarget(c47395382.tg)
	e1:SetOperation(c47395382.op)
	c:RegisterEffect(e1)
end
-- 同调召唤成功时触发条件：这张卡以同调召唤（SUMMON_TYPE_SYNCHRO）方式特殊召唤成功。
function c47395382.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果发动前的合法性检查和发动时登记：先判断自己手牌是否不足2张且能否抽卡；若可发动，则将对象玩家设为自己、抽卡数量设为2-当前手牌数，并登记抽卡的操作信息。
function c47395382.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得自己当前的手卡数量。
		local h=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		-- 判断是否满足发动条件：自己手卡数小于2，且自己可以抽（2-手牌数）张卡。
		return h<2 and Duel.IsPlayerCanDraw(tp,2-h)
	end
	-- 发动时再次取得自己当前的手卡数量，用于计算需要抽的卡数。
	local h=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 将当前连锁的处理对象玩家设置为效果发动者自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的处理参数设置为（2-当前手牌数），即需要抽的卡数。
	Duel.SetTargetParam(2-h)
	-- 设置操作信息：本次效果处理将执行抽卡，目标玩家为自己，预定的抽卡数量为2-当前手牌数，没有确定的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2-h)
end
-- 效果处理：取得之前登记的对象玩家，若其手牌仍然不足2张，则抽取补足到2张所需数量的卡。
function c47395382.op(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁登记的对象玩家（即效果发动者自己）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 取得该玩家当前的手卡数量。
	local h=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	if h>=2 then return end
	-- 让玩家p抽取（2-当前手牌数）张卡，使其手卡变成2张。
	Duel.Draw(p,2-h,REASON_EFFECT)
end
