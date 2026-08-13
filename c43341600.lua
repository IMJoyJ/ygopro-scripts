--フライアのリンゴ
-- 效果：
-- ①：以最多有自己场上的「女武神」怪兽数量的对方墓地的卡为对象才能发动。那些卡除外。
-- ②：盖放的这张卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合才能发动。自己从卡组抽出自己场上的「女武神」怪兽的数量＋1张。
function c43341600.initial_effect(c)
	-- ①：以最多有自己场上的「女武神」怪兽数量的对方墓地的卡为对象才能发动。那些卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c43341600.target)
	e1:SetOperation(c43341600.activate)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合才能发动。自己从卡组抽出自己场上的「女武神」怪兽的数量＋1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(c43341600.drcon)
	e2:SetTarget(c43341600.drtg)
	e2:SetOperation(c43341600.drop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- 过滤函数：判定怪兽是否为表侧表示且属于「女武神」系列（字段0x122），用于统计自己场上的女武神怪兽。
function c43341600.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x122)
end
-- 效果对象选择与发动条件判定：若为连锁对象确认（chkc），对象须是对方墓地且可除外的卡；若为合法性检查（chk==0），须满足自己场上有女武神怪兽且对方墓地存在可选对象。
function c43341600.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsAbleToRemove() and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) end
	-- 发动条件检测：自己场上是否存在至少1只表侧表示的女武神怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c43341600.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 发动条件检测：对方墓地是否存在至少1张可以被除外的卡。
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 统计自己场上表侧表示的女武神怪兽数量，作为可选择对象的数量上限。
	local ct=Duel.GetMatchingGroupCount(c43341600.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 向玩家显示选择提示消息：‘请选择要除外的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方墓地选择1~ct张（ct为自己场上女武神数量）可以除外的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,ct,nil)
	-- 设置连锁操作信息：本次效果将除外对象卡，数量为对象数，对象持有者为对方，位置为墓地。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果处理：从连锁信息中取得对象卡，将与效果关联的卡全部以表侧表示除外。
function c43341600.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中取出本效果的对象卡组，并筛选出仍与这个效果存在关联的卡（排除已离场或对象被无效的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将选中的卡以表侧表示除外，除外原因记为效果。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果②的触发条件：这张里侧表示的卡因对方玩家的效果从场上离开（送去墓地或被除外），且离场前由自己控制、处于场上里侧表示。
function c43341600.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp~=tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 效果②的target：统计自己场上女武神数量，检查能否抽相应张数；设置对象玩家为自己，并写入抽卡的操作信息。
function c43341600.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计自己场上表侧表示的女武神怪兽数量，用于计算抽卡张数。
	local ct=Duel.GetMatchingGroupCount(c43341600.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 发动合法性检测：自己能否抽出（女武神数量+1）张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct+1) end
	-- 将本次连锁的对象玩家设置为自己，便于处理阶段获知抽卡玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作信息：本次效果执行抽卡，对象玩家为自己，预计抽卡数量为ct+1（ct为女武神数量）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct+1)
end
-- 效果②处理：从连锁信息中取得抽卡玩家，按该玩家场上的女武神数量+1张进行抽卡。
function c43341600.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回在target中设置的对象玩家（即抽卡玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 统计玩家p场上表侧表示的女武神怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c43341600.cfilter,p,LOCATION_MZONE,0,nil)
	-- 让玩家p从卡组抽（女武神数量+1）张卡，抽卡原因为效果。
	Duel.Draw(p,ct+1,REASON_EFFECT)
end
