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
-- 发动条件与宣言怪兽卡名
function c78053598.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方卡组是否有可以加入手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_DECK,1,nil,1-tp) end
	-- 提示宣言卡名
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_MONSTER,OPCODE_ISTYPE,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT,OPCODE_AND}
	-- 宣言1个主卡组怪兽卡名
	local code=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 设置宣言的卡名参数
	Duel.SetTargetParam(code)
	-- 设置操作信息：宣言卡名
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 过滤条件：宣言卡名的怪兽且可加入手卡
function c78053598.filter(c,code,p)
	return c:IsType(TYPE_MONSTER) and c:IsCode(code) and c:IsAbleToHand(p)
end
-- 效果处理函数
function c78053598.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取宣言的卡名
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 提示对方选择宣言的怪兽加入手卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 对方从卡组选择1张宣言卡名的怪兽
	local g=Duel.SelectMatchingCard(1-tp,c78053598.filter,1-tp,LOCATION_DECK,0,1,1,nil,code,1-tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽加入对方手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT,1-tp)
		-- 向自己确认加入手卡的怪兽
		Duel.ConfirmCards(tp,tc)
	end
end
