--世紀の大泥棒
-- 效果：
-- 每当这张卡给与对方战斗伤害时，宣言1张卡的名字。检视对方手卡，若其中有被宣言名字的卡，则将其全部扔进墓地。
function c10809984.initial_effect(c)
	-- 每当这张卡给与对方战斗伤害时，宣言1张卡的名字。检视对方手卡，若其中有被宣言名字的卡，则将其全部扔进墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10809984,0))  --"宣言"
	e1:SetCategory(CATEGORY_HANDES_OPPO)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c10809984.drcon)
	e1:SetTarget(c10809984.drtg)
	e1:SetOperation(c10809984.drop)
	c:RegisterEffect(e1)
end
-- 判断受到伤害的玩家是否为对方（给与对方战斗伤害的发动条件）
function c10809984.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动时的目标选择与卡名宣言处理
function c10809984.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示己方玩家进行卡名宣言
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让己方玩家宣言一个非额外怪兽的卡名
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡号保存为当前连锁的效果参数
	Duel.SetTargetParam(ac)
	-- 设置当前连锁的操作信息为宣言卡名
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 获取宣言卡名，检视对方手牌并将同名卡全部送去墓地，最后洗切对方手牌
function c10809984.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁被宣言的卡片卡号
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 筛选对方手牌中与宣言卡名同名的卡片
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_HAND,nil,ac)
	-- 获取对方的全部手牌
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 给己方玩家确认（检视）对方的所有手牌
	Duel.ConfirmCards(tp,hg)
	if g:GetCount()>0 then
		-- 将这些与宣言卡名相同的卡以效果丢弃的方式送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	end
	-- 洗切对方的手牌
	Duel.ShuffleHand(1-tp)
end
