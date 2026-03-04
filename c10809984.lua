--世紀の大泥棒
-- 效果：
-- 每当这张卡给与对方战斗伤害时，宣言1张卡的名字。检视对方手卡，若其中有被宣言名字的卡，则将其全部扔进墓地。
function c10809984.initial_effect(c)
	-- 每当这张卡给与对方战斗伤害时，宣言1张卡的名字。检视对方手卡，若其中有被宣言名字的卡，则将其全部扔进墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10809984,0))  --"宣言"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c10809984.drcon)
	e1:SetTarget(c10809984.drtg)
	e1:SetOperation(c10809984.drop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：造成战斗伤害的玩家不是自己
function c10809984.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动时的处理：宣言一张卡名
function c10809984.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家提示选择卡名
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让玩家宣言一张卡的卡号
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡号设置为连锁参数
	Duel.SetTargetParam(ac)
	-- 设置连锁操作信息为宣言卡名
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果发动后的处理：检索对方手牌并破坏符合条件的卡
function c10809984.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中宣言的卡号
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 检索对方手牌中与宣言卡号相同的卡
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_HAND,nil,ac)
	-- 获取对方手牌的全部卡片组
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 确认对方手牌
	Duel.ConfirmCards(tp,hg)
	if g:GetCount()>0 then
		-- 将符合条件的卡送入墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	end
	-- 将对方手牌洗牌
	Duel.ShuffleHand(1-tp)
end
