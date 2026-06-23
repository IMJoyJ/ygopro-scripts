--魔轟神レイジオン
-- 效果：
-- 「魔轰神」调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤时才能发动。自己直到手卡变成2张为止抽卡。
function c47395382.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整且为魔轰神卡组的怪兽，以及至少1只非调整的怪兽参与同调
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
-- 判断此卡是否为同调召唤成功
function c47395382.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置效果的发动条件，检查玩家手牌数量是否少于2且可以抽卡
function c47395382.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前玩家手牌数量
		local h=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		-- 返回手牌数小于2并且玩家可以抽卡的数量
		return h<2 and Duel.IsPlayerCanDraw(tp,2-h)
	end
	-- 再次获取当前玩家手牌数量
	local h=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 设置连锁的目标玩家为当前处理的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的目标参数为需要抽卡的数量
	Duel.SetTargetParam(2-h)
	-- 设置效果操作信息，指定将要进行抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2-h)
end
-- 设置效果的处理函数，执行实际抽卡操作
function c47395382.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取目标玩家的手牌数量
	local h=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	if h>=2 then return end
	-- 让目标玩家以效果原因抽卡
	Duel.Draw(p,2-h,REASON_EFFECT)
end
