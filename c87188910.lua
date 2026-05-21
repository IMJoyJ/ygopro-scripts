--飢鰐竜アーケティス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。自己抽出那些作为同调素材的怪兽之内除调整以外的怪兽的数量。
-- ②：这张卡的攻击力·守备力上升自己手卡数量×500。
-- ③：自己·对方回合，丢弃2张手卡，以场上1张卡为对象才能发动。那张卡破坏。
function c87188910.initial_effect(c)
	-- 为卡片添加同调召唤手续：需要1只调整和1只以上调整以外的怪兽。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。自己抽出那些作为同调素材的怪兽之内除调整以外的怪兽的数量。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87188910,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,87188910)
	e1:SetCondition(c87188910.drcon)
	e1:SetTarget(c87188910.drtg)
	e1:SetOperation(c87188910.drop)
	c:RegisterEffect(e1)
	-- 自己抽出那些作为同调素材的怪兽之内除调整以外的怪兽的数量。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c87188910.valcheck)
	e0:SetLabelObject(e1)
	c:RegisterEffect(e0)
	-- ②：这张卡的攻击力·守备力上升自己手卡数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c87188910.adval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：自己·对方回合，丢弃2张手卡，以场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(87188910,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,87188911)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCost(c87188910.descost)
	e4:SetTarget(c87188910.destg)
	e4:SetOperation(c87188910.desop)
	c:RegisterEffect(e4)
end
-- 检查同调素材，将除调整以外的怪兽数量（总素材数减1）作为标签值存入效果e1中。
function c87188910.valcheck(e,c)
	e:GetLabelObject():SetLabel(c:GetMaterialCount()-1)
end
-- 判断此卡是否为同调召唤成功，作为抽卡效果的发动条件。
function c87188910.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 抽卡效果的发动准备：检查是否能抽卡，并设置抽卡玩家、抽卡数量以及操作信息。
function c87188910.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	-- 判断非调整素材数量是否大于0，且玩家当前是否可以抽对应数量的卡。
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 将当前连锁的对象玩家设置为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为非调整素材的数量。
	Duel.SetTargetParam(ct)
	-- 设置当前连锁的操作信息为：玩家抽对应数量的卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 抽卡效果的执行：获取目标玩家和抽卡数量，并执行抽卡。
function c87188910.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 攻击力·守备力上升值的计算函数。
function c87188910.adval(e,c)
	-- 返回自己手卡数量乘以500的数值。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*500
end
-- 破坏效果的发动代价：检查并丢弃2张手卡。
function c87188910.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手卡中是否存在至少2张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil) end
	-- 从手卡中选择2张可以丢弃的卡送去墓地，作为发动代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end
-- 破坏效果的发动准备：检查并选择场上的1张卡作为对象，并设置破坏操作信息。
function c87188910.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 判断场上是否存在至少1张可以作为对象的目标卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为：破坏选中的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行：获取对象卡，若其仍存在于场上则将其破坏。
function c87188910.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
