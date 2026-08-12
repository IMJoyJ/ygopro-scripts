--闇の指名者
-- 效果：
-- 宣言1种怪兽卡的名字。当这种怪兽卡在对方的卡组中存在时，那种卡其中1张加入对方手卡。
function c78053598.initial_effect(c)
	-- 宣言1种怪兽卡的名字。当这种怪兽卡在对方的卡组中存在时，那种卡其中1张加入对方手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c78053598.target)
	e1:SetOperation(c78053598.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标选择与宣言卡名的处理
function c78053598.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方卡组中是否存在可以加入手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_DECK,1,nil) end
	-- 提示玩家宣言一个卡名
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_MONSTER,OPCODE_ISTYPE,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT,OPCODE_AND}
	-- 让发动效果的玩家宣言一个非额外怪兽的怪兽卡名
	local code=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡名作为效果参数保存
	Duel.SetTargetParam(code)
	-- 设置连锁信息，表示该效果包含宣言卡名的操作
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 过滤对方卡组中与宣言卡名相同且能加入手牌的怪兽卡
function c78053598.filter(c,code)
	return c:IsType(TYPE_MONSTER) and c:IsCode(code) and c:IsAbleToHand()
end
-- 效果发动后的具体处理逻辑
function c78053598.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时宣言的卡名
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 提示对方玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让对方玩家从其卡组中选择1张宣言的怪兽卡
	local g=Duel.SelectMatchingCard(1-tp,c78053598.filter,1-tp,LOCATION_DECK,0,1,1,nil,code)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡加入对方手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让发动效果的玩家确认加入对方手牌的卡
		Duel.ConfirmCards(tp,tc)
	end
end
